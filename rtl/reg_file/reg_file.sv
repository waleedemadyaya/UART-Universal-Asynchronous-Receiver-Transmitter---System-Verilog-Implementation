import UART_PACKAGE::*;

module reg_file (
    input [DATA_WIDTH-1:0] i_WrData,
    input [ADDRESS_WIDTH-1:0] i_Address,
    input i_WrEn,
    input i_RdEn,
    input CLK,
    input RSTn,

    output logic [DATA_WIDTH-1:0] o_RdData,
    output logic [DATA_WIDTH-1:0] o_REG0,
    output logic [DATA_WIDTH-1:0] o_REG1,
    output logic [DATA_WIDTH-1:0] o_REG2,
    output logic [DATA_WIDTH-1:0] o_REG3,
    output logic                  o_RdData_Valid
);

    logic [DATA_WIDTH-1:0] r_reg_file [(2**ADDRESS_WIDTH)-1:0];

    always_ff @( posedge CLK, negedge RSTn ) begin : pb_reg_file
        if (!RSTn)
        begin
            // Initialize array
            for (int i = 0; i < ADDRESS_WIDTH; i++) begin
                if (i == 2) r_reg_file[i] <= 8'b1000_0001;
                else if (i == 3) r_reg_file[i] <= 8'b0010_0000;
                else r_reg_file[i] <= '0;
            end
            o_RdData <= 'b0;
            o_RdData_Valid <= 'b0;
            
        end else if (i_WrEn) begin
            r_reg_file[i_Address] <= i_WrData;
        end else if (i_RdEn) begin
            o_RdData <= r_reg_file[i_Address];
            o_RdData_Valid <= 'b1;
        end else begin
            o_RdData <= 'b0;
            o_RdData_Valid <= 'b0;
        end
    end

    assign o_REG0 = r_reg_file[0];
    assign o_REG1 = r_reg_file[1];
    assign o_REG2 = r_reg_file[2];
    assign o_REG3 = r_reg_file[3];

endmodule