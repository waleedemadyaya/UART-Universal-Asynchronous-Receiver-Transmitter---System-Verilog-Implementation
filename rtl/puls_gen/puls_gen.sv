module PULSE_GEN (
    input  wire i_CLK,       // System Clock
    input  wire i_RST_n,       // Synchronous Reset (Active High)
    input  wire i_LVL_SIG,   // Input Level Signal
    output wire o_PULSE_SIG  // Output Pulse Signal
);

    // Internal register to store the previous state of the input signal
    reg lvl_sig_delay;

    // Sequential logic to sample the input signal
    always @( posedge i_CLK, negedge i_RST_n) begin
        if (!i_RST_n) begin
            lvl_sig_delay <= 1'b0;
        end else begin
            lvl_sig_delay <= i_LVL_SIG;
        end
    end

    // Combinational logic for edge detection
    // A pulse is generated when the current signal is high and the previous was low
    assign o_PULSE_SIG = i_LVL_SIG & (~lvl_sig_delay);

endmodule