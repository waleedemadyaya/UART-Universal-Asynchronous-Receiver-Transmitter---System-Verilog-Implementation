import UART_PACKAGE::*;
import ALU_PACKAGE::*;

module ALU (
    input i_CLK,
    input i_RSTn,
    input [ALU_FUN_WIDTH-1:0] i_ALU_FUN,
    input [DATA_WIDTH-1:0] i_A,
    input [DATA_WIDTH-1:0] i_B,
    input i_Enable,

    output logic [2*DATA_WIDTH-1:0] o_ALU_OUT,
    output logic o_CF,   // carry flage
    output logic o_OF,   // overflow flage
    output logic o_EF,   //equal flage
    output logic o_ZF,   //zero flage
    output logic o_OUT_VALID

);
    opcode_t op;
    assign op = opcode_t'(i_ALU_FUN);  // Cast to enum type

    always_ff @( posedge i_CLK, negedge i_RSTn ) begin : pb_ALU
        if (!i_RSTn) begin
            o_ALU_OUT <= 'b0;
            o_OUT_VALID <= 'b0;
        end else begin
            o_OUT_VALID <= 'b1;
            case (op)
                OP_ADD:   o_ALU_OUT = alu_add(i_A, i_B, o_CF, o_OF, o_ZF, o_EF);
                OP_SUB:   o_ALU_OUT = alu_sub(i_A, i_B, o_CF, o_OF, o_ZF, o_EF);
                OP_MUL:   o_ALU_OUT = alu_mul(i_A, i_B, o_CF, o_OF, o_ZF, o_EF);
                OP_DIV:   o_ALU_OUT = alu_div(i_A, i_B, o_CF, o_OF, o_ZF, o_EF);
                OP_AND:   o_ALU_OUT = alu_and(i_A, i_B, o_CF, o_OF, o_ZF, o_EF);
                OP_OR:    o_ALU_OUT = alu_or(i_A, i_B, o_CF, o_OF, o_ZF, o_EF);
                OP_NAND:  o_ALU_OUT = alu_nand(i_A, i_B, o_CF, o_OF, o_ZF, o_EF);
                OP_NOR:   o_ALU_OUT = alu_nor(i_A, i_B, o_CF, o_OF, o_ZF, o_EF);
                OP_XOR:   o_ALU_OUT = alu_xor(i_A, i_B, o_CF, o_OF, o_ZF, o_EF);
                OP_XNOR:  o_ALU_OUT = alu_xnor(i_A, i_B, o_CF, o_OF, o_ZF, o_EF);
                OP_CMP_EQ: o_ALU_OUT = alu_cmp_eq(i_A, i_B, o_CF, o_OF, o_ZF, o_EF);
                OP_CMP_GT: o_ALU_OUT = alu_cmp_gt(i_A, i_B, o_CF, o_OF, o_ZF, o_EF);
                OP_SHR:   o_ALU_OUT = alu_shr(i_A, i_B, o_CF, o_OF, o_ZF, o_EF);
                OP_SHL:   o_ALU_OUT = alu_shl(i_A, i_B, o_CF, o_OF, o_ZF, o_EF);
                default: begin
                    o_ALU_OUT = '0;
                    o_CF = 1'b0;
                    o_OF = 1'b0;
                    o_ZF = 1'b0;
                    o_EF = 1'b0;
                    o_OUT_VALID <= 'b0;
                end
            endcase
        end
    end

endmodule