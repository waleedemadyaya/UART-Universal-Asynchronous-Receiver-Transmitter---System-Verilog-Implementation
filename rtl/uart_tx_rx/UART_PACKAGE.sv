package UART_PACKAGE;

    // --- Data Configuration ---
    // Number of bits in the UART data payload
    parameter DATA_WIDTH = 8;

    // --- Prescale Configuration ---
    // The maximum possible value for the clock divider (Oversampling)
    parameter MAX_PRESCALE = 32;
    
    // Width calculation: +1 ensures we can represent the MAX_PRESCALE value itself
    // e.g., if MAX_PRESCALE is 32, $clog2(33) = 6 bits
    parameter PRESCALE_WIDTH = $clog2(MAX_PRESCALE + 1);

    // --- Sampling Configuration ---
    // Number of samples taken per bit (usually for majority voting)
    parameter NUM_SAMPLED_BITS = 3;

    // --- Calculation Helpers (Optional but Professional) ---
    // Defines the max value for bit counters (Start + Data + Parity + Stop)
    parameter MAX_BIT_COUNT_WIDTH = $clog2(DATA_WIDTH + 3);

endpackage : UART_PACKAGE