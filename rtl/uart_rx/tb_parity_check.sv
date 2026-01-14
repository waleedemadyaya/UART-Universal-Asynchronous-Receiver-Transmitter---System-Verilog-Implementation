`timescale 1ns/1ps

module parity_check_tb();

    // 1. Signals
    logic i_clk;
    logic i_resetn;
    logic i_par_chk_en;
    logic i_stp_chk_en;
    logic i_par_typ;
    logic i_sampled_bit;
    logic o_par_err;

    // 2. DUT Instantiation
    parity_check dut (.*); // Using .* for shorthand connection

    // 3. Clock Generation (100MHz)
    always #5 i_clk = (i_clk === 1'b0);

    // Task to send a serial byte and a parity bit
    task send_frame(input logic [7:0] data, input logic par_type);
        begin
            i_par_typ = par_type;
            $display("--- Sending Data: %b (Type: %s) ---", data, par_type ? "Odd" : "Even");
            
            // Step A: Accumulate 8 bits of data
            for (int i = 0; i < 8; i++) begin
                @(negedge i_clk);
                i_par_chk_en = 1;
                i_sampled_bit = data[i];
            end
            
            // Step B: Send the Parity Bit (Check phase)
            // In your logic, the error is checked while i_par_chk_en is high
            @(negedge i_clk);
            if (par_type == 0) i_sampled_bit = ^data;    // Correct Even Parity
            else               i_sampled_bit = ~(^data); // Correct Odd Parity
            
            // Let the DUT evaluate the parity bit
            @(posedge i_clk);
            #1; // Small delay to observe result after clock edge
            if (o_par_err) $display("Result: FAIL - Error detected");
            else           $display("Result: PASS - No error");

            // Step C: Reset Accumulator for next frame
            @(negedge i_clk);
            i_par_chk_en = 0;
            i_stp_chk_en = 1;
            @(negedge i_clk);
            i_stp_chk_en = 0;
        end
    endtask

    // 4. Test Procedure
    initial begin
        // Initialize
        i_clk = 0;
        i_resetn = 0;
        i_par_chk_en = 0;
        i_stp_chk_en = 0;
        i_sampled_bit = 0;
        i_par_typ = 0;

        #20 i_resetn = 1;

        // Case 1: Even Parity - Valid Frame
        // Data 10101010 has 4 ones (Even). Even parity bit should be 0.
        send_frame(8'b10101010, 0);

        // Case 2: Even Parity - Invalid Frame (Inject Error)
        $display("Checking Forced Error...");
        send_frame(8'b11110000, 0); // Correct par is 0, we will send 1 inside task if modified
        // Manual override for error injection:
        @(negedge i_clk);
        i_par_chk_en = 1; i_sampled_bit = 1; // Wrong parity bit
        @(posedge i_clk); #1;
        if (o_par_err) $display("SUCCESS: Error detected as expected.");

        // Case 3: Odd Parity - Valid Frame
        // Data 11100000 has 3 ones (Odd). Odd parity bit should be 0.
        send_frame(8'b11100000, 1);

        #50;
        $display("Tests Completed.");
        $stop;
    end

endmodule