import SYS_PACKAGE::*;

module SYS_TOP (
    // Global inputs
    input  wire        REF_CLK,          // 50 MHz reference clock
    input  wire        UART_CLK,         // 3.6864 MHz UART clock
    input  wire        RST_N,      // Asynchronous active-low reset
    
    // UART interfaces
    input  wire        UART_RX_IN,            // Serial RX input
    output wire        UART_TX_O,           // Serial TX output
    output wire        parity_error,          // Parity error indicator
    output wire        framing_error           // Stop error indicator
    
    // Optional debug outputs
    // output wire        ALU_OUT_VALID,
    // output wire [7:0]  ALU_RESULT,
    // output wire        TX_BUSY,
    // output wire        FIFO_FULL,
    // output wire        FIFO_EMPTY
);

    // ====================
    // INTERNAL SIGNALS
    // ====================
    
    // Clock domain 1 signals (REF_CLK domain)
    wire                clk_ref;
    wire                rst_ref_n;
    wire                gated_clk;
    
    // Clock domain 2 signals (UART_CLK domain)
    wire                clk_uart;
    wire                rst_uart_n;
    wire                div_clk;
    
    // RegFile signals
    wire [ADDR_WIDTH-1:0]          reg_addr;
    wire                reg_wr_en;
    wire                reg_rd_en;
    wire [DATA_WIDTH-1:0]          reg_wr_data;
    wire [DATA_WIDTH-1:0]          reg_rd_data;
    wire                reg_rd_valid;
    wire [DATA_WIDTH-1:0]          reg0_out;    // ALU Operand A
    wire [DATA_WIDTH-1:0]          reg1_out;    // ALU Operand B
    wire [DATA_WIDTH-1:0]          reg2_out;    // UART Config
    wire [DATA_WIDTH-1:0]          reg3_out;    // Div Ratio
    
    // ALU signals
    wire [ALU_FUN_WIDTH-1:0]          alu_func;
    wire                alu_en;
    wire [ALU_OUT_WIDTH-1:0]          alu_result;
    wire                alu_out_valid;
    
    // UART TX signals
    wire [DATA_WIDTH-1:0]          tx_p_data;
    wire                tx_d_vld;
    wire                tx_busy;
    wire                tx_par_en;
    wire                tx_par_typ;
    
    // UART RX signals
    wire [DATA_WIDTH-1:0]          rx_p_data;
    wire                rx_d_vld;
    wire [PRESCALE_WIDTH-1:0]          rx_prescale;
    wire                rx_par_en;
    wire                rx_par_typ;
    
    // Async FIFO signals
    wire [DATA_WIDTH-1:0]          fifo_wr_data;
    wire                fifo_wr_inc;
    wire [DATA_WIDTH-1:0]          fifo_rd_data;
    wire                fifo_rd_inc;
    wire                fifo_full;
    wire                fifo_empty;
    
    // Data Sync signals
    wire [DATA_WIDTH-1:0]          sync_rx_data;
    wire                sync_rx_valid;
    
    // Pulse Gen signals
    wire                pulse_sig;
    
    // Clock gating signal
    wire                clk_en;
    
    // Clock divider signal
    wire                clk_div_en;
    
    // ====================
    // CLOCK & RESET SYNCHRONIZATION
    // ====================
    
    // Reset synchronizers for each clock domain
    RST_SYNC rst_sync_ref (
        .i_CLK     (REF_CLK),
        .i_RSTn     (RST_N),
        .o_SYNC_RSTn(rst_ref_n)
    );
    
    RST_SYNC rst_sync_uart (
        .i_CLK     (UART_CLK),
        .i_RSTn     (RST_N),
        .o_SYNC_RSTn(rst_uart_n)
    );
    
    // Clock assignments
    assign clk_ref  = REF_CLK;
    assign clk_uart = UART_CLK;
    
    // ====================
    // MAIN SYSTEM BLOCKS
    // ====================
    
    // 1. REGISTER FILE
    reg_file U0_RegFile (
        .i_CLK          (clk_ref),
        .i_RSTn         (rst_ref_n),       // Active low to active high
        .i_Address      (reg_addr),
        .i_WrEn         (reg_wr_en),
        .i_RdEn         (reg_rd_en),
        .i_WrData       (reg_wr_data),
        .o_RdData       (reg_rd_data),
        .o_RdData_Valid (reg_rd_valid),
        .o_REG0         (reg0_out),
        .o_REG1         (reg1_out),
        .o_REG2         (reg2_out),
        .o_REG3         (reg3_out)
    );
    
    // 2. ARITHMETIC LOGIC UNIT
    ALU u_alu (
        .i_CLK        (gated_clk),
        .i_RSTn        (rst_ref_n),
        .i_A          (reg0_out),
        .i_B          (reg1_out),
        .i_ALU_FUN    (alu_func),
        .i_Enable     (alu_en),
        .o_ALU_OUT    (alu_result),
        .o_OUT_VALID  (alu_out_valid)
    );
    
    // 3. CLOCK GATING
    clock_gating u_clock_gate (
        .i_CLK        (clk_ref),
        .i_CLK_EN     (clk_en),
        .o_GATED_CLK  (gated_clk)
    );
    
    // 4. SYSTEM CONTROLLER (MAIN FSM)
    SYS_CTRL u_sys_ctrl (
        .i_CLK            (clk_ref),
        .i_RSTn           (rst_ref_n),
        .i_ALU_OUT        (alu_result),  // 16-bit input per spec
        .i_OUT_Valid      (alu_out_valid),
        .o_ALU_FUN        (alu_func),
        .o_EN             (alu_en),
        .o_CLK_EN         (clk_en),
        .o_Address        (reg_addr),
        .o_WrEn           (reg_wr_en),
        .o_RdEn           (reg_rd_en),
        .o_WrData         (reg_wr_data),
        .i_RdData         (reg_rd_data),
        .i_RdData_Valid   (reg_rd_valid),
        .i_RX_P_DATA      (sync_rx_data),
        .i_RX_D_VLD       (sync_rx_valid),
        .o_TX_P_DATA      (tx_p_data),
        .o_TX_D_VLD       (tx_d_vld),
        //.o_clk_div_en     (clk_div_en),
        .i_FIFO_FULL      (fifo_full)
    );
    
    // 5. CLOCK DIVIDER
    clk_div u_clk_divider_tx (
        .i_ref_clk   (clk_uart),
        .i_rst_n     (rst_uart_n),
        .i_clk_en    (1'b1),              // Always enabled per spec
        .i_div_ratio (reg3_out),
        .o_div_clk   (div_clk)
    );

    // 5. CLOCK DIVIDER
    clk_div u_clk_divider_rx (
        .i_ref_clk   (clk_uart),
        .i_rst_n     (rst_uart_n),
        .i_clk_en    (1'b1),              // Always enabled per spec
        .i_div_ratio (reg3_out/reg2_out[7:2]),
        .o_div_clk   (rx_clk_generated)
    );
    
    // 6. UART TRANSMITTER
    UART_TX u_uart_tx (
        .i_CLK         (div_clk),
        .i_RSTn        (rst_uart_n),
        .i_PAR_EN      (reg2_out[0]),
        .i_PAR_TYP     (reg2_out[1]),
        .i_P_DATA      (fifo_rd_data),
        .i_DATA_VALID  (fifo_rd_inc),
        .o_TX_OUT      (UART_TX_O),
        .o_BUSY        (tx_busy)
    );
    
    // 7. UART RECEIVER
    UART_RX u_uart_rx (
        .i_CLK         (rx_clk_generated),
        .i_RSTn         (rst_uart_n),
        .i_Prescale    (reg2_out[7:2]),
        .i_PAR_EN      (reg2_out[0]),
        .i_PAR_TYP     (reg2_out[1]),
        .i_RX_IN       (UART_RX_IN),
        .o_P_DATA      (rx_p_data),
        .o_DATA_VALID    (rx_d_vld),
        .o_PAR_ERR     (parity_error),
        .o_STP_ERR     (framing_error)
    );
    
    // 8. DATA SYNCHRONIZER (UART_RX to REF_CLK domain)
    Data_Sync #(
        .BUS_WIDTH(8)
    ) u_data_sync (
        .i_unsync_bus    (rx_p_data),
        .i_bus_enable    (rx_d_vld),
        .i_dest_clk      (clk_ref),
        .i_dest_rstn      (rst_ref_n),
        .o_sync_bus      (sync_rx_data),
        .o_enable_pulse(sync_rx_valid)
    );
    
    // 9. PULSE GENERATOR
    PULSE_GEN u_pulse_gen (
        .i_CLK        (div_clk),
        .i_RSTn       (rst_uart_n),
        .i_LVL_SIG    (!(tx_busy)&&!(fifo_empty)),
        .o_PULSE_SIG  (pulse_sig)
    );
    
    // 10. ASYNCHRONOUS FIFO (REF_CLK → UART_TX clock domain)
    fifo1 u_async_fifo (
        .i_W_CLK     (clk_ref),
        .i_W_RSTn     (rst_ref_n),
        .i_W_INC     (tx_d_vld),
        .i_WR_DATA    (tx_p_data),
        .i_R_CLK     (div_clk),
        .i_R_RSTn     (rst_uart_n),
        .i_R_INC     (pulse_sig),
        .o_RD_DATA    (fifo_rd_data),
        .o_FULL      (fifo_full),
        .o_EMPTY     (fifo_empty)
    );

    /*
    clk_multiplier u_baud_gen (
        .i_CLK      (div_clk),       // High-speed source (e.g., 50MHz)
        .i_RSTn     (rst_uart_n),
        .i_Prescale (reg2_out[7:2]),  // 8, 16, or 32
        .o_rx_clk   (rx_clk_generated)
    );*/
    
    // ====================
    // SIGNAL ASSIGNMENTS
    // ====================
    
    // Connect FIFO read enable
    assign fifo_rd_inc = pulse_sig;
    
    // Debug outputs
    // assign ALU_OUT_VALID = alu_out_valid;
    // assign ALU_RESULT    = alu_result;
    // assign TX_BUSY       = tx_busy;
    // assign FIFO_FULL     = fifo_full;
    // assign FIFO_EMPTY    = fifo_empty;

endmodule

// ============================================================================
// Module:       clk_multiplier
// Designer:     IC / Automation Engineer
// Description:  Generates a divided/multiplied clock pulse based on Prescale.
//               Typically used for UART Baud Rate Generation.
// ============================================================================

module clk_multiplier #(
    parameter PRESCALE_WIDTH = 6
)(
    input  logic                      i_CLK,      // High-speed Reference Clock
    input  logic                      i_RSTn,     // Active Low Asynchronous Reset
    input  logic [PRESCALE_WIDTH-1:0] i_Prescale, // Support for 8, 16, 32
    output logic                      o_rx_clk    // Generated clock pulse
);

    // Internal signals
    logic [PRESCALE_WIDTH-1:0] count_reg;
    logic [PRESCALE_WIDTH-1:0] count_next;
    logic                      clk_gen_reg;
    logic                      clk_gen_next;

    // ------------------------------------------------------------------------
    // Counter Logic: Division control
    // ------------------------------------------------------------------------
    always_ff @(posedge i_CLK or negedge i_RSTn) begin
        if (!i_RSTn) begin
            count_reg   <= '0;
            clk_gen_reg <= 1'b0;
        end else begin
            count_reg   <= count_next;
            clk_gen_reg <= clk_gen_next;
        end
    end

    // ------------------------------------------------------------------------
    // Combinational Logic for Frequency Control
    // ------------------------------------------------------------------------
    always_comb begin
        // Default assignments
        count_next   = count_reg + 1'b1;
        clk_gen_next = clk_gen_reg;

        // Reset counter and toggle output clock when reaching terminal count
        // Terminal count is (Prescale >> 1) - 1 for a 50% duty cycle
        // If generating pulses (enable signals), use (Prescale - 1)
        if (count_reg >= (i_Prescale >> 1) - 1'b1) begin
            count_next   = '0;
            clk_gen_next = ~clk_gen_reg;
        end
    end

    // Output assignment
    assign o_rx_clk = clk_gen_reg;

endmodule