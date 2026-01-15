`include "UART_PACKAGE.sv"
import UART_PACKAGE::*;

module Tx_Rx_Wrapper (
    input  logic                     TX_CLK,
    input  logic                     RX_CLK,
    input  logic                     RSTn,

    // Configuration
    input  logic [PRESCALE_WIDTH-1:0] Prescale,
    input  logic                     PAR_EN,
    input  logic                     PAR_TYP,

    // Transmitter Input (The Data we want to send)
    input  logic [DATA_WIDTH-1:0]    TX_P_DATA,
    input  logic                     TX_DATA_VALID,
    output logic                     TX_BUSY,

    // Receiver Output (The Data we eventually receive)
    output logic [DATA_WIDTH-1:0]    RX_P_DATA,
    output logic                     RX_DATA_VALID,
    output logic                     RX_PARITY_ERR,
    output logic                     RX_FRAMING_ERR
);

    // Internal loopback wire
    logic w_serial_line;

    // --- UART Transmitter ---
    UART_TX u_TX (
        .i_clk        (TX_CLK),
        .i_rst_n      (RSTn),
        .i_PAR_EN     (PAR_EN),
        .i_PAR_TYP    (PAR_TYP),
        .i_P_DATA     (TX_P_DATA),
        .i_DATA_VALID (TX_DATA_VALID),
        .o_TX_OUT     (w_serial_line), // Sending to internal wire
        .o_BUSY       (TX_BUSY)
    );

    // --- UART Receiver ---
    UART_RX u_RX (
        .CLK           (RX_CLK),
        .RSTn          (RSTn),
        .RX_IN         (w_serial_line), // Receiving from internal wire
        .Prescale      (Prescale),
        .PAR_EN        (PAR_EN),
        .PAR_TYP       (PAR_TYP),
        .P_DATA        (RX_P_DATA),
        .data_valid    (RX_DATA_VALID),
        .parity_error  (RX_PARITY_ERR),
        .framing_error (RX_FRAMING_ERR)
    );

endmodule