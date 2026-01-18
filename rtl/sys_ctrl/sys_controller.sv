module SYS_CTRL #(
    parameter ADDR_WIDTH     = 4,
    parameter DATA_WIDTH     = 8,
    parameter ALU_OUT_WIDTH  = 16,
    parameter ALU_FUN_WIDTH  = 4
) (
    input  logic                     i_clk, 
    input  logic                     i_RSTn,
    
    // External Interface (from Data Synchronizer / UART)
    input  logic                     data_synchronizer_valid,
    input  logic [DATA_WIDTH-1 : 0]  synch_data,

    // Interface to Register File (Physical Memory)
    output logic                     o_WrEn, 
    output logic                     o_RdEn, 
    output logic [ADDR_WIDTH-1 : 0]  o_Addr, 
    output logic [DATA_WIDTH-1 : 0]  o_Wr_D,
    input  logic [DATA_WIDTH-1 : 0]  i_Rd_D,

    // Interface to ALU (Execution Unit)
    output logic [ALU_FUN_WIDTH-1:0] o_ALU_Func,
    output logic                     o_ALU_EN,
    input  logic                     i_ALU_OUT_Valid,
    input  logic [ALU_OUT_WIDTH-1:0] i_ALU_OUT_Result,

    // Interface to FIFO/UART TX
    input  logic                     i_FIFO_FULL,
    output logic [DATA_WIDTH-1 : 0]  o_TX_DATA,
    output logic                     o_TX_WR_INC
);

    // --- Internal Wire Declarations ---
    
    // Top FSM <-> ALU FSM
    logic o_alu_start;
    logic o_alu_operands_en;
    logic i_alu_done;
    logic [ALU_OUT_WIDTH-1:0] w_ALU_Result_Latching;

    // Top FSM <-> RegFile FSM
    logic o_reg_start;
    logic o_reg_rw_en;
    logic i_reg_done;
    logic [DATA_WIDTH-1:0] w_Reg_Read_Data;

    // ALU FSM <-> RegFile FSM (Handshake for operand fetching)
    logic w_alu_read_operands;
    logic w_alu_read_operands_done;

    // --- Module Instantiations ---

    // 1. The "Brain" - Decodes UART commands and manages the flow
    top_fsm #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ALU_OUT_WIDTH(ALU_OUT_WIDTH)
    ) U_top_fsm (
        .i_clk(i_clk), .i_RSTn(i_RSTn),
        .data_synchronizer_valid(data_synchronizer_valid),
        .synch_data(synch_data),
        .i_FIFO_FULL(i_FIFO_FULL),
        .o_WR_DATA(o_TX_DATA),
        .o_WR_INC(o_TX_WR_INC),
        .o_alu_start(o_alu_start),
        .o_alu_operands_en(o_alu_operands_en),
        .i_alu_done(i_alu_done),
        .i_ALU_OUT(w_ALU_Result_Latching),
        .o_reg_start(o_reg_start),
        .o_reg_rw_en(o_reg_rw_en),
        .i_reg_done(i_reg_done),
        .i_Rd_D(w_Reg_Read_Data)
    );

    // 2. The ALU Manager - Handles math operations and operand requests
    alu_fsm #(
        .ALU_FUN_WIDTH(ALU_FUN_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) U_alu_fsm (
        .i_clk(i_clk), .i_RSTn(i_RSTn),
        .i_alu_start(o_alu_start),
        .data_synchronizer_valid(data_synchronizer_valid),
        .synch_data(synch_data),
        .i_operands_en(o_alu_operands_en),
        .o_read_operands(w_alu_read_operands),
        .i_read_operands_done(w_alu_read_operands_done),
        .o_Func(o_ALU_Func),
        .o_EN(o_ALU_EN),
        .o_ALU_OUT(w_ALU_Result_Latching),
        .i_OUT_Valid(i_ALU_OUT_Valid),
        .i_ALU_OUT(i_ALU_OUT_Result),
        .o_alu_done(i_alu_done)
    );

    // 3. The RegFile Manager - Handles reading/writing to memory
    reg_file_fsm #(
        .ADDRESS_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .WRDATA_WIDTH(DATA_WIDTH)
    ) U_reg_file_fsm (
        .i_clk(i_clk), .i_RSTn(i_RSTn),
        .i_reg_start(o_reg_start || w_alu_read_operands), // Start on manual OR ALU request
        .data_synchronizer_valid(data_synchronizer_valid),
        .synch_data(synch_data),
        .i_rw_en(o_reg_rw_en), 
        .i_alu_fetch_en(w_alu_read_operands), // Tell RegFile if this is an auto-fetch
        .o_WrEn(o_WrEn),
        .o_RdEn(o_RdEn),
        .o_Addr(o_Addr),
        .o_Wr_D(o_Wr_D),
        .o_reg_done(i_reg_done_internal),
        .i_Rd_D(i_Rd_D),
        .o_Rd_D(w_Reg_Read_Data)
    );

    // --- Combinational Glue Logic ---
    assign i_reg_done = i_reg_done_internal;
    assign w_alu_read_operands_done = i_reg_done_internal && w_alu_read_operands;

endmodule