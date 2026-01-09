import UART_PACKAGE::*;

module serializer_tb ();

logic i_clk;
logic i_resetn;
logic [DATA_WIDTH-1:0] i_P_DATA;
logic i_ser_en;
logic i_latche_en;
logic o_ser_data;
logic o_ser_done;

localparam CLK_PERIOD = 10;

serializer serializer_dut(
    .i_clk(i_clk),
    .i_resetn(i_resetn),
    .i_P_DATA(i_P_DATA),
    .i_ser_en(i_ser_en),
    .i_latche_en(i_latche_en),
    .o_ser_data(o_ser_data),
    .o_ser_done(o_ser_done)
);


//clock generation
always begin
    #(CLK_PERIOD / 2);
    i_clk = ~i_clk;
end
//applay input data with one cycle latch enable
task apply_data (input [DATA_WIDTH-1 : 0] data);
    i_P_DATA = data;
    i_latche_en = 1;
    #CLK_PERIOD;
    i_latche_en = 0;
endtask
//check outputs from the serializer
int i;
task check_outputs (input [DATA_WIDTH-1 : 0] data);
    logic [DATA_WIDTH-1:0] ref_data;
    ref_data = data;
    for (i = 0; i < DATA_WIDTH; i++)
    begin
        @ (posedge i_clk);
        if (o_ser_data != ref_data[0] && i_ser_en) begin
            $display("Wrong data %b , correct data is %b \n",o_ser_data,ref_data[0]);
            ref_data = ref_data >> 'b1;
        end else if (i_ser_en) begin
            $display("Correct data %b , correct data is %b \n",o_ser_data,ref_data[0]);
            ref_data = ref_data >> 'b1;
        end else begin
            i--;
        end
    end
endtask

initial begin
    i_clk = 0;
    i_resetn = 0;
    i_P_DATA = 0;
    i_ser_en = 0;
    i_latche_en = 0;

    #(2*CLK_PERIOD);
    i_resetn = 1;
    i_ser_en = 1;
    apply_data('d12);
    check_outputs('d12);
    #(5*CLK_PERIOD);
    i_ser_en = 0;
    #(5*CLK_PERIOD);
    i_ser_en = 1;
end


endmodule