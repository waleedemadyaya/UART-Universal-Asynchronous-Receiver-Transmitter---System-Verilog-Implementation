`timescale 1ns/1ps

module tb_strt_check();

    // 1. Declare signals for the DUT (Device Under Test)
    logic i_clk;
    logic i_resetn;
    logic i_strt_chk_en;
    logic i_sampled_bit;
    logic o_strt_glitch;

    // 2. Instantiate the DUT
    strt_check dut (
        .i_clk(i_clk),
        .i_resetn(i_resetn),
        .i_strt_chk_en(i_strt_chk_en),
        .i_sampled_bit(i_sampled_bit),
        .o_strt_glitch(o_strt_glitch)
    );

    // 3. Clock Generation (100MHz)
    always #5 i_clk = ~i_clk;

    // 4. Test Stimulus
    initial begin
        // Initialize signals
        i_clk = 0;
        i_resetn = 0;
        i_strt_chk_en = 0;
        i_sampled_bit = 0;

        // --- Case 1: Apply Reset ---
        $display("Time: %0t | Case 1: Applying Reset", $time);
        #15 i_resetn = 1; // Release reset after 1.5 clock cycles
        
        // --- Case 2: Enable LOW, Random Data ---
        // Result: Glitch should stay 0 regardless of data
        $display("Time: %0t | Case 2: Enable LOW, Random Data", $time);
        repeat(5) begin
            @(negedge i_clk);
            i_strt_chk_en = 0;
            i_sampled_bit = $random;
        end

        // --- Case 3: Enable HIGH, Random Data ---
        // Result: Glitch should follow sampled_bit (1 = glitch, 0 = valid)
        $display("Time: %0t | Case 3: Enable HIGH, Random Data", $time);
        @(negedge i_clk);
        i_strt_chk_en = 1;
        
        repeat(5) begin
            i_sampled_bit = $random; 
            @(negedge i_clk);
            #1; // Wait for non-blocking assignment to update
            if (i_sampled_bit && !o_strt_glitch) 
                $display("Error: Glitch not detected!");
        end

        // --- Case 4: Edge Case - Recovery ---
        // Verify that after a glitch (1), if enable goes low, the glitch flag stays/resets
        $display("Time: %0t | Case 4: Checking Flag Persistence", $time);
        i_sampled_bit = 1; // Force a glitch
        i_strt_chk_en = 1;
        @(negedge i_clk);
        i_strt_chk_en = 0; // Disable check
        i_sampled_bit = 0; // Data goes back to 0
        @(negedge i_clk);
        // Note: In your current module, o_strt_glitch will HOLD its last value 
        // until i_strt_chk_en is high again or reset is toggled.

        #20;
        $display("Simulation Finished!");
        $stop;
    end

    // Optional: Monitor changes in the console
    initial begin
        $monitor("Time: %0t | En: %b | Sampled: %b | Glitch: %b", 
                 $time, i_strt_chk_en, i_sampled_bit, o_strt_glitch);
    end

endmodule