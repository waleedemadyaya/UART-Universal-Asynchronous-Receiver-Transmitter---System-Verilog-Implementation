package SYS_PACKAGE;

    // ==========================================
    // 1. SYSTEM CONFIGURATION PARAMETERS
    // ==========================================
    parameter ADDR_WIDTH     = 4;
    parameter DATA_WIDTH     = 8;
    parameter ALU_OUT_WIDTH  = 16;
    parameter ALU_FUN_WIDTH  = 5; // Updated to match SEL_WIDTH
    parameter DIVISION_WIDTH = 8;
    parameter ADDRESS_WIDTH = 4;

    // ==========================================
    // 2. UART CONFIGURATION
    // ==========================================
    parameter MAX_PRESCALE     = 32;
    parameter PRESCALE_WIDTH   = $clog2(MAX_PRESCALE + 1);
    parameter NUM_SAMPLED_BITS = 3;
    parameter BIT_COUNT_WIDTH  = $clog2(DATA_WIDTH + 4); 

    // ==========================================
    // 3. ALU TYPES & ENUMERATIONS
    // ==========================================
    typedef enum logic [ALU_FUN_WIDTH-1:0] {
        ADD  = 5'b0000, SUB  = 5'b0001, MUL  = 5'b0010, DIV  = 5'b0011,
        AND  = 5'b0100, OR   = 5'b0101, NAND = 5'b0110, NOR  = 5'b0111,
        XOR  = 5'b1000, XNOR = 5'b1001, EQUAL= 5'b1010, GT   = 5'b1011,
        LT   = 5'b1100, LSR  = 5'b1101, LSL  = 5'b1110
    } alu_op_t;

    // ==========================================
    // 4. ALU STATIC FUNCTIONS (Optimized)
    // ==========================================
    // Note: Using 16-bit internal logic to prevent overflow before return
    
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

endpackage : SYS_PACKAGE