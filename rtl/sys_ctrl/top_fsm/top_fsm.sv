module top_fsm #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8,
    parameter ALU_OUT_WIDTH = 16
) (
    input  logic                     i_clk, 
    input  logic                     i_RSTn,
    
    // Data Sync Interface
    input  logic                     data_synchronizer_valid,
    input  logic [DATA_WIDTH-1 : 0]  synch_data,

    // FIFO/UART TX Interface
    input  logic                     i_FIFO_FULL,
    output logic [DATA_WIDTH-1 : 0]  o_WR_DATA, 
    output logic                     o_WR_INC,

    // ALU FSM Interface
    output logic                     o_alu_start,
    output logic                     o_alu_operands_en, // 1: Fetch, 0: Use existing
    input  logic                     i_alu_done,
    input  logic [ALU_OUT_WIDTH-1:0] i_ALU_OUT,

    // RegFile FSM Interface
    output logic                     o_reg_start,
    output logic                     o_reg_rw_en,
    input  logic                     i_reg_done,
    input  logic [DATA_WIDTH-1 : 0]  i_Rd_D
);

    typedef enum logic [2:0] {
        IDLE,
        DECODE,
        WAIT_REG,
        WAIT_ALU,
        SEND_RESULT_1,
        SEND_RESULT_2
    } t_state;

    t_state curr_state, next_state;
    logic [DATA_WIDTH-1:0] r_command;

    // --- State Register ---
    always_ff @(posedge i_clk or negedge i_RSTn) begin
        if (!i_RSTn) curr_state <= IDLE;
        else         curr_state <= next_state;
    end

    // --- Command Latch ---
    always_ff @(posedge i_clk or negedge i_RSTn) begin
        if (!i_RSTn) r_command <= '0;
        else if (curr_state == IDLE && data_synchronizer_valid) 
            r_command <= synch_data;
    end

    // --- Next State & Main Control Logic ---
    always_comb begin
        next_state        = curr_state;
        o_alu_start       = 1'b0;
        o_alu_operands_en = 1'b0;
        o_reg_start       = 1'b0;
        o_reg_rw_en       = 1'b0;
        o_WR_INC          = 1'b0;
        o_WR_DATA         = '0;

        case (curr_state)
            IDLE: if (data_synchronizer_valid) next_state = DECODE;

            DECODE: begin
                case (r_command)
                    8'hAA: begin // Reg Write
                        o_reg_start = 1'b1;
                        o_reg_rw_en = 1'b1;
                        next_state  = WAIT_REG;
                    end
                    8'hBB: begin // Reg Read
                        o_reg_start = 1'b1;
                        o_reg_rw_en = 1'b0;
                        next_state  = WAIT_REG;
                    end
                    8'hCC: begin // ALU WITH Fetch
                        o_alu_start       = 1'b1;
                        o_alu_operands_en = 1'b1; // Tell ALU FSM to fetch
                        next_state        = WAIT_ALU;
                    end
                    8'hDD: begin // NEW: ALU WITHOUT Fetch
                        o_alu_start       = 1'b1;
                        o_alu_operands_en = 1'b0; // Tell ALU FSM to skip fetch
                        next_state        = WAIT_ALU;
                    end
                    default: next_state = IDLE;
                endcase
            end

            WAIT_REG: if (i_reg_done) begin
                if (r_command == 8'hBB) next_state = SEND_RESULT_1;
                else                    next_state = IDLE;
            end

            WAIT_ALU: if (i_alu_done) next_state = SEND_RESULT_1;

            SEND_RESULT_1: begin
                if (!i_FIFO_FULL) begin
                    o_WR_INC  = 1'b1;
                    // Send Reg Data or Low byte of ALU
                    o_WR_DATA = (r_command == 8'hBB) ? i_Rd_D : i_ALU_OUT[7:0];
                    
                    if (r_command == 8'hBB) next_state = IDLE;
                    else                    next_state = SEND_RESULT_2;
                end
            end

            SEND_RESULT_2: begin
                if (!i_FIFO_FULL) begin
                    o_WR_INC  = 1'b1;
                    o_WR_DATA = i_ALU_OUT[15:8]; // Send high byte
                    next_state = IDLE;
                end
            end

            default: next_state = IDLE;
        endcase
    end

endmodule