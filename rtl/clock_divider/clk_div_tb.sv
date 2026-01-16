`timescale 1ns/1ps

module clk_div_tb();

    // 1. Parameters and Signals
    parameter WIDTH = 8;
    parameter T = 10; // 100MHz reference clock

    logic             i_ref_clk;
    logic             i_rst_n;
    logic             i_clk_en;
    logic [WIDTH-1:0] i_div_ratio;
    wire              o_div_clk;

    // 2. DUT Instantiation
    clk_div #(.DIVISION_RATION_WIDTH(WIDTH)) DUT (
        .i_ref_clk   (i_ref_clk),
        .i_rst_n     (i_rst_n),
        .i_clk_en     (i_clk_en),
        .i_div_ratio (i_div_ratio),
        .o_div_clk   (o_div_clk)
    );

    // 3. Clock Generation
    always #(T/2) i_ref_clk = ~i_ref_clk;

    // 4. Test Procedure
    initial begin
        // --- Initialize ---
        i_ref_clk   = 0;
        i_rst_n     = 0;
        i_clk_en    = 0;
        i_div_ratio = 0;

        // --- Reset Phase ---
        #(T*2) i_rst_n = 1;
        
        // --- Test Case 1: Divide by 4 ---
        $display("[TIME: %0t] Starting Divide by 4 Test", $time);
        i_div_ratio = 8'd4;
        i_clk_en    = 1;
        #(T*20); // Observe several cycles

        // --- Test Case 2: Disable Clock ---
        $display("[TIME: %0t] Disabling Clock", $time);
        i_clk_en    = 0;
        #(T*10);

        // --- Test Case 3: Divide by 10 ---
        $display("[TIME: %0t] Starting Divide by 10 Test", $time);
        i_div_ratio = 8'd10;
        i_clk_en    = 1;
        #(T*50);

        // --- Test Case 4: Reset during operation ---
        $display("[TIME: %0t] Testing Async Reset", $time);
        #(T*5) i_rst_n = 0;
        #(T*5) i_rst_n = 1;
        #(T*20);

        $display("[TIME: %0t] Simulation Finished", $time);
        $stop;
    end

endmodule