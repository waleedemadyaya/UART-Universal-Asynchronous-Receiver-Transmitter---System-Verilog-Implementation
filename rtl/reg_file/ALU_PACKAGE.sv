package ALU_PACKAGE;
import UART_PACKAGE::*;
        // Function for addition with flags
    function automatic logic [2*DATA_WIDTH-1:0] alu_add (
        input logic [DATA_WIDTH-1:0] a,
        input logic [DATA_WIDTH-1:0] b,
        ref logic cf,    // Carry flag
        ref logic of,    // Overflow flag
        ref logic zf,    // Zero flag
        ref logic ef     // Equal flag (not typically for addition, but we'll compute)
    );
        logic [DATA_WIDTH:0] temp_sum;  // Extra bit for carry
        temp_sum = {1'b0, a} + {1'b0, b};
        
        alu_add = temp_sum[DATA_WIDTH-1:0];  // Lower bits
        cf = temp_sum[DATA_WIDTH];           // Carry flag
        
        // Overflow for signed addition
        of = (a[DATA_WIDTH-1] == b[DATA_WIDTH-1]) && 
             (alu_add[DATA_WIDTH-1] != a[DATA_WIDTH-1]);
        
        // Zero flag
        zf = (alu_add == 0);
        
        // Equal flag (a == b)
        ef = (a == b);
    endfunction
    
    // Function for subtraction with flags
    function automatic logic [2*DATA_WIDTH-1:0] alu_sub (
        input logic [DATA_WIDTH-1:0] a,
        input logic [DATA_WIDTH-1:0] b,
        ref logic cf,    // Borrow flag
        ref logic of,    // Overflow flag
        ref logic zf,    // Zero flag
        ref logic ef     // Equal flag
    );
        logic [DATA_WIDTH:0] temp_diff;
        
        // Perform subtraction: a - b
        temp_diff = {1'b0, a} - {1'b0, b};
        
        alu_sub = temp_diff[DATA_WIDTH-1:0];
        cf = temp_diff[DATA_WIDTH];  // Borrow flag
        
        // Overflow for signed subtraction
        of = (a[DATA_WIDTH-1] != b[DATA_WIDTH-1]) && 
             (alu_sub[DATA_WIDTH-1] != a[DATA_WIDTH-1]);
        
        // Zero flag
        zf = (alu_sub == 0);
        
        // Equal flag (a == b)
        ef = (a == b);
    endfunction
    
    // Function for multiplication with flags
    function automatic logic [2*DATA_WIDTH-1:0] alu_mul (
        input logic [DATA_WIDTH-1:0] a,
        input logic [DATA_WIDTH-1:0] b,
        ref logic cf,    // Not typically used for multiplication
        ref logic of,    // Overflow flag
        ref logic zf,    // Zero flag
        ref logic ef     // Equal flag
    );
        logic [2*DATA_WIDTH-1:0] temp_prod;
        
        // Perform multiplication
        temp_prod = a * b;
        alu_mul = temp_prod;
        
        // Carry flag - typically not used for multiplication
        cf = 1'b0;
        
        // Overflow flag - set if result doesn't fit in lower DATA_WIDTH bits
        // (i.e., upper bits are non-zero for unsigned multiplication)
        of = (temp_prod[2*DATA_WIDTH-1:DATA_WIDTH] != 0);
        
        // Zero flag
        zf = (temp_prod == 0);
        
        // Equal flag
        ef = (a == b);
    endfunction
    
    // Function for division with flags
    function automatic logic [2*DATA_WIDTH-1:0] alu_div (
        input logic [DATA_WIDTH-1:0] a,
        input logic [DATA_WIDTH-1:0] b,
        ref logic cf,    // Division by zero flag
        ref logic of,    // Not typically used
        ref logic zf,    // Zero flag
        ref logic ef     // Equal flag
    );
        // Store quotient in lower bits, remainder in upper bits
        logic [DATA_WIDTH-1:0] quotient, remainder;
        
        if (b == 0) begin
            // Division by zero - return max value
            quotient = {DATA_WIDTH{1'b1}};
            remainder = {DATA_WIDTH{1'b1}};
            cf = 1'b1;  // Set carry/error flag for division by zero
        end else begin
            quotient = a / b;
            remainder = a % b;
            cf = 1'b0;
        end
        
        alu_div = {remainder, quotient};  // Upper bits: remainder, Lower bits: quotient
        
        // Overflow flag - not typically used for division
        of = 1'b0;
        
        // Zero flag (quotient is zero)
        zf = (quotient == 0);
        
        // Equal flag
        ef = (a == b);
    endfunction
    
    // Function for bitwise AND with flags
    function automatic logic [2*DATA_WIDTH-1:0] alu_and (
        input logic [DATA_WIDTH-1:0] a,
        input logic [DATA_WIDTH-1:0] b,
        ref logic cf,    // Not used
        ref logic of,    // Not used
        ref logic zf,    // Zero flag
        ref logic ef     // Equal flag
    );
        logic [DATA_WIDTH-1:0] temp_result;
        
        temp_result = a & b;
        alu_and = {{DATA_WIDTH{1'b0}}, temp_result};  // Zero-extend
        
        // Flags not applicable for logical operations
        cf = 1'b0;
        of = 1'b0;
        zf = (temp_result == 0);
        ef = (a == b);
    endfunction
    
    // Function for bitwise OR with flags
    function automatic logic [2*DATA_WIDTH-1:0] alu_or (
        input logic [DATA_WIDTH-1:0] a,
        input logic [DATA_WIDTH-1:0] b,
        ref logic cf,
        ref logic of,
        ref logic zf,
        ref logic ef
    );
        logic [DATA_WIDTH-1:0] temp_result;
        
        temp_result = a | b;
        alu_or = {{DATA_WIDTH{1'b0}}, temp_result};
        
        cf = 1'b0;
        of = 1'b0;
        zf = (temp_result == 0);
        ef = (a == b);
    endfunction
    
    // Function for bitwise NAND with flags
    function automatic logic [2*DATA_WIDTH-1:0] alu_nand (
        input logic [DATA_WIDTH-1:0] a,
        input logic [DATA_WIDTH-1:0] b,
        ref logic cf,
        ref logic of,
        ref logic zf,
        ref logic ef
    );
        logic [DATA_WIDTH-1:0] temp_result;
        
        temp_result = ~(a & b);
        alu_nand = {{DATA_WIDTH{1'b0}}, temp_result};
        
        cf = 1'b0;
        of = 1'b0;
        zf = (temp_result == 0);
        ef = (a == b);
    endfunction
    
    // Function for bitwise NOR with flags
    function automatic logic [2*DATA_WIDTH-1:0] alu_nor (
        input logic [DATA_WIDTH-1:0] a,
        input logic [DATA_WIDTH-1:0] b,
        ref logic cf,
        ref logic of,
        ref logic zf,
        ref logic ef
    );
        logic [DATA_WIDTH-1:0] temp_result;
        
        temp_result = ~(a | b);
        alu_nor = {{DATA_WIDTH{1'b0}}, temp_result};
        
        cf = 1'b0;
        of = 1'b0;
        zf = (temp_result == 0);
        ef = (a == b);
    endfunction
    
    // Function for bitwise XOR with flags
    function automatic logic [2*DATA_WIDTH-1:0] alu_xor (
        input logic [DATA_WIDTH-1:0] a,
        input logic [DATA_WIDTH-1:0] b,
        ref logic cf,
        ref logic of,
        ref logic zf,
        ref logic ef
    );
        logic [DATA_WIDTH-1:0] temp_result;
        
        temp_result = a ^ b;
        alu_xor = {{DATA_WIDTH{1'b0}}, temp_result};
        
        cf = 1'b0;
        of = 1'b0;
        zf = (temp_result == 0);
        ef = (a == b);
    endfunction
    
    // Function for bitwise XNOR with flags
    function automatic logic [2*DATA_WIDTH-1:0] alu_xnor (
        input logic [DATA_WIDTH-1:0] a,
        input logic [DATA_WIDTH-1:0] b,
        ref logic cf,
        ref logic of,
        ref logic zf,
        ref logic ef
    );
        logic [DATA_WIDTH-1:0] temp_result;
        
        temp_result = ~(a ^ b);
        alu_xnor = {{DATA_WIDTH{1'b0}}, temp_result};
        
        cf = 1'b0;
        of = 1'b0;
        zf = (temp_result == 0);
        ef = (a == b);
    endfunction
    
    // Function for comparison: A = B
    function automatic logic [2*DATA_WIDTH-1:0] alu_cmp_eq (
        input logic [DATA_WIDTH-1:0] a,
        input logic [DATA_WIDTH-1:0] b,
        ref logic cf,    // Not used
        ref logic of,    // Not used
        ref logic zf,    // Not used (use ef instead)
        ref logic ef     // Equal flag
    );
        // Comparison returns 1 if equal, 0 otherwise
        logic equal_result;
        
        equal_result = (a == b) ? 1'b1 : 1'b0;
        alu_cmp_eq = {{2*DATA_WIDTH-1{1'b0}}, equal_result};
        
        cf = 1'b0;
        of = 1'b0;
        zf = 1'b0;  // Not used for comparison
        ef = equal_result;  // This is the comparison result
    endfunction
    
    // Function for comparison: A > B
    function automatic logic [2*DATA_WIDTH-1:0] alu_cmp_gt (
        input logic [DATA_WIDTH-1:0] a,
        input logic [DATA_WIDTH-1:0] b,
        ref logic cf,
        ref logic of,
        ref logic zf,
        ref logic ef
    );
        logic greater_result;
        
        // Unsigned comparison
        greater_result = (a > b) ? 1'b1 : 1'b0;
        alu_cmp_gt = {{2*DATA_WIDTH-1{1'b0}}, greater_result};
        
        cf = 1'b0;
        of = 1'b0;
        zf = 1'b0;
        ef = (a == b);  // Still compute equality
    endfunction
    
    // Function for shift right by 1
    function automatic logic [2*DATA_WIDTH-1:0] alu_shr (
        input logic [DATA_WIDTH-1:0] a,
        input logic [DATA_WIDTH-1:0] b,  // Not used, but kept for interface consistency
        ref logic cf,    // Carry out the shifted bit
        ref logic of,    // Not used
        ref logic zf,    // Zero flag
        ref logic ef     // Equal flag
    );
        logic [DATA_WIDTH-1:0] temp_result;
        
        // Shift right logical
        cf = a[0];  // LSB becomes carry
        temp_result = a >> 1;
        alu_shr = {{DATA_WIDTH{1'b0}}, temp_result};
        
        of = 1'b0;
        zf = (temp_result == 0);
        ef = (a == b);  // Compare with second operand (if needed)
    endfunction
    
    // Function for shift left by 1
    function automatic logic [2*DATA_WIDTH-1:0] alu_shl (
        input logic [DATA_WIDTH-1:0] a,
        input logic [DATA_WIDTH-1:0] b,  // Not used
        ref logic cf,    // Carry out the shifted bit
        ref logic of,    // Overflow flag
        ref logic zf,    // Zero flag
        ref logic ef     // Equal flag
    );
        logic [DATA_WIDTH-1:0] temp_result;
        
        // Shift left logical
        cf = a[DATA_WIDTH-1];  // MSB becomes carry
        temp_result = a << 1;
        alu_shl = {{DATA_WIDTH{1'b0}}, temp_result};
        
        // Overflow if MSB changed (for signed numbers)
        of = a[DATA_WIDTH-1] ^ temp_result[DATA_WIDTH-1];
        zf = (temp_result == 0);
        ef = (a == b);
    endfunction
    
endpackage