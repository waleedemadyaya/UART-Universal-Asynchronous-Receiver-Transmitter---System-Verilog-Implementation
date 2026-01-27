import SYS_PACKAGE::*;

module ALU #(
    parameter A_WIDTH = 8,
    parameter B_WIDTH = 8,
    parameter OUT_WIDTH = 16 // Set to 16 for ALU result [cite: 364]
)(
    input  logic                 i_CLK,       // From i_CLK_GATE [cite: 330]
    input  logic                 i_RSTn,       // From i_RST_SYNC [cite: 331]
    input  logic [A_WIDTH-1:0]   i_A,         // From RegFile REG0 [cite: 304, 323]
    input  logic [B_WIDTH-1:0]   i_B,         // From RegFile REG1 [cite: 306, 324]
    input  logic [ALU_FUN_WIDTH-1:0]           i_ALU_FUN,   // From SYS_CTRL [cite: 326, 349]
    input  logic                 i_Enable,    // From SYS_CTRL [cite: 328, 347]
    output logic [OUT_WIDTH-1:0] o_ALU_OUT,   // To SYS_CTRL [cite: 325, 346]
    output logic                 o_OUT_VALID  // To SYS_CTRL [cite: 329, 348]
);

    always_ff @(posedge i_CLK or negedge i_RSTn) begin
        if (!i_RSTn) begin
            o_ALU_OUT   <= '0;
            o_OUT_VALID <= 1'b0;
        end else if (i_Enable) begin
            o_OUT_VALID <= 1'b1;
            case (i_ALU_FUN)
                ADD:   o_ALU_OUT <= add_funct(i_A, i_B);
                SUB:   o_ALU_OUT <= sub_funct(i_A, i_B);
                MUL:   o_ALU_OUT <= mul_funct(i_A, i_B);
                DIV:   o_ALU_OUT <= div_funct(i_A, i_B);
                AND:   o_ALU_OUT <= and_funct(i_A, i_B);
                OR:    o_ALU_OUT <= or_funct(i_A, i_B);
                NAND:  o_ALU_OUT <= nand_funct(i_A, i_B);
                NOR:   o_ALU_OUT <= nor_funct(i_A, i_B);
                XOR:   o_ALU_OUT <= xor_funct(i_A, i_B);
                XNOR:  o_ALU_OUT <= xnor_funct(i_A, i_B);
                EQUAL: o_ALU_OUT <= equal_funct(i_A, i_B);
                GT:    o_ALU_OUT <= gt_funct(i_A, i_B);
                LT:    o_ALU_OUT <= lt_funct(i_A, i_B);
                LSR:   o_ALU_OUT <= lsr_funct(i_A, i_B);
                LSL:   o_ALU_OUT <= lsl_funct(i_A, i_B);
                default: o_ALU_OUT <= '0;
            endcase
        end else begin
            o_OUT_VALID <= 1'b0;
        end
    end
endmodule