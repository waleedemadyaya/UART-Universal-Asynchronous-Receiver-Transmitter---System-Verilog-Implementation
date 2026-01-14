`timescale 1ns/1ps
import UART_PACKAGE::*;

module tb_edge_bit_counter;

    // -----------------------------
    // Testbench signals
    // -----------------------------
    logic i_clk;
    logic i_resetn;
    logic i_enable;
    logic [PRESCALE_WIDTH - 1:0] i_prescale;

    logic [$clog2(DATA_WIDTH)-1:0] o_bit_cnt;
    logic [PRESCALE_WIDTH - 1:0]     o_edge_cnt;

    // -----------------------------
    // DUT instantiation
    // -----------------------------
    edge_bit_counter dut (
        .i_clk      (i_clk),
        .i_resetn   (i_resetn),
        .i_enable   (i_enable),
        .i_prescale (i_prescale),
        .o_bit_cnt  (o_bit_cnt),
        .o_edge_cnt (o_edge_cnt)
    );

    // -----------------------------
    // Clock generation (100 MHz)
    // -----------------------------
    always #5 i_clk = ~i_clk;

    // -----------------------------
    // Stimulus
    // -----------------------------
    initial begin
        // Initial values
        i_clk      = 0;
        i_resetn  = 0;
        i_enable  = 0;
        i_prescale = 4;   // example prescale

        // Apply reset
        #20;
        i_resetn = 1;

        // Enable counter
        #10;
        i_enable = 1;

        // Let it run
        #200;

        // Change prescale
        i_prescale = 2;
        #100;

        // Disable counting
        i_enable = 0;
        #50;

        // Re-enable
        i_enable = 1;
        #100;

        $stop;
    end

    // -----------------------------
    // Monitor (optional but useful)
    // -----------------------------
    initial begin
        $monitor(
            "T=%0t | enable=%b prescale=%0d | edge_cnt=%0d bit_cnt=%0d",
            $time, i_enable, i_prescale, o_edge_cnt, o_bit_cnt
        );
    end

endmodule
