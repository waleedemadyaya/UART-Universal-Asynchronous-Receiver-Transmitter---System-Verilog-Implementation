package UART_PACKAGE; 

    parameter DATA_WIDTH = 8;
    parameter ADDRESS_WIDTH = 4;
    parameter ALU_FUN_WIDTH = 4;

    typedef enum logic [3:0] {
        OP_ADD     = 4'b0000,  // Addition
        OP_SUB     = 4'b0001,  // Subtraction
        OP_MUL     = 4'b0010,  // Multiplication
        OP_DIV     = 4'b0011,  // Division
        OP_AND     = 4'b0100,  // AND
        OP_OR      = 4'b0101,  // OR
        OP_NAND    = 4'b0110,  // NAND
        OP_NOR     = 4'b0111,  // NOR
        OP_XOR     = 4'b1000,  // XOR
        OP_XNOR    = 4'b1001,  // XNOR
        OP_CMP_EQ  = 4'b1010,  // Compare: A = B
        OP_CMP_GT  = 4'b1011,  // Compare: A > B
        OP_SHR     = 4'b1100,  // Shift Right by 1
        OP_SHL     = 4'b1101,  // Shift Left by 1
        OP_NOP     = 4'b1110,  // No Operation (Optional)
        OP_INVALID = 4'b1111   // Invalid/Reserved
    } opcode_t;
    

    // Define initial values as parameters
    //parameter logic [DATA_WIDTH-1:0] INIT_VALUES [ADDRESS_WIDTH-1:0] = '{
    //    8'h00,  // addr 0
    //    8'h00,  // addr 1
    //    8'h81,  // addr 2 = 1000_0001 in hex
    //    8'h20,  // addr 3 = 0010_0000 in hex
    //    default: 8'h00  // rest are zeros
    //};
endpackage : UART_PACKAGE 