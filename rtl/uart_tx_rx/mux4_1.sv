module mux_4_1 (
    input i_1, i_2, i_3, i_4,
    input [1:0] sel,
    output logic o
);
    always_comb begin : mux_4_1
        case(sel)
            'b00:
            begin
                o = i_1;
            end
            'b01:
            begin
                o = i_2;
            end
            'b10:
            begin
                o = i_3;
            end
            'b11:
            begin
                o = i_4;
            end
        endcase
    end
endmodule