import UART_PACKAGE::*;

module parity_calc (
    P_DATA,
    Data_Valid,
    PAR_TYP,
    par_bit
);

    input logic [DATA_WIDTH-1:0] P_DATA;
    input logic Data_Valid;
    input logic PAR_TYP;
    output logic par_bit;

    always_latch begin : par_bit_calc
        if (Data_Valid == 'b1)
        begin
            case (PAR_TYP)
                'b0:
                begin
                    par_bit = ^P_DATA;
                end
                'b1:
                begin
                    par_bit = ~(^P_DATA);
                end
            endcase
        end else
        begin
            par_bit = par_bit;
        end
    end



endmodule