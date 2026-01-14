`timescale 1ns/1ps

module tb_check_modules();

    // Global Signals
    logic clk = 0;
    logic resetn;
    logic sampled_bit;
    
    // Start Check Signals
    logic strt_chk_en;
    logic strt_glitch;
    
    // Stop Check Signals
    logic stp_chk_en;
    logic stp_err;
    
    // Parity Check Signals
    logic par_chk_en;
    logic par_typ;   // 0: Even, 1: Odd
    logic deser_en;
    logic par_err;

    // --- 1. Instantiate Modules ---
    
    strt_check u_strt (
        .i_clk(clk),
        .i_resetn(resetn),
        .i_strt_chk_en(strt_chk_en),
        .i_sampled_bit(sampled_bit),
        .o_strt_glitch(strt_glitch)
    );

    stp_check u_stp (
        .i_clk(clk),
        .i_resetn(resetn),
        .i_stp_chk_en(stp_chk_en),
        .i_sampled_bit(sampled_bit),
        .o_stp_err(stp_err)
    );

    parity_check u_par (
        .i_clk(clk),
        .i_resetn(resetn),
        .i_par_chk_en(par_chk_en),
        .i_par_typ(par_typ),
        .i_deser_en(deser_en),
        .i_sampled_bit(sampled_bit),
        .o_par_err(par_err)
    );

    // Clock Gen
    always #5 clk = ~clk;

    // --- Tasks for Stimulus ---
    
    task automatic reset_system();
        resetn = 0;
        strt_chk_en = 0;
        stp_chk_en = 0;
        par_chk_en = 0;
        deser_en = 0;
        sampled_bit = 1;
        #20 resetn = 1;
        #10;
    endtask

    // Simulates sending data bits to the parity accumulator
    task automatic send_data_payload(input logic [7:0] data);
        for(int i=0; i<8; i++) begin
            sampled_bit = data[i];
            deser_en = 1;
            @(posedge clk);
            deser_en = 0;
        end
    endtask

    // --- Test Scenarios ---
    initial begin
        reset_system();

        // SCENARIO 1: Perfect Frame (Even Parity)
        // Data: 8'b11001101 (Count of 1s = 5). For Even Parity, Parity Bit should be 1.
        $display("Test 1: Normal Frame, Even Parity");
        par_typ = 0; 
        
        // Start Bit (Should be 0)
        sampled_bit = 0; strt_chk_en = 1; @(posedge clk); strt_chk_en = 0;
        
        send_data_payload(8'b11001101);
        
        // Parity Bit (Received 1)
        sampled_bit = 1; par_chk_en = 1; @(posedge clk); par_chk_en = 0;
        
        // Stop Bit (Should be 1)
        sampled_bit = 1; stp_chk_en = 1; @(posedge clk); stp_chk_en = 0;
        
        #5;
        if (!strt_glitch && !par_err && !stp_err) $display("Result: PASS");
        else $display("Result: FAIL - Unexpected Error Flag");

        // SCENARIO 2: Start Glitch & Stop Error
        reset_system();
        $display("Test 2: Start Glitch and Stop Error Detection");
        
        // Start Bit = 1 (Glitch!)
        sampled_bit = 1; strt_chk_en = 1; @(posedge clk); strt_chk_en = 0;
        
        // Stop Bit = 0 (Framing Error!)
        sampled_bit = 0; stp_chk_en = 1; @(posedge clk); stp_chk_en = 0;
        
        #5;
        if (strt_glitch) $display("Result: Start Glitch Detected Correctly");
        if (stp_err)     $display("Result: Stop Error Detected Correctly");

        // SCENARIO 3: Parity Error (Odd Parity)
        // Data: 8'b00000001 (Count = 1). For Odd Parity, Parity Bit should be 0.
        // We will send Parity Bit = 1 to trigger error.
        reset_system();
        $display("Test 3: Odd Parity Error Detection");
        par_typ = 1; 
        
        send_data_payload(8'b00000001);
        
        // Incorrect Parity Bit
        sampled_bit = 1; par_chk_en = 1; @(posedge clk); par_chk_en = 0;
        
        #5;
        if (par_err) $display("Result: Parity Error Detected Correctly");
        else         $display("Result: FAIL - Parity Error Missed");

        #50;
        $finish;
    end

endmodule