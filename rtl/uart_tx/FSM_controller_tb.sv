`timescale 1ns/1ps

module tb_FSM_controller;
    // ============================================
    // Parameters
    // ============================================
    parameter CLK_PERIOD = 5;        // 200 MHz = 5ns period
    
    // ============================================
    // DUT Signals
    // ============================================
    reg clk;
    reg resetn;
    reg data_valid;
    reg par_en;
    reg ser_done;
    wire ser_en;
    wire latch_en;
    wire [2:0] mux_sel;
    wire busy;
    
    // ============================================
    // Clock Generation
    // ============================================
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // ============================================
    // DUT Instantiation
    // ============================================
    FSM_controller dut (
        .i_clk(clk),
        .i_resetn(resetn),
        .i_Data_Valid(data_valid),
        .i_PAR_EN(par_en),
        .i_ser_done(ser_done),
        .o_ser_en(ser_en),
        .o_latch_en(latch_en),
        .o_mux_sel(mux_sel),
        .o_busy(busy)
    );
    
    // ============================================
    // Test Stimulus
    // ============================================
    initial begin
        // Initialize all signals
        resetn = 1'b0;
        data_valid = 1'b0;
        par_en = 1'b0;
        ser_done = 1'b0;
        
        // Apply reset
        #100;
        resetn = 1'b1;
        #50;
        
        // Test Case 1: Simple transmission without parity
        $display("Time=%0t: Starting Test 1 - No Parity Transmission", $time);
        data_valid = 1'b1;
        #5;
        data_valid = 1'b0;
        
        // Wait for FSM to enter START state
        #20;
        
        // Generate ser_done pulses for 8 data bits
        repeat(8) begin
            #40 ser_done = 1'b1;
            #5 ser_done = 1'b0;
            #35;
        end
        
        // Wait for transmission to complete
        #200;
        
        // Test Case 2: Transmission with parity enabled
        $display("Time=%0t: Starting Test 2 - With Parity Transmission", $time);
        par_en = 1'b1;
        #50;
        data_valid = 1'b1;
        #5;
        data_valid = 1'b0;
        
        // Generate ser_done pulses for 8 data bits + parity
        repeat(9) begin
            #40 ser_done = 1'b1;
            #5 ser_done = 1'b0;
            #35;
        end
        
        #200;
        
        // Test Case 3: Try data_valid during busy state
        $display("Time=%0t: Starting Test 3 - Data Valid During Busy", $time);
        par_en = 1'b0;
        #50;
        data_valid = 1'b1;
        #5;
        data_valid = 1'b0;
        
        // Generate a few ser_done pulses
        repeat(3) begin
            #40 ser_done = 1'b1;
            #5 ser_done = 1'b0;
            #35;
        end
        
        // Try to send new data while busy (should be ignored)
        data_valid = 1'b1;
        #5;
        data_valid = 1'b0;
        
        // Complete the transmission
        repeat(6) begin
            #40 ser_done = 1'b1;
            #5 ser_done = 1'b0;
            #35;
        end
        
        #200;
        
        // Test Case 4: Back-to-back transmissions
        $display("Time=%0t: Starting Test 4 - Back-to-back Transmissions", $time);
        
        // First transmission
        data_valid = 1'b1;
        #5;
        data_valid = 1'b0;
        
        // Generate ser_done pulses
        repeat(10) begin
            #40 ser_done = 1'b1;
            #5 ser_done = 1'b0;
            #35;
        end
        
        // Small gap
        #100;
        
        // Second transmission
        data_valid = 1'b1;
        #5;
        data_valid = 1'b0;
        
        // Generate ser_done pulses
        repeat(10) begin
            #40 ser_done = 1'b1;
            #5 ser_done = 1'b0;
            #35;
        end
        
        #200;
        
        // Test Case 5: Parity enable toggle
        $display("Time=%0t: Starting Test 5 - Parity Toggle", $time);
        
        // With parity
        par_en = 1'b1;
        #50;
        data_valid = 1'b1;
        #5;
        data_valid = 1'b0;
        
        repeat(9) begin
            #40 ser_done = 1'b1;
            #5 ser_done = 1'b0;
            #35;
        end
        
        #200;
        
        // Without parity
        par_en = 1'b0;
        #50;
        data_valid = 1'b1;
        #5;
        data_valid = 1'b0;
        
        repeat(8) begin
            #40 ser_done = 1'b1;
            #5 ser_done = 1'b0;
            #35;
        end
        
        #200;
        
        // Test Case 6: Reset during transmission
        $display("Time=%0t: Starting Test 6 - Reset During Transmission", $time);
        data_valid = 1'b1;
        #5;
        data_valid = 1'b0;
        
        // Start transmission
        #40 ser_done = 1'b1;
        #5 ser_done = 1'b0;
        #35;
        
        // Apply reset during transmission
        resetn = 1'b0;
        #50;
        resetn = 1'b1;
        #50;
        
        // Try to continue (should be in IDLE)
        repeat(3) begin
            #40 ser_done = 1'b1;
            #5 ser_done = 1'b0;
            #35;
        end
        
        #200;
        
        // Test Case 7: Continuous ser_done pulses (testing robustness)
        $display("Time=%0t: Starting Test 7 - Continuous Stimulus", $time);
        
        // Start transmission
        data_valid = 1'b1;
        #5;
        data_valid = 1'b0;
        
        // Continuous ser_done pulses
        repeat(20) begin
            #30 ser_done = 1'b1;
            #5 ser_done = 1'b0;
            #25;
        end
        
        #200;
        
        // Keep simulation running indefinitely
        $display("Time=%0t: All stimulus applied, simulation continues...", $time);
        forever #1000;
    end
    
    // ============================================
    // Monitoring
    // ============================================
    initial begin
        // Wait for reset to complete
        #150;
        
        $display("\n=================================================================");
        $display("Time(ns) | DV | Par | Busy | Latch | SerEn | MuxSel");
        $display("=================================================================");
        
        forever begin
            @(posedge clk);
            $display("%8t | %b  | %b   | %b    | %b     | %b     | %b",
                     $time,
                     data_valid,
                     par_en,
                     busy,
                     latch_en,
                     ser_en,
                     mux_sel);
        end
    end
    
    // ============================================
    // Waveform Dumping
    // ============================================
    initial begin
        $dumpfile("fsm_controller_waves.vcd");
        $dumpvars(0, tb_FSM_controller);
    end
    
    // ============================================
    // Simulation Control
    // ============================================
    // Run simulation for a long time (10ms)
    initial begin
        #10000000;
        $display("\nTime=%0t: Simulation completed", $time);
        $finish;
    end
    
endmodule