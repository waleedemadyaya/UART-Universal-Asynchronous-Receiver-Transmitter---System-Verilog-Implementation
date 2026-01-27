module alu_fsm #(
    parameter ALU_FUN_WIDTH = 4,
    parameter ALU_OUT_WIDTH  = 16,
    parameter DATA_WIDTH    = 8  // Added for synch_data
) (
    input  logic                      i_clk, 
    input  logic                      i_RSTn,
    input  logic                      i_alu_start,            
    input  logic                      data_synchronizer_valid,
    input  logic [DATA_WIDTH-1 : 0]   synch_data,
    input  logic                      i_operands_en, // 1: Need to fetch from RegFile

    // Interface to RegFile Master
    output logic                      o_read_operands,
    input  logic                      i_read_operands_done,

    // Interface to ALU
    output logic [ALU_FUN_WIDTH-1 : 0] o_Func,
    output logic                      o_EN,
    output logic                      o_CLK_EN,
    output logic [ALU_OUT_WIDTH-1 : 0] o_ALU_OUT,
    input  logic                      i_OUT_Valid,
    input  logic [ALU_OUT_WIDTH-1 : 0] i_ALU_OUT,
    
    // Interface to Master System Ctrl
    output logic                      o_alu_done
);

    logic [ALU_FUN_WIDTH-1 : 0] r_latched_func;

    typedef enum logic [2:0] {
        IDLE,
        READ_OPERANDS,
        WAIT_FUNC,
        CALC,
        DONE
    } t_state;

    t_state curr_state, next_state;

    // --- State Register ---
    always_ff @(posedge i_clk or negedge i_RSTn) begin : alu_fsm_curr_state
        if (!i_RSTn) curr_state <= IDLE;
        else         curr_state <= next_state;
    end

    // --- Next State & Control Logic ---
    always_comb begin : alu_fsm_next_state
        next_state      = curr_state;
        o_read_operands = 1'b0;
        o_Func          = r_latched_func; // Output the latched function
        o_EN            = 1'b0;
        o_CLK_EN        = 1'b0;
        o_alu_done      = 1'b0;

        case(curr_state)
            IDLE: begin
                if (i_alu_start) begin
                    if (i_operands_en) next_state = READ_OPERANDS;
                    else               next_state = WAIT_FUNC;
                end
            end

            READ_OPERANDS: begin
                o_read_operands = 1'b1;
                o_CLK_EN = 1'b1;
                if (i_read_operands_done) next_state = WAIT_FUNC;
            end

            WAIT_FUNC: begin
                o_CLK_EN = 1'b1;
                if (data_synchronizer_valid) next_state = CALC;
            end

            CALC: begin
                o_EN = 1'b1;
                o_CLK_EN = 1'b1;
                if (i_OUT_Valid) next_state = DONE;
            end

            DONE: begin
                o_CLK_EN = 1'b1;
                o_alu_done = 1'b1;
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // --- Function Capture Logic ---
    always_ff @(posedge i_clk or negedge i_RSTn) begin
        if (!i_RSTn) begin
            r_latched_func <= '0;
            o_ALU_OUT <= '0;
        end else begin
            if (curr_state == IDLE && i_alu_start) begin
                r_latched_func <= '0;
                o_ALU_OUT <= '0;
            end 
            else if (curr_state == WAIT_FUNC && data_synchronizer_valid) begin
                r_latched_func <= synch_data[ALU_FUN_WIDTH-1:0];
            end else if (curr_state == DONE) begin
                o_ALU_OUT <= i_ALU_OUT;
            end
        end
    end

endmodule