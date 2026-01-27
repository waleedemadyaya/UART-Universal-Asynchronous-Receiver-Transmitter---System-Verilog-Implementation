`timescale 1ns/1ps
import alu_package::*;

module tb_ALU;
    logic clk, rst, enable, out_valid;
    logic [7:0] a, b;
    logic [3:0] alu_fun;
    logic [15:0] alu_out;

    // Instantiate DUT using implicit port mapping
    ALU dut (
        .CLK(clk), .RST(rst), .A(a), .B(b), 
        .ALU_FUN(alu_fun), .Enable(enable), 
        .ALU_OUT(alu_out), .OUT_VALID(out_valid)
    );

    // Clock generation: REF_CLK is 50 MHz (20ns period) [cite: 221]
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Corrected task definition with 'input' keywords
    task automatic apply_op(input alu_op_e op, input [7:0] op_a, input [7:0] op_b);
        @(negedge clk);
        a = op_a; b = op_b; alu_fun = op; enable = 1'b1;
        @(posedge clk);
        #1; // Wait for output stability
        $display("Time: %t | Op: %s | A: %d B: %d | Result: %d", $time, op.name(), a, b, alu_out);
        enable = 1'b0;
    endtask

    initial begin
        // Reset sequence (Active Low) [cite: 331]
        rst = 0; #25; rst = 1;
        
        // Initial configuration: RegFile addresses 0x2, 0x3 [cite: 221]
        $display("Starting ALU Operation Tests...");
        
        apply_op(ADD,  8'd15, 8'd10);
        apply_op(MUL,  8'd5,  8'd4);
        apply_op(NAND, 8'hAA, 8'h55);
        apply_op(GT,   8'd20, 8'd10);
        
        #100;
        $finish;
    end
endmodule