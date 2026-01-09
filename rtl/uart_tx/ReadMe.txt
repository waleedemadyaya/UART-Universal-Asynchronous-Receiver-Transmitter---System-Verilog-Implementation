# UART Transmitter - SystemVerilog Implementation

## 📋 Project Overview
A complete SystemVerilog implementation of a Universal Asynchronous Receiver/Transmitter (UART) transmitter module. This project implements a fully functional UART transmitter with configurable parity, proper framing, and comprehensive verification.

## 🏗️ Architecture
```
UART_TX (Top Module)
├── FSM_controller (State Machine)
├── serializer (Parallel-to-Serial Converter)
├── parity_calc (Parity Generator)
├── mux_4_1 (Output Selector)
└── UART_PACKAGE (Configuration Parameters)
```

## 📁 File Structure
```
UART_Transmitter/
├── rtl/                          # Source Files
│   ├── UART_TX.sv               # Top-level transmitter
│   ├── FSM_controller.sv        # Finite State Machine
│   ├── serializer.sv            # Serializer module
│   ├── parity_calc.sv           # Parity calculator
│   ├── mux_4_1.sv               # 4:1 Multiplexer
│   └── UART_PACKAGE.sv          # Package with parameters
├── tb/                          # Testbenches
│   ├── tb_FSM_controller.sv     # FSM testbench
│   ├── UART_TX_TB.sv            # Main transmitter testbench
│   ├── serializer_tb.sv         # Serializer testbench
│   └── parity_calc_tb.sv        # Parity calculator testbench
├── waves/                       # Simulation waveforms
├── docs/                        # Documentation
└── README.md                    # This file
```

## 🔧 Module Specifications

### 1. **UART_TX** (`UART_TX.sv`)
**Top-level transmitter module**
```systemverilog
module UART_TX (
    input  logic       i_clk,           // System clock
    input  logic       i_rst_n,         // Active-low reset
    input  logic       i_PAR_EN,        // Parity enable (0: disable, 1: enable)
    input  logic       i_PAR_TYP,       // Parity type (0: even, 1: odd)
    input  logic [7:0] i_P_DATA,        // 8-bit parallel data input
    input  logic       i_DATA_VALID,    // Data valid pulse
    output logic       o_TX_OUT,        // Serial output
    output logic       o_BUSY           // Busy indicator
);
```

### 2. **FSM_controller** (`FSM_controller.sv`)
**State Machine with 6 states**
```systemverilog
typedef enum logic [2:0] {
    S_IDLE      = 3'd0,    // Waiting for data
    S_LATCH     = 3'd1,    // Latch parallel data
    S_START     = 3'd2,    // Send start bit (0)
    S_DATA      = 3'd3,    // Send 8 data bits (LSB first)
    S_PARITY    = 3'd4,    // Send parity bit
    S_STOP      = 3'd5     // Send stop bit (1)
} state_t;
```

### 3. **serializer** (`serializer.sv`)
**8-bit Parallel-to-Serial Converter**
- Converts parallel data to serial stream
- Outputs LSB first
- Generates `ser_done` flag when complete

### 4. **parity_calc** (`parity_calc.sv`)
**Parity Bit Calculator**
```systemverilog
// Even parity: par_bit = ^P_DATA (XOR of all bits)
// Odd parity:  par_bit = ~(^P_DATA) (XNOR of all bits)
```

### 5. **mux_4_1** (`mux_4_1.sv`)
**Output Multiplexer**
```
sel = 00: Start bit (0)
sel = 01: Stop/Idle bit (1)  
sel = 10: Serial data
sel = 11: Parity bit
```

### 6. **UART_PACKAGE** (`UART_PACKAGE.sv`)
**Configuration Package**
```systemverilog
package UART_PACKAGE;
    parameter DATA_WIDTH = 8;  // Configurable data width
endpackage
```

## 📊 UART Frame Format
```
┌────────┬─────────────┬──────────┬─────────┐
│ START  │   DATA      │  PARITY  │  STOP   │
│  (0)   │ (8 bits LSB │ (0 or 1) │   (1)   │
│        │   first)    │          │         │
└────────┴─────────────┴──────────┴─────────┘
   1 bit     8 bits       1 bit      1 bit
```

## 🚀 Features
- ✅ **8-bit data transmission** (configurable via `UART_PACKAGE`)
- ✅ **Programmable parity**: Even/Odd/None
- ✅ **Standard UART framing**: Start bit (0), Stop bit (1)
- ✅ **Busy indicator**: `o_BUSY` signal during transmission
- ✅ **LSB-first** serial transmission
- ✅ **Synchronous design** with proper reset handling
- ✅ **Comprehensive testbenches** with 100% functional coverage

## 🧪 Verification
### Test Coverage Matrix
| Test Case | Description | Status |
|-----------|-------------|--------|
| **FSM Test 1** | Simple transmission without parity | ✅ |
| **FSM Test 2** | Transmission with parity enabled | ✅ |
| **FSM Test 3** | Data valid during busy state | ✅ |
| **FSM Test 4** | Back-to-back transmissions | ✅ |
| **FSM Test 5** | Parity enable toggle | ✅ |
| **FSM Test 6** | Reset during transmission | ✅ |
| **FSM Test 7** | Continuous stimulus robustness | ✅ |
| **System Test 1** | No parity transmission (8'hA3) | ✅ |
| **System Test 2** | Even parity transmission (8'hB4) | ✅ |
| **System Test 3** | Odd parity transmission (8'hD2) | ✅ |

### Simulation Setup
```bash
# Compile and run FSM testbench
iverilog -g2012 -I. -o fsm_sim tb_FSM_controller.sv FSM_controller.sv
vvp fsm_sim

# Compile and run main testbench  
iverilog -g2012 -I. -o uart_tx_sim UART_TX_TB.sv *.sv
vvp uart_tx_sim

# View waveforms (GTKWave)
gtkwave fsm_controller_waves.vcd
```

## 📈 Timing Characteristics
- **Clock Frequency**: 200 MHz (5ns period) for FSM
- **Baud Rate**: 115.2 KHz (8.68µs period) for system tests
- **Transmission Time**: 
  - Without parity: 10 bits × 8.68µs = 86.8µs
  - With parity: 11 bits × 8.68µs = 95.48µs

## 🔌 Interface Signals

### Inputs
| Signal | Width | Description |
|--------|-------|-------------|
| `i_clk` | 1 | System clock (200MHz) |
| `i_rst_n` | 1 | Active-low asynchronous reset |
| `i_PAR_EN` | 1 | Parity enable (1=enabled, 0=disabled) |
| `i_PAR_TYP` | 1 | Parity type (0=even, 1=odd) |
| `i_P_DATA` | 8 | Parallel data input |
| `i_DATA_VALID` | 1 | Data valid pulse (1 cycle) |

### Outputs
| Signal | Width | Description |
|--------|-------|-------------|
| `o_TX_OUT` | 1 | Serial data output |
| `o_BUSY` | 1 | High during transmission |

## 🎯 Operation Sequence
1. **Idle State**: `o_TX_OUT = 1`, `o_BUSY = 0`
2. **Data Request**: Pulse `i_DATA_VALID = 1` with `i_P_DATA`
3. **Start Bit**: `o_TX_OUT = 0` for 1 bit time, `o_BUSY = 1`
4. **Data Bits**: Transmit 8 bits LSB-first
5. **Parity Bit**: Transmit if `i_PAR_EN = 1`
6. **Stop Bit**: `o_TX_OUT = 1` for 1 bit time
7. **Return to Idle**: `o_BUSY = 0`, ready for next transmission

## 📝 Example Usage
```systemverilog
// Instantiate UART transmitter
UART_TX uart_tx_inst (
    .i_clk(clk_200mhz),
    .i_rst_n(rst_n),
    .i_PAR_EN(1'b1),           // Enable parity
    .i_PAR_TYP(1'b0),          // Even parity
    .i_P_DATA(8'h55),          // Data to transmit
    .i_DATA_VALID(data_valid), // Trigger transmission
    .o_TX_OUT(uart_tx),        // Serial output
    .o_BUSY(tx_busy)           // Status indicator
);

// Trigger transmission
assign data_valid = (tx_ready && !tx_busy);
```

## 🧰 Dependencies
- **Simulator**: Icarus Verilog, ModelSim, or equivalent
- **Waveform Viewer**: GTKWave (optional)
- **SystemVerilog**: IEEE 1800-2012 compatible

## 📊 Simulation Results
```
Test Case 1 is succeeded
Test Case 2 is succeeded  
Test Case 3 is succeeded
All stimulus applied, simulation continues...
```

## 🚀 Future Enhancements
1. **Baud Rate Generator**: Programmable clock divider
2. **FIFO Buffer**: TL16C550 compatible 16-byte buffer
3. **Interrupt Support**: Transmission complete interrupt
4. **Flow Control**: RTS/CTS handshaking
5. **Configurable Data Width**: 5-9 bit support
6. **Multiple Stop Bits**: 1, 1.5, 2 stop bits

## 📚 References
1. **TL16C550 Datasheet** - Texas Instruments
2. **UART Protocol** - RS-232 Standard
3. **SystemVerilog IEEE 1800-2012** - Language Reference Manual

## 👥 Contributors
- Developed as part of Digital Design course final project

## 📄 License
This project is open-source and available for academic and personal use.

---
*Last Updated: December 2024*  
*Project Status: Complete & Verified*