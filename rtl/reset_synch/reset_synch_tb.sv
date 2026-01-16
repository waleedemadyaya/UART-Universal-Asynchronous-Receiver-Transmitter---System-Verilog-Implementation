`timescale 1ns/1ps

module RST_SYNC_tb();

    // 1. Signals
    logic i_CLK;
    logic i_RST_n;
    wire  o_SYNC_RST_n;

    // Clock Period (100MHz)
    localparam T = 10;

    // 2. DUT Instantiation
    RST_SYNC DUT (
        .i_CLK       (i_CLK),
        .i_RST_n     (i_RST_n),
        .o_SYNC_RST_n(o_SYNC_RST_n)
    );

    // 3. Clock Generation
    initial i_CLK = 0;
    always #(T/2) i_CLK = ~i_CLK;

    // 4. Test Procedure
    initial begin
        // --- Initialization ---
        i_RST_n = 1'b1;
        
        // --- Test Case 1: Asynchronous Assertion ---
        // Pulling reset low in the middle of a clock cycle
        #(T * 2.3); 
        $display("[TIME: %0t] Asserting Asynchronous Reset (Low)", $time);
        i_RST_n = 1'b0;
        
        // Output should go low immediately (within simulation delta)
        #1; 
        if (o_SYNC_RST_n === 1'b0)
            $display("[PASS] Output asserted asynchronously.");
        else
            $display("[FAIL] Output did not assert immediately!");

        // --- Test Case 2: Synchronous Deassertion ---
        // Release reset and watch it "thaw" through the two-stage flops
        #(T * 2);
        $display("[TIME: %0t] Releasing Reset (High)", $time);
        @(posedge i_CLK);
        i_RST_n <= 1'b1;

        // At the first posedge, r_sync_reg_1 becomes 1, but o_SYNC_RST_n stays 0
        @(posedge i_CLK);
        #1;
        if (o_SYNC_RST_n === 1'b0)
            $display("[PASS] Output stayed low after 1st clock edge.");

        // At the second posedge, r_sync_reg_2 (o_SYNC_RST_n) finally becomes 1
        @(posedge i_CLK);
        #1;
        if (o_SYNC_RST_n === 1'b1)
            $display("[PASS] Output released synchronously after 2nd clock edge.");

        #(T * 5);
        $display("[TIME: %0t] Simulation Finished", $time);
        $stop;
    end

endmodule