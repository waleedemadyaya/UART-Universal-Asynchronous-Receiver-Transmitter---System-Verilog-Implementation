package alu_package;
    // ALU Operation Enums - Must be 4 bits as per SYS_CTRL spec [cite: 349, 364]
    typedef enum logic [3:0] {
        ADD  = 4'b0000, SUB  = 4'b0001, MUL  = 4'b0010, DIV  = 4'b0011,
        AND  = 4'b0100, OR   = 4'b0101, NAND = 4'b0110, NOR  = 4'b0111,
        XOR  = 4'b1000, XNOR = 4'b1001, EQUAL= 4'b1010, GT   = 4'b1011,
        LT   = 4'b1100, LSR  = 4'b1101, LSL  = 4'b1110
    } alu_op_e;

    // Functions for ALU logic
    function [15:0] add_funct(input [7:0] a, b); return a + b; endfunction
    function [15:0] sub_funct(input [7:0] a, b); return a - b; endfunction
    function [15:0] mul_funct(input [7:0] a, b); return a * b; endfunction
    function [15:0] div_funct(input [7:0] a, b); return a / b; endfunction
    function [15:0] and_funct(input [7:0] a, b); return a & b; endfunction
    function [15:0] or_funct (input [7:0] a, b); return a | b; endfunction
    function [15:0] nand_funct(input [7:0] a, b); return ~(a & b); endfunction
    function [15:0] nor_funct (input [7:0] a, b); return ~(a | b); endfunction
    function [15:0] xor_funct(input [7:0] a, b); return a ^ b; endfunction
    function [15:0] xnor_funct(input [7:0] a, b); return ~(a ^ b); endfunction
    function [15:0] equal_funct(input [7:0] a, b); return (a == b); endfunction
    function [15:0] gt_funct(input [7:0] a, b); return (a > b) ? 16'd2 : 16'd0; endfunction
    function [15:0] lt_funct(input [7:0] a, b); return (a < b) ? 16'd3 : 16'd0; endfunction
    function [15:0] lsr_funct(input [7:0] a, b); return a >> 1; endfunction
    function [15:0] lsl_funct(input [7:0] a, b); return a << 1; endfunction
endpackage