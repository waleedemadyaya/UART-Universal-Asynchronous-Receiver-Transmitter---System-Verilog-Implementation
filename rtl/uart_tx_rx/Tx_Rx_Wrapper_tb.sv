`timescale 1ns/1ps

module Tx_Rx_Wrapper_tb ();

    // =========================================================================
    // 1. Parameters & Clock Configuration
    // =========================================================================
    parameter DATA_WIDTH_TB = 8;
    
    // Target Baud Rate: 115.2 kbps
    // Bit Period = 1 / 115200 ≈ 8680.55 ns
    parameter real TX_BIT_PERIOD = 8680.55; 

    // DUT Signals
    logic                      TX_CLK;
    logic                      RX_CLK;
    logic                      RSTn;
    logic [5:0]                Prescale;
    logic                      PAR_EN;
    logic                      PAR_TYP;
    
    logic [DATA_WIDTH_TB-1:0]  TX_P_DATA;
    logic                      TX_DATA_VALID;
    wire                       TX_BUSY;
    
    wire [DATA_WIDTH_TB-1:0]   RX_P_DATA;
    wire                       RX_DATA_VALID;
    wire                       RX_PARITY_ERR;
    wire                       RX_FRAMING_ERR;

    // --- Dynamic Clock Logic ---
    // RX Clock Freq = TX Freq * Prescale
    real rx_clk_period;
    
    initial begin
        RX_CLK = 0;
        TX_CLK = 0;
        Prescale = 32; // Default starting prescale
        rx_clk_period = TX_BIT_PERIOD / 32.0;
    end

    // Update RX clock period whenever Prescale is changed in the TB
    always @(Prescale) begin
        rx_clk_period = TX_BIT_PERIOD / $itor(Prescale);
    end

    // Generate System Clock (RX Clock)
    always #(rx_clk_period/2.0) RX_CLK = ~RX_CLK;
    always #(TX_BIT_PERIOD/2.0) TX_CLK = ~TX_CLK;

    // =========================================================================
    // 2. Main Test Procedure
    // =========================================================================
    initial begin
        // Initialize and Reset
        initialize();
        reset();

        // --- TEST CASE 1: 8-N-1 (No Parity), Prescale 32 ---
        $display("\n[TC1] Testing 8-N-1 | Prescale: 32");
        run_uart_transaction(8'hA5, 6'd32, 1'b0, 1'b0);

        // --- TEST CASE 2: 8-E-1 (Even Parity), Prescale 16 ---
        $display("\n[TC2] Testing 8-E-1 | Prescale: 16");
        run_uart_transaction(8'h3C, 6'd16, 1'b1, 1'b0);

        // --- TEST CASE 3: 8-O-1 (Odd Parity), Prescale 8 ---
        $display("\n[TC3] Testing 8-O-1 | Prescale: 8");
        run_uart_transaction(8'hFF, 6'd8, 1'b1, 1'b1);

        // --- TEST CASE 4: Stress Test (Back-to-Back) ---
        $display("\n[TC4] Testing Consecutive Bytes | Prescale: 16");
        configure_uart(6'd16, 1'b0, 1'b0);
        send_data(8'h55);
        send_data(8'hAA);
        
        // Final Wait
        #5000;
        $display("\n[ALL TEST CASES PASSED SUCCESSFULLY]");
        $stop;
    end

    // =========================================================================
    // 3. Helper Tasks
    // =========================================================================
    
    task initialize;
        begin
            RSTn          = 1;
            TX_P_DATA     = 0;
            TX_DATA_VALID = 0;
            PAR_EN        = 0;
            PAR_TYP       = 0;
            Prescale      = 32;
        end
    endtask

    task reset;
        begin
            #(TX_BIT_PERIOD)   RSTn = 0;
            #(TX_BIT_PERIOD*5) RSTn = 1;
            #(TX_BIT_PERIOD*5);
        end
    endtask

    task configure_uart(input [5:0] pre, input en, input typ);
        begin
            Prescale = pre;
            PAR_EN   = en;
            PAR_TYP  = typ;
            #(TX_BIT_PERIOD); // Let the system stabilize
        end
    endtask

    task send_data(input [DATA_WIDTH_TB-1:0] data);
        begin
            wait(!TX_BUSY);
            @(posedge TX_CLK);
            TX_P_DATA     = data;
            TX_DATA_VALID = 1;
            @(posedge TX_CLK);
            TX_DATA_VALID = 0;
        end
    endtask

    task verify_received(input [DATA_WIDTH_TB-1:0] expected);
        begin
            @(posedge RX_DATA_VALID);
            if (RX_P_DATA === expected && !RX_PARITY_ERR && !RX_FRAMING_ERR)
                $display("  [PASS] Data: %h received correctly.", RX_P_DATA);
            else begin
                $display("  [FAIL] Expected: %h | Received: %h", expected, RX_P_DATA);
                $display("         Errors -> Parity: %b | Frame: %b", RX_PARITY_ERR, RX_FRAMING_ERR);
                $stop;
            end
        end
    endtask

    task run_uart_transaction(input [7:0] data, input [5:0] pre, input en, input typ);
        begin
            configure_uart(pre, en, typ);
            send_data(data);
            verify_received(data);
            #(TX_BIT_PERIOD * 2);
        end
    endtask

    // =========================================================================
    // 4. DUT Instantiation
    // =========================================================================
    Tx_Rx_Wrapper DUT (
        .TX_CLK            (TX_CLK),
        .RX_CLK            (RX_CLK),
        .RSTn           (RSTn),
        .Prescale       (Prescale),
        .PAR_EN         (PAR_EN),
        .PAR_TYP        (PAR_TYP),
        .TX_P_DATA      (TX_P_DATA),
        .TX_DATA_VALID  (TX_DATA_VALID),
        .TX_BUSY        (TX_BUSY),
        .RX_P_DATA      (RX_P_DATA),
        .RX_DATA_VALID  (RX_DATA_VALID),
        .RX_PARITY_ERR  (RX_PARITY_ERR),
        .RX_FRAMING_ERR (RX_FRAMING_ERR)
    );

endmodule