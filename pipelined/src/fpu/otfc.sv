///////////////////////////////////////////
// otfc.sv
//
// Written: me@KatherineParry.com, cturek@hmc.edu 
// Modified:7/14/2022
//
// Purpose: On the fly conversion
// 
// A component of the Wally configurable RISC-V project.
// 
// Copyright (C) 2021 Harvey Mudd College & Oklahoma State University
//
// MIT LICENSE
// Permission is hereby granted, free of charge, to any person obtaining a copy of this 
// software and associated documentation files (the "Software"), to deal in the Software 
// without restriction, including without limitation the rights to use, copy, modify, merge, 
// publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons 
// to whom the Software is furnished to do so, subject to the following conditions:
//
//   The above copyright notice and this permission notice shall be included in all copies or 
//   substantial portions of the Software.
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
//   INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
//   PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS 
//   BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
//   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE 
//   OR OTHER DEALINGS IN THE SOFTWARE.
////////////////////////////////////////////////////////////////////////////////////////////////

`include "wally-config.vh"

module otfc2 (
  input  logic         qp, qz,
  input  logic [`QLEN-1:0] Q, QM,
  output logic [`QLEN-1:0] QNext, QMNext
);
  //  The on-the-fly converter transfers the quotient 
  //  bits to the quotient as they come.
  //  Use this otfc for division only.
  logic [`QLEN-2:0] QR, QMR;

  assign QR  = Q[`QLEN-2:0];
  assign QMR = QM[`QLEN-2:0];     // Shifted Q and QM

  always_comb begin
    if (qp) begin
      QNext  = {QR,  1'b1};
      QMNext = {QR,  1'b0};
    end else if (qz) begin
      QNext  = {QR,  1'b0};
      QMNext = {QMR, 1'b1};
    end else begin        // If qp and qz are not true, then qn is
      QNext  = {QMR, 1'b1};
      QMNext = {QMR, 1'b0};
    end 
  end

endmodule


module otfc4 (
  input  logic [3:0]   q,
  input  logic [`QLEN-1:0] Q, QM,
  output logic [`QLEN-1:0] QNext, QMNext
);

  //  The on-the-fly converter transfers the quotient 
  //  bits to the quotient as they come. 
  //
  //  This code follows the psuedocode presented in the 
  //  floating point chapter of the book. Right now, 
  //  it is written for Radix-4 division.
  //
  //  QM is Q-1. It allows us to write negative bits 
  //  without using a costly CPA. 

  //  QR and QMR are the shifted versions of Q and QM.
  //  They are treated as [N-1:r] size signals, and 
  //  discard the r most significant bits of Q and QM. 
  logic [`QLEN-3:0] QR, QMR;

  // shift Q (quotent) and QM (quotent-1)
		// if 	q = 2  	    Q = {Q, 10} 	QM = {Q, 01}		
		// else if 	q = 1   Q = {Q, 01} 	QM = {Q, 00}	
		// else if 	q = 0   Q = {Q, 00} 	QM = {QM, 11}	
		// else if 	q = -1	Q = {QM, 11} 	QM = {QM, 10}
		// else if 	q = -2	Q = {QM, 10} 	QM = {QM, 01}

  assign QR  = Q[`QLEN-3:0];
  assign QMR = QM[`QLEN-3:0];     // Shifted Q and QM
  always_comb begin
    if (q[3]) begin // +2
      QNext  = {QR,  2'b10};
      QMNext = {QR,  2'b01};
    end else if (q[2]) begin // +1
      QNext  = {QR,  2'b01};
      QMNext = {QR,  2'b00};
    end else if (q[1]) begin // -1
      QNext  = {QMR,  2'b11};
      QMNext = {QMR,  2'b10};
    end else if (q[0]) begin // -2
      QNext  = {QMR,  2'b10};
      QMNext = {QMR,  2'b01};
    end else begin           // 0
      QNext  = {QR,  2'b00};
      QMNext = {QMR, 2'b11};
    end 
  end
  // Final Qmeint is in the range [.5, 2)

endmodule