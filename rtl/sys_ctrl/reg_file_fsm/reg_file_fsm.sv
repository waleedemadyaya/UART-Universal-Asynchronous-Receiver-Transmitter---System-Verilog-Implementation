module reg_file_fsm #(
    parameter ADDRESS_WIDTH   = 4,
    parameter DATA_WIDTH = 8,
    parameter WRDATA_WIDTH    = 8
) (
    input  logic                      i_clk, 
    input  logic                      i_RSTn,
    input  logic                      i_reg_start,            
    input  logic                      data_synchronizer_valid,
    input  logic [WRDATA_WIDTH-1 : 0] synch_data,
    input  logic                      i_rw_en,        // 0: Read, 1: Write
    input  logic                      i_alu_fetch_en, // High when ALU needs operands

    output logic                      o_WrEn, 
    output logic                      o_RdEn, 
    output logic [ADDRESS_WIDTH-1 : 0] o_Addr, 
    output logic [WRDATA_WIDTH-1 : 0]  o_Wr_D,
    output logic                      o_reg_done,
    input  logic [DATA_WIDTH-1 : 0]  i_Rd_D,

    output logic [DATA_WIDTH-1 : 0]  o_Rd_D       
);

    logic r_latched_rw_en;

    typedef enum logic [3:0] { 
        IDLE,
        WAIT_ADDR,
        WAIT_DATA,
        ALU_FETCH_A, 
        ALU_WRITE_A, // New State
        ALU_FETCH_B, 
        ALU_WRITE_B, // New State
        READ_STROBE,
        WRITE_STROBE,
        DONE
    } t_state;

    t_state curr_state, next_state;

    // --- State Register ---
    always_ff @( posedge i_clk or negedge i_RSTn ) begin
        if (!i_RSTn) curr_state <= IDLE;
        else         curr_state <= next_state;
    end

    // --- Next State & Control Logic ---
    always_comb begin
        next_state = curr_state;
        o_WrEn     = 1'b0;
        o_RdEn     = 1'b0;
        o_reg_done = 1'b0;

        case (curr_state)
            IDLE: begin
                if (i_reg_start) begin
                    if (i_alu_fetch_en) next_state = ALU_FETCH_A;
                    else                next_state = WAIT_ADDR;
                end
            end
            
            // --- Manual Flow ---
            WAIT_ADDR: if (data_synchronizer_valid) begin
                if (r_latched_rw_en == 1'b0)    next_state = READ_STROBE;
                else                    next_state = WAIT_DATA;
            end
            WAIT_DATA: if (data_synchronizer_valid) next_state = WRITE_STROBE;

            // --- ALU Auto-Fetch Flow (Updated) ---
            ALU_FETCH_A: if (data_synchronizer_valid) next_state = ALU_WRITE_A;
            
            ALU_WRITE_A: begin
                o_WrEn     = 1'b1;       // Write Operand A to Addr 0
                next_state = ALU_FETCH_B;
            end

            ALU_FETCH_B: if (data_synchronizer_valid) next_state = ALU_WRITE_B;

            ALU_WRITE_B: begin
                o_WrEn     = 1'b1;       // Write Operand B to Addr 1
                next_state = DONE;
            end

            READ_STROBE: begin
                o_RdEn     = 1'b1;
                next_state = DONE;
            end

            WRITE_STROBE: begin
                o_WrEn     = 1'b1;
                next_state = DONE;
            end
            
            DONE: begin
                o_reg_done = 1'b1;
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // --- Data Capture Logic ---
    always_ff @( posedge i_clk or negedge i_RSTn ) begin
        if (!i_RSTn) begin
            o_Addr <= '0;
            o_Wr_D <= '0;
            o_Rd_D <= '0;
        end else begin
            if (curr_state == IDLE) begin
                if (i_reg_start) begin
                    o_Addr <= '0;
                    o_Wr_D <= '0;
                    o_Rd_D <= '0;
                end
            end 
            else if (curr_state == WAIT_ADDR && data_synchronizer_valid) begin
                o_Addr <= synch_data[ADDRESS_WIDTH-1:0];
            end 
            else if (curr_state == WAIT_DATA && data_synchronizer_valid) begin
                o_Wr_D <= synch_data;
            end
            // Auto-Capture logic
            else if (curr_state == ALU_FETCH_A && data_synchronizer_valid) begin
                o_Addr <= 'd0;        
                o_Wr_D <= synch_data; 
            end
            else if (curr_state == ALU_FETCH_B && data_synchronizer_valid) begin
                o_Addr <= 'd1;        
                o_Wr_D <= synch_data; 
            end else if (curr_state == DONE) begin
                o_Rd_D <= i_Rd_D;
            end
        end
    end

    always_ff @( posedge i_clk, negedge i_RSTn ) begin : latch_RWn
        if(!i_RSTn)begin
            r_latched_rw_en <= '0;
        end else begin
            if(curr_state == IDLE && i_reg_start == 1)begin
                r_latched_rw_en <= i_rw_en;
            end else if (curr_state == IDLE) begin
                r_latched_rw_en <= '0;
            end else begin
                r_latched_rw_en <= r_latched_rw_en;
            end
        end
    end
        
endmodule