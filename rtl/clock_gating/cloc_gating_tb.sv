`timescale 1ns/1ps
`define PERIOD 10
module clock_gating_tb();

    logic i_clk_tb;
    logic i_en_tb;
    logic o_clk_tb;

    initial begin
        i_clk_tb = '0;
        i_en_tb = '0;
    end

    initial begin
        forever begin
           #(`PERIOD/2); i_clk_tb = !i_clk_tb; 
        end
    end

    initial begin
        #(2.75*`PERIOD);
        i_en_tb = 1;
        #(10*`PERIOD);
        i_en_tb = 0;
        #(5*`PERIOD);
        i_en_tb = 1;
    end

    clock_gating DUT (
        .i_clk(i_clk_tb),
        .i_en(i_en_tb),
        .o_clk(o_clk_tb)
    );

endmodule: clock_gating_tb