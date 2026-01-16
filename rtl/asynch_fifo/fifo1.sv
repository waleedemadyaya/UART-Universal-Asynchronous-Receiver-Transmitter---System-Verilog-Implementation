`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/18/2025 11:39:38 AM
// Design Name: 
// Module Name: fifo1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fifo1 #(
    parameter DSIZE = 8,
    parameter ASIZE = 4
)(
    output [DSIZE-1:0] o_RD_DATA,
    output o_FULL,
    output o_EMPTY,
    input [DSIZE-1:0] i_WR_DATA,
    input i_W_INC, i_W_CLK, W_RST_n,
    input i_R_INC, i_R_CLK, i_R_RSTn);
    wire [ASIZE-1:0] waddr, raddr;
    wire [ASIZE:0] wptr, rptr, wq2_rptr, rq2_wptr;
    
     sync_r2w sync_r2w (
     .wq2_rptr(wq2_rptr), .rptr(rptr),
     .wclk(i_W_CLK), .wrst_n(W_RST_n));
     
     sync_w2r sync_w2r
    (.rq2_wptr(rq2_wptr), .wptr(wptr),
     .rclk(i_R_CLK), .rrst_n(i_R_RSTn));
     
     fifomem #(DSIZE, ASIZE) fifomem
    (.rdata(o_RD_DATA), .wdata(i_WR_DATA),
     .waddr(waddr), .raddr(raddr),
     .wclken(i_W_INC), .wfull(o_FULL),
     .wclk(i_W_CLK),
     .rclken(i_R_INC), .rempty(o_EMPTY),
     .rclk(i_R_CLK)
     );
     
     rptr_empty #(ASIZE) rptr_empty
     (.rempty(o_EMPTY),
     .raddr(raddr),
     .rptr(rptr), .rq2_wptr(rq2_wptr),
     .rinc(i_R_INC), .rclk(i_R_CLK),
     .rrst_n(i_R_RSTn));
     
     wptr_full #(ASIZE) wptr_full
     (.wfull(o_FULL), .waddr(waddr),
     .wptr(wptr), .wq2_rptr(wq2_rptr),
     .winc(i_W_INC), .wclk(i_W_CLK),
     .wrst_n(W_RST_n));
endmodule
