`timescale 1ns/1ps
import UART_PACKAGE::*;

module tb_data_sampling;

    // -------------------------
    // Testbench signals
    // -------------------------
    logic i_clk;
    logic i_resetn;
    logic i_data_samp_en;
    logic i_RX_IN;
    logic [PRESCALE_WIDTH-1:0] i_prescale;
    logic [PRESCALE_WIDTH-1:0] i_edge_cnt;

    logic o_sampled_bit;

    // -------------------------
    // DUT
    // -------------------------
    data_sampling dut (
        .i_clk         (i_clk),
        .i_resetn      (i_resetn),
        .i_prescale    (i_prescale),
        .i_data_samp_en(i_data_samp_en),
        .i_edge_cnt    (i_edge_cnt),
        .i_RX_IN       (i_RX_IN),
        .o_sampled_bit (o_sampled_bit)
    );

    // -------------------------
    // Clock (50 MHz)
    // -------------------------
    always #10 i_clk = ~i_clk;

    // -------------------------
    // Stimulus
    // -------------------------
    initial begin
        // Init
        i_clk          = 0;
        i_resetn       = 0;
        i_data_samp_en = 0;
        i_RX_IN        = 1;
        i_prescale     = 8;   // oversampling example
        i_edge_cnt     = 0;

        // Reset
        #40;
        i_resetn = 1;

        // Enable sampling
        i_data_samp_en = 1;

        // Simulate one bit time
        repeat (i_prescale) begin
            @(posedge i_clk);

            // Drive RX value around center
            if (i_edge_cnt == 3) i_RX_IN = 1;
            if (i_edge_cnt == 4) i_RX_IN = 1;
            if (i_edge_cnt == 5) i_RX_IN = 0;

            i_edge_cnt++;
        end

        // Hold
        #50;

        // Change RX pattern (majority 0)
        i_edge_cnt = 0;
        i_RX_IN = 0;

        repeat (i_prescale) begin
            @(posedge i_clk);

            if (i_edge_cnt == 3) i_RX_IN = 0;
            if (i_edge_cnt == 4) i_RX_IN = 1;
            if (i_edge_cnt == 5) i_RX_IN = 0;

            i_edge_cnt++;
        end

        #50;
        $stop;
    end

    // -------------------------
    // Monitor
    // -------------------------
    initial begin
        $monitor("T=%0t edge=%0d RX=%b sampled=%b",
                 $time, i_edge_cnt, i_RX_IN, o_sampled_bit);
    end

endmodule
