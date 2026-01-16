`timescale 1ns/1ps

module PULSE_GEN_tb();

    // 1. Signals
    logic i_CLK;
    logic i_RST_n;
    logic i_LVL_SIG;
    wire  o_PULSE_SIG;

    // Clock Period (100MHz)
    localparam T = 10;

    // 2. DUT Instantiation
    PULSE_GEN DUT (
        .i_CLK      (i_CLK),
        .i_RST_n    (i_RST_n),
        .i_LVL_SIG  (i_LVL_SIG),
        .o_PULSE_SIG(o_PULSE_SIG)
    );

    // 3. Clock Generation
    always #(T/2) i_CLK = ~i_CLK;

    // 4. Test Procedure
    initial begin
        // --- Initialization ---
        i_CLK     = 0;
        i_RST_n   = 0;
        i_LVL_SIG = 0;

        // --- Reset Phase ---
        #(T*2) i_RST_n = 1;
        #(T);

        // --- Test Case 1: Positive Edge Detection ---
        $display("[TIME: %0t] Applying Level Signal", $time);
        @(posedge i_CLK);
        i_LVL_SIG <= 1;   // Level signal stays high
        
        // Wait 5 cycles - o_PULSE_SIG should only be high for the first cycle
        repeat(5) @(posedge i_CLK);
        i_LVL_SIG <= 0;
        
        #(T*2);

        // --- Test Case 2: Short Pulse (Glitch) ---
        // Even if LVL_SIG is high for only one cycle, a pulse should occur
        $display("[TIME: %0t] Applying Single Cycle Level", $time);
        @(posedge i_CLK);
        i_LVL_SIG <= 1;
        @(posedge i_CLK);
        i_LVL_SIG <= 0;

        #(T*5);

        // --- Test Case 3: Multiple Level Transitions ---
        $display("[TIME: %0t] Applying Rapid Transitions", $time);
        repeat(3) begin
            @(posedge i_CLK);
            i_LVL_SIG <= 1;
            repeat(2) @(posedge i_CLK);
            i_LVL_SIG <= 0;
            repeat(2) @(posedge i_CLK);
        end

        $display("[TIME: %0t] Simulation Finished", $time);
        $stop;
    end

endmodule