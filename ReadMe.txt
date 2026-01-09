UART (Universal Asynchronous Receiver/Transmitter) - SystemVerilog Implementation
Project Overview
A SystemVerilog implementation of a UART peripheral based on the industry-standard TL16C550 asynchronous communications element. This project features a fully functional UART with configurable baud rates, FIFO buffering, and interrupt support, suitable for FPGA and ASIC designs.

Key Features
Core Functionality
Serial-to-Parallel & Parallel-to-Serial Conversion: Bidirectional data conversion between serial peripheral devices and parallel CPU interfaces

TL16C450 Compatibility Mode: Single character mode for backward compatibility

TL16C550 FIFO Mode: Advanced mode with 16-byte transmit and receive FIFOs

Error Detection: Three error status bits per received byte in FIFO mode

Programmable Configuration
Baud Rate Generator: Divisor range from 1 to 65535

Clock Options: Configurable 16× or 13× reference clock generation

Interrupt System: Flexible interrupt generation for efficient CPU communication

Status Monitoring: Real-time status registers accessible by CPU

Technical Specifications
FIFO Depth: 16 bytes for both transmitter and receiver

Error Status: Per-byte error tracking (parity, framing, overrun)

Clock Divider: Programmable divisor for custom baud rates

Control Registers: Full set of control and status registers