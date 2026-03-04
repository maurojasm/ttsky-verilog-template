/*
 * Copyright (c) 2024 Mauricio Rojas
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_marojasm_alu (
    input  wire [7:0] ui_in,    // Dedicated inputs  -- 8 bit A input
    output wire [7:0] uo_out,   // Dedicated outputs -- 8 bit result
    input  wire [7:0] uio_in,   // IOs: Input path   -- [7:3] 5 bit B input, [2:0] 3 bit opcode
    output wire [7:0] uio_out,  // IOs: Output path  -- [7] 1 bit carry out
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  wire [2:0] opcode;
  wire [7:0] A;
  wire [7:0] B;
  wire [8:0] adder_out;
  wire [8:0] sub_out;

  reg [7:0] out;
  reg [0:0] carry_out;

  assign A = ui_in;
  assign B = {3'b0, uio_in[7:3]};

  assign opcode = uio_in[2:0];

  assign adder_out = {1'b0, A} + {1'b0, B};
  assign sub_out = {1'b0, A} - {1'b0, B};

  always @(posedge clk) begin
    if(!rst_n) begin
      out <= 8'b0;
      carry_out <= 1'b0;
    end
    else begin
      case (opcode)
        3'b000: // add
        begin
          out <= adder_out[7:0];
          carry_out <= adder_out[8];
        end
        3'b001: // sub
        begin
          out <= sub_out[7:0];
          carry_out <= sub_out[8];
        end
        3'b010: // not A
        begin
          out <= ~A;
          carry_out <= 0;
        end
        3'b011: // and
        begin
          out <= A & B;
          carry_out <= 1'b0;
        end
        3'b100: // or
        begin
          out <= A | B;
          carry_out <= 1'b0;
        end
        3'b101: // xor
        begin
          out <= A ^ B;
          carry_out <= 1'b0;
        end
        3'b110: // A sll
        begin
          out <= {A[6:0], 1'b0};
          carry_out <= 1'b0;
        end
        3'b111: // A passthrough
        begin
          out <= A;
          carry_out <= 1'b0;
        end
        default: begin
            out <= 8'b0;
            carry_out <= 1'b0;
        end
      endcase
    end
  end


  // All output pins must be assigned. If not used, assign to 0.
  // assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  assign uo_out = out;
  assign uio_out = {carry_out, 7'b0};
  assign uio_oe  = {1'b1, 7'b0};

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, 1'b0};

endmodule
