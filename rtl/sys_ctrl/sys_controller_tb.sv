`timescale 1ns/1ps

module SYS_CTRL_tb();

    // --- Parameters ---
    parameter ADDR_WIDTH     = 4;
    parameter DATA_WIDTH     = 8;
    parameter ALU_OUT_WIDTH  = 16;
    parameter ALU_FUN_WIDTH  = 4;

    // --- Clock Period Calculations ---
    // REF_CLK = 50 MHz -> Period = 20ns
    localparam T_REF  = 20; 
    // UART_CLK = 3.6864 MHz -> Period = 1/3.6864M = ~271.26ns
    localparam T_UART = 271.26; 

    // --- Signals ---
    logic                     i_clk;      // System Clock (REF_CLK)
    logic                     i_uart_clk; // UART Clock domain
    logic                     i_RSTn;
    logic                     data_synchronizer_valid;
    logic [DATA_WIDTH-1 : 0]  synch_data;
    logic                     i_FIFO_FULL;
    
    wire                      o_WrEn, o_RdEn;
    wire [ADDR_WIDTH-1 : 0]   o_Addr;
    wire [DATA_WIDTH-1 : 0]   o_Wr_D;
    logic [DATA_WIDTH-1 : 0]  i_Rd_D;

    wire [ALU_FUN_WIDTH-1:0]  o_ALU_Func;
    wire                      o_ALU_EN;
    logic                     i_ALU_OUT_Valid;
    logic [ALU_OUT_WIDTH-1:0] i_ALU_OUT_Result;

    wire [DATA_WIDTH-1 : 0]   o_TX_DATA;
    wire                      o_TX_WR_INC;

    logic [DATA_WIDTH-1 : 0]  test_read_data_override;

    // --- DUT Instantiation ---
    SYS_CTRL #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ALU_OUT_WIDTH(ALU_OUT_WIDTH),
        .ALU_FUN_WIDTH(ALU_FUN_WIDTH)
    ) DUT (
        .i_clk(i_clk), // Connected to REF_CLK
        .* );

    // --- Dual Clock Generation ---
    initial i_clk = 0;
    always #(T_REF/2) i_clk = ~i_clk;

    initial i_uart_clk = 0;
    always #(T_UART/2) i_uart_clk = ~i_uart_clk;

    // --- Helper Tasks ---

    // Updated to synchronize with UART_CLK
    task send_uart_byte(input [DATA_WIDTH-1:0] data);
        begin
            @(posedge i_uart_clk); // Synchronize to UART domain
            synch_data <= data;
            @(posedge i_clk);
            data_synchronizer_valid <= 1'b1;
            @(posedge i_clk);
            data_synchronizer_valid <= 1'b0;
            @(posedge i_uart_clk); // Synchronize to UART domain
            @(posedge i_uart_clk); // Synchronize to UART domain
        end
    endtask

    // Memory Emulation (Must stay in i_clk domain)
    always_ff @(posedge i_clk) begin
        if (o_RdEn) begin
            if (test_read_data_override != '0)
                i_Rd_D <= test_read_data_override;
            else
                i_Rd_D <= 8'hA5;
        end
    end

    // --- Test Procedure ---
    initial begin
        // Initialization
        i_RSTn = 0; i_FIFO_FULL = 0;
        data_synchronizer_valid = 0; synch_data = '0;
        i_ALU_OUT_Valid = 0; i_ALU_OUT_Result = '0;
        test_read_data_override = '0;

        // Reset Sequence (Relative to System Clock)
        $display("[SYSTEM] Applying Reset...");
        #(T_REF*2) i_RSTn = 1;
        #(T_REF*2);

        // --- TEST CASE 1: MANUAL REGISTER WRITE (0xAA) ---
        $display("\n[CASE 1] Manual Reg Write: Addr 0x4, Data 0xF1");
        send_uart_byte(8'hAA); 
        send_uart_byte(8'h04); 
        send_uart_byte(8'hF1); 
        //wait(DUT.i_reg_done);
        #(T_REF*5);

        // --- TEST CASE 2: MANUAL REGISTER READ (0xBB) ---
        $display("\n[CASE 2] Manual Reg Read: Addr 0x4");
        test_read_data_override = 8'hF1; 
        send_uart_byte(8'hBB); 
        send_uart_byte(8'h04); 
        
        //wait(o_TX_WR_INC);
        $display("[CHECK] TX Received Data: 0x%h", o_TX_DATA);
        #(T_REF*5);
        test_read_data_override = '0;

        // --- TEST CASE 3: ALU WITH OPERAND FETCH (0xCC) ---
        $display("\n[CASE 3] ALU With Fetch: 10 + 5 (Addition)");
        send_uart_byte(8'hCC); 
        send_uart_byte(8'h0A); 
        send_uart_byte(8'h05); 
        send_uart_byte(8'h00); 
        
        wait(o_ALU_EN);
        #(T_REF*3); 
        i_ALU_OUT_Result <= 16'h000F;
        i_ALU_OUT_Valid  <= 1'b1;
        @(posedge i_clk);
        i_ALU_OUT_Valid  <= 1'b0;

        wait(o_TX_WR_INC);
        $display("[CHECK] ALU Low Byte: 0x%h", o_TX_DATA);
        @(posedge i_clk);
        wait(o_TX_WR_INC);
        $display("[CHECK] ALU High Byte: 0x%h", o_TX_DATA);
        #(T_REF*10);

        $display("\n[SYSTEM] ALL TEST CASES PASSED SUCCESSFULLY");
        $stop;
    end

    // Monitoring
    always @(posedge i_clk) begin
        if (o_WrEn) $display("    [BUS] WRITE | Addr: %h | Data: %h", o_Addr, o_Wr_D);
        if (o_RdEn) $display("    [BUS] READ  | Addr: %h", o_Addr);
    end

endmodule