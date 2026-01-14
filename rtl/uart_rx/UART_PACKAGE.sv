package UART_PACKAGE; 
    parameter DATA_WIDTH = 8;

    parameter MAX_PRESCALE = 32;
    
    parameter PRESCALE_WIDTH = $clog2(MAX_PRESCALE+1);

    parameter NUM_SAMPLED_BITS = 3;

endpackage : UART_PACKAGE 