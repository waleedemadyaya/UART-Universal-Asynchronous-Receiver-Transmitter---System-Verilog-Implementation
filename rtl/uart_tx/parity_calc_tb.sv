import UART_PACKAGE::*;

module parity_calc_tb;

    logic [DATA_WIDTH-1:0] P_DATA;
    logic Data_Valid;
    logic PAR_TYP;
    logic par_bit;

    parity_calc DUT(
        .P_DATA(P_DATA),
        .Data_Valid(Data_Valid),
        .PAR_TYP(PAR_TYP),
        .par_bit(par_bit)
    );

    initial begin
        Data_Valid = 0;
        PAR_TYP = 0;
        P_DATA = 'b0;

        #10
        
        P_DATA = 'hA1;
        #10
        PAR_TYP = 'b0;
        Data_Valid = 'b1;

        #10
        Data_Valid = 'b0;

        #50
        PAR_TYP = 1;
        P_DATA = 'hB2;
        Data_Valid = 'b1;

        #10
        Data_Valid = 0;
    end

endmodule