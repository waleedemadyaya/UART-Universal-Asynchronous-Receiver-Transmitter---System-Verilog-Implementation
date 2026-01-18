`timescale 1ns/1ps

module top_fsm_tb();

    // 1. Parameters and Signals
    parameter ADDR_WIDTH    = 4;
    parameter DATA_WIDTH    = 8;
    parameter ALU_OUT_WIDTH = 16;
    localparam T = 10; 

    logic                     i_clk;
    logic                     i_RSTn;
    logic                     data_synchronizer_valid;
    logic [DATA_WIDTH-1 : 0]  synch_data;
    logic                     i_FIFO_FULL;
    
    wire [DATA_WIDTH-1 : 0]   o_WR_DATA;
    wire                      o_WR_INC;
    wire                      o_alu_start;
    wire                      o_alu_operands_en;
    logic                     i_alu_done;
    logic [ALU_OUT_WIDTH-1:0] i_ALU_OUT;
    wire                      o_reg_start;
    wire                      o_reg_rw_en;
    logic                     i_reg_done;
    logic [DATA_WIDTH-1 : 0]  i_Rd_D;

    // 2. DUT Instantiation
    top_fsm #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ALU_OUT_WIDTH(ALU_OUT_WIDTH)
    ) DUT (.*);

    // 3. Clock Generation
    always #(T/2) i_clk = ~i_clk;

    // 4. Helper Task: Send UART Command/Data Pulse
    task send_uart_byte(input [DATA_WIDTH-1:0] byte_data);
        begin
            @(posedge i_clk);
            synch_data <= byte_data;
            data_synchronizer_valid <= 1'b1;
            @(posedge i_clk);
            data_synchronizer_valid <= 1'b0;
            synch_data <= '0;
        end
    endtask

    // 5. Test Procedure
    initial begin
        // --- Initialization ---
        i_clk = 0; i_RSTn = 0; i_FIFO_FULL = 0;
        data_synchronizer_valid = 0; synch_data = '0;
        i_alu_done = 0; i_ALU_OUT = '0;
        i_reg_done = 0; i_Rd_D = '0;

        // --- Reset ---
        #(T*2) i_RSTn = 1;
        #(T*2);

        // --- CASE 1: REGISTER WRITE (0xAA) ---
        $display("[TIME: %0t] CASE 1: Triggering Reg Write", $time);
        send_uart_byte(8'hAA); // Command
        wait(o_reg_start);
        #(T*5); // Simulate sub-FSM working
        @(posedge i_clk);
        i_reg_done <= 1;
        @(posedge i_clk);
        i_reg_done <= 0;
        #(T*5);

        // --- CASE 2: REGISTER READ (0xBB) ---
        $display("[TIME: %0t] CASE 2: Triggering Reg Read & Checking Output", $time);
        i_Rd_D <= 8'h55; // Prepare dummy read data
        send_uart_byte(8'hBB); 
        wait(o_reg_start);
        @(posedge i_clk);
        i_reg_done <= 1;
        @(posedge i_clk);
        i_reg_done <= 0;
        
        // FSM should move to SEND_RESULT_1
        wait(o_WR_INC);
        if (o_WR_DATA === 8'h55) 
            $display("[SUCCESS] Reg Read returned correct data: %h", o_WR_DATA);
        #(T*5);

        // --- CASE 3: ALU WITH FETCH (0xCC) ---
        $display("[TIME: %0t] CASE 3: Triggering ALU With Fetch", $time);
        i_ALU_OUT <= 16'hABCD; // Prepare dummy result
        send_uart_byte(8'hCC);
        wait(o_alu_start && o_alu_operands_en);
        #(T*5);
        @(posedge i_clk);
        i_alu_done <= 1;
        @(posedge i_clk);
        i_alu_done <= 0;

        // FSM should send 2 bytes
        wait(o_WR_INC);
        $display("[UART TX] Received ALU Low Byte: %h", o_WR_DATA);
        @(posedge i_clk); 
        wait(o_WR_INC);
        $display("[UART TX] Received ALU High Byte: %h", o_WR_DATA);
        #(T*5);

        // --- CASE 4: ALU WITHOUT FETCH (0xDD) ---
        $display("[TIME: %0t] CASE 4: Triggering ALU Without Fetch", $time);
        send_uart_byte(8'hDD);
        wait(o_alu_start && !o_alu_operands_en); // operands_en should be 0
        @(posedge i_clk);
        i_alu_done <= 1;
        @(posedge i_clk);
        i_alu_done <= 0;
        wait(o_WR_INC); // Check for start of result transmission
        
        #(T*10);
        $display("[TIME: %0t] ALL TOP FSM TESTS COMPLETED", $time);
        $stop;
    end

    // --- Monitoring ---
    always @(posedge i_clk) begin
        if (o_WR_INC) $display(">>> FIFO WRITE: Data=%h", o_WR_DATA);
    end

endmodule