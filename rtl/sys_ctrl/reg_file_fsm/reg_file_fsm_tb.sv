`timescale 1ns/1ps

module reg_file_fsm_tb();

    // 1. Parameters and Signals
    parameter ADDRESS_WIDTH = 4;
    parameter WRDATA_WIDTH  = 8;
    localparam T = 10; 

    logic                      i_clk;
    logic                      i_RSTn;
    logic                      i_reg_start;            
    logic                      data_synchronizer_valid;
    logic [WRDATA_WIDTH-1 : 0] synch_data;
    logic                      i_rw_en;
    logic                      i_alu_fetch_en;

    wire                       o_WrEn;
    wire                       o_RdEn;
    wire [ADDRESS_WIDTH-1 : 0] o_Addr;
    wire [WRDATA_WIDTH-1 : 0]  o_Wr_D;
    wire                       o_reg_done;

    // 2. DUT Instantiation
    reg_file_fsm #(
        .ADDRESS_WIDTH(ADDRESS_WIDTH),
        .WRDATA_WIDTH(WRDATA_WIDTH)
    ) DUT (.*);

    // 3. Clock Generation
    always #(T/2) i_clk = ~i_clk;

    // 4. Helper Task to simulate UART/DataSync pulses
    task send_pulse(input [WRDATA_WIDTH-1:0] data);
        begin
            @(posedge i_clk);
            synch_data <= data;
            data_synchronizer_valid <= 1'b1;
            @(posedge i_clk);
            data_synchronizer_valid <= 1'b0;
            synch_data <= '0;
        end
    endtask

    // 5. Test Procedure
    initial begin
        // --- Initialization ---
        i_clk = 0; i_RSTn = 0; i_reg_start = 0;
        data_synchronizer_valid = 0; synch_data = '0; 
        i_rw_en = 0; i_alu_fetch_en = 0;

        // --- Reset ---
        #(T*2) i_RSTn = 1;
        #(T*2);

        // --- TEST CASE 1: MANUAL WRITE (Addr: 0x5, Data: 0xAA) ---
        $display("[TIME: %0t] CASE 1: Manual Write", $time);
        @(posedge i_clk);
        i_reg_start <= 1; i_rw_en <= 1; i_alu_fetch_en <= 0;
        @(posedge i_clk);
        i_reg_start <= 0;
        
        send_pulse(8'h05); // Address
        #(T);
        send_pulse(8'hAA); // Data
        wait(o_reg_done);
        #(T*2);

        // --- TEST CASE 2: MANUAL READ (Addr: 0x5) ---
        $display("[TIME: %0t] CASE 2: Manual Read", $time);
        @(posedge i_clk);
        i_reg_start <= 1; i_rw_en <= 0; i_alu_fetch_en <= 0;
        @(posedge i_clk);
        i_reg_start <= 0;

        send_pulse(8'h05); // Address
        wait(o_reg_done);
        #(T*2);

        // --- TEST CASE 3: ALU AUTO-FETCH (OpA -> Addr 0, OpB -> Addr 1) ---
        $display("[TIME: %0t] CASE 3: ALU Auto-Fetch (Sequential Writes)", $time);
        @(posedge i_clk);
        i_reg_start    <= 1; 
        i_alu_fetch_en <= 1; // Trigged by ALU FSM o_read_operands
        @(posedge i_clk);
        i_reg_start    <= 0;

        // Simulate first pulse (Operand A = 0x11)
        send_pulse(8'h11); 
        // Monitor will check if o_WrEn pulses and o_Addr is 0
        
        #(T*3); // Some idle time between pulses

        // Simulate second pulse (Operand B = 0x22)
        send_pulse(8'h22);
        // Monitor will check if o_WrEn pulses and o_Addr is 1

        wait(o_reg_done);
        
        #(T*10);
        $display("[TIME: %0t] ALL TESTS COMPLETED", $time);
        $stop;
    end

    // --- Monitor for Verification ---
    always @(posedge i_clk) begin
        if (o_WrEn) begin
            $display("[STROBE] Write Enable High! Addr: %h, Data: %h", o_Addr, o_Wr_D);
        end
        if (o_RdEn) begin
            $display("[STROBE] Read Enable High!  Addr: %h", o_Addr);
        end
    end

endmodule