`timescale 1ns/1ps
import UART_PACKAGE::*;

module tb_deserializer();

    // Inputs
    logic                   i_clk = 0;
    logic                   i_resetn;
    logic                   i_deser_en;
    logic                   i_sampled_bit;

    // Outputs
    logic [DATA_WIDTH-1:0]  o_P_DATA;

    // Instantiate the Unit Under Test (UUT)
    deserializer uut (
        .i_clk(i_clk),
        .i_resetn(i_resetn),
        .i_deser_en(i_deser_en),
        .i_sampled_bit(i_sampled_bit),
        .o_P_DATA(o_P_DATA)
    );

    // Clock generation (100MHz)
    always #5 i_clk = ~i_clk;

    // --- Task to shift in one bit ---
    task automatic shift_bit(input logic bit_val);
        begin
            @(posedge i_clk);
            i_sampled_bit = bit_val;
            i_deser_en    = 1;      // Enable shifting
            @(posedge i_clk);
            i_deser_en    = 0;      // Disable shifting
            i_sampled_bit = 1'bx;   // Drive to X to ensure timing is correct
        end
    endtask

    // --- Stimulus ---
    initial begin
        // Initialize
        i_resetn      = 0;
        i_deser_en    = 0;
        i_sampled_bit = 0;

        // Reset the system
        #20 i_resetn  = 1;
        #20;

        // Test Case: Receive 8'hD2 (Binary: 1101_0010)
        // Since the serializer is LSB-first, we send: 0 -> 1 -> 0 -> 0 -> 1 -> 0 -> 1 -> 1
        $display("--- Starting Deserializer Test: Sending 0xD2 ---");
        
        shift_bit(1'b0); // LSB (bit 0)
        shift_bit(1'b1); // bit 1
        shift_bit(1'b0); // bit 2
        shift_bit(1'b0); // bit 3
        shift_bit(1'b1); // bit 4
        shift_bit(1'b0); // bit 5
        shift_bit(1'b1); // bit 6
        shift_bit(1'b1); // MSB (bit 7)

        // Check result
        #10;
        if (o_P_DATA === 8'hD2)
            $display("SUCCESS: Received %h", o_P_DATA);
        else
            $display("FAILURE: Received %h (Expected D2)", o_P_DATA);

        // Test Case 2: Verify Reset
        #20 i_resetn = 0;
        #10;
        if (o_P_DATA === 8'h00)
            $display("SUCCESS: Reset cleared data");

        #50;
        $finish;
    end

endmodule