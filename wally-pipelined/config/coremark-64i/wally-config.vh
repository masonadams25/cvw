//////////////////////////////////////////
// wally-config.vh
//
// Written: David_Harris@hmc.edu 4 January 2021
// Modified: 
//
// Purpose: Specify which features are configured
//          Macros to determine which modes are supported based on MISA
// 
// A component of the Wally configurable RISC-V project.
// 
// Copyright (C) 2021 Harvey Mudd College & Oklahoma State University
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, 
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software 
// is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS 
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT 
// OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
///////////////////////////////////////////

// include shared configuration
`include "wally-shared.vh"

// RV32 or RV64: XLEN = 32 or 64
`define XLEN 64

//`define MISA (32'h00000104)
`define MISA (32'h00000104 | 1<<5 | 1<<18 | 1 << 20)
`define ZCSR_SUPPORTED 1
`define ZCOUNTERS_SUPPORTED 1

// Microarchitectural Features
`define UARCH_PIPELINED 1
`define UARCH_SUPERSCALR 0
`define UARCH_SINGLECYCLE 0
`define MEM_DCACHE 0
`define MEM_DTIM 1
`define MEM_ICACHE 0
`define MEM_VIRTMEM 0

// Address space
`define RESET_VECTOR 64'h0000000000001000

// Bus Interface width
`define AHBW 64

// Peripheral Addresses
// Peripheral memory space extends from BASE to BASE+RANGE
// Range should be a thermometer code with 0's in the upper bits and 1s in the lower bits

`define TIMBASE    32'h80000000
`define TIMRANGE   32'h0007FFFF
`define CLINTBASE  32'h02000000
`define CLINTRANGE 32'h0000FFFF
`define GPIOBASE   32'h10012000
`define GPIORANGE  32'h000000FF
`define UARTBASE   32'h10000000
`define UARTRANGE  32'h00000007

// Test modes

// Tie GPIO outputs back to inputs
`define GPIO_LOOPBACK_TEST 0


// Hardware configuration
`define UART_PRESCALE 1
