import UART_PACKAGE::*;

module serializer (
    input i_clk,
    input i_resetn,
    input [DATA_WIDTH-1:0] i_P_DATA,
    input i_ser_en,
    input i_latche_en,
    output o_ser_data,
    output o_ser_done
);

reg [DATA_WIDTH-1:0]latched_data;
reg [$clog2(DATA_WIDTH):0] bit_counter;
assign o_ser_data = latched_data[0];
assign o_ser_done = (bit_counter==0)? 'b1 : 'b0;

always_ff @( posedge i_clk, negedge i_resetn ) begin : serializer_logic
    if (!i_resetn)begin
        latched_data <= 'b0;
        bit_counter <= 'b0;
    end else begin
        if(i_latche_en) begin
            latched_data <= i_P_DATA;
            bit_counter <= 8;
        end else if (i_ser_en && (bit_counter != 'b0)) begin
            latched_data <= latched_data >> 1'b1;
            bit_counter <= bit_counter - 1;
        end
    end    
end

endmodule