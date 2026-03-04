`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb ();

  // Dump the signals to a FST file. You can view it with gtkwave or surfer.
  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb);
    #1;
  end

  // Wire up the inputs and outputs:
  reg clk = 0;
  reg rst_n = 0;
  reg ena = 1'b1;
  reg [7:0] ui_in;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;
`ifdef GL_TEST
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
`endif

  // reference module
  // reg [7:0] B;
  reg [8:0] temp_result;
  reg [7:0] expected_out;
  reg [0:0] expected_carry;

  // wire B = {3'b0, uio_in[7:3]};

  always @(posedge clk) begin
    if(!rst_n) begin
      expected_out <= 8'b0;
      expected_carry <= 1'b0;
    end
    else begin
      case (uio_in[2:0])
        3'b000: begin // add
          temp_result <= {1'b0,ui_in} + {4'b0, uio_in[7:3]};
          expected_out <= temp_result[7:0];
          expected_carry <= temp_result[8];
        end
        3'b001: begin // sub
          temp_result <= {1'b0,ui_in} - {4'b0, uio_in[7:3]};
          expected_out <= temp_result[7:0];
          expected_carry <= temp_result[8];
        end
        3'b010: begin // not A
          expected_out <=  ~ui_in & 8'hFF;
          expected_carry <= 0;
        end
        3'b011: begin // and
          expected_out <= ui_in & {3'b0, uio_in[7:3]};;
          expected_carry <= 0;
        end
        3'b100: begin // or
          expected_out <= ui_in | {3'b0, uio_in[7:3]};;
          expected_carry <= 0;
        end
        3'b101: begin // xor
          expected_out <= ui_in ^ {3'b0, uio_in[7:3]};;
          expected_carry <= 0;
        end
        3'b110: begin // sll
          expected_out <= {ui_in[6:0], 1'b0};
          expected_carry <= 0;
        end
        3'b111: begin // pass A
          expected_out <= ui_in;
          expected_carry <= 0;
        end
      endcase
    end
  end

  // Replace tt_um_example with your module name:
  // dut
  tt_um_marojasm_alu user_project (

      // Include power ports for the Gate Level test:
`ifdef GL_TEST
      .VPWR(VPWR),
      .VGND(VGND),
`endif

      .ui_in  (ui_in),    // Dedicated inputs
      .uo_out (uo_out),   // Dedicated outputs
      .uio_in (uio_in),   // IOs: Input path
      .uio_out(uio_out),  // IOs: Output path
      .uio_oe (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
      .ena    (ena),      // enable - goes high when design is selected
      .clk    (clk),      // clock
      .rst_n  (rst_n)     // not reset
  );

  always #100 clk = ~clk; // T = 200ns ~ 5 MHz

  initial begin
    // reset
    #10
    rst_n = 0;
    ui_in = 0;
    uio_in = 0;

    #500
    rst_n = 1;
    // add
    ui_in = 8'd15;
    uio_in = {5'd7, 3'b000};
    #10
    if (uo_out !== expected_out) begin
      $display("ERROR: opcode=%b A=%d B=%d Expected=%d Got=%d", uio_in[2:0], ui_in, uio_in[7:3], expected_out, uo_out);
      // $fatal;
    end
    if (uio_out[7] !== expected_carry) begin
      $display("ERROR: Carry mismatch opcode=%b A=%d B=%d Expected carry=%b Got carry=%b", uio_in[2:0], ui_in, uio_in[7:3], expected_carry, uio_out[7]);
      // $fatal;
    end

    #200
    // sub
    ui_in = 8'd20;
    uio_in = {5'd3, 3'b001};
    #10
    if (uo_out !== expected_out) begin
      $display("ERROR: opcode=%b A=%d B=%d Expected=%d Got=%d", uio_in[2:0], ui_in, uio_in[7:3], expected_out, uo_out);
      // $fatal;
    end
    if (uio_out[7] !== expected_carry) begin
      $display("ERROR: Carry mismatch opcode=%b A=%d B=%d Expected carry=%b Got carry=%b", uio_in[2:0], ui_in, uio_in[7:3], expected_carry, uio_out[7]);
      // $fatal;
    end

    #200
    // not A
    ui_in = 8'b11110000;
    uio_in = {5'd0, 3'b010};
    #10
    if (uo_out !== expected_out) begin
      $display("ERROR: opcode=%b A=%d B=%d Expected=%b Got=%b", uio_in[2:0], ui_in, uio_in[7:3], expected_out, uo_out);
      // $fatal;
    end
    if (uio_out[7] !== expected_carry) begin
      $display("ERROR: Carry mismatch opcode=%b A=%d B=%d Expected carry=%b Got carry=%b", uio_in[2:0], ui_in, uio_in[7:3], expected_carry, uio_out[7]);
      // $fatal;
    end

    #200
    // and
    ui_in = 8'b10101010;
    uio_in = {5'b11111, 3'b011};
    #10
    if (uo_out !== expected_out) begin
      $display("ERROR: opcode=%b A=%d B=%d Expected=%d Got=%d", uio_in[2:0], ui_in, uio_in[7:3], expected_out, uo_out);
      // $fatal;
    end
    if (uio_out[7] !== expected_carry) begin
      $display("ERROR: Carry mismatch opcode=%b A=%d B=%d Expected carry=%b Got carry=%b", uio_in[2:0], ui_in, uio_in[7:3], expected_carry, uio_out[7]);
      // $fatal;
    end

    #200
    // or
    ui_in = 8'd20;
    uio_in = {5'd3, 3'b100};
    #10
    if (uo_out !== expected_out) begin
      $display("ERROR: opcode=%b A=%d B=%d Expected=%d Got=%d", uio_in[2:0], ui_in, uio_in[7:3], expected_out, uo_out);
      // $fatal;
    end
    if (uio_out[7] !== expected_carry) begin
      $display("ERROR: Carry mismatch opcode=%b A=%d B=%d Expected carry=%b Got carry=%b", uio_in[2:0], ui_in, uio_in[7:3], expected_carry, uio_out[7]);
      // $fatal;
    end

    #200
    // xor
    ui_in = 8'd20;
    uio_in = {5'd3, 3'b101};
    #10
    if (uo_out !== expected_out) begin
      $display("ERROR: opcode=%b A=%d B=%d Expected=%d Got=%d", uio_in[2:0], ui_in, uio_in[7:3], expected_out, uo_out);
      // $fatal;
    end
    if (uio_out[7] !== expected_carry) begin
      $display("ERROR: Carry mismatch opcode=%b A=%d B=%d Expected carry=%b Got carry=%b", uio_in[2:0], ui_in, uio_in[7:3], expected_carry, uio_out[7]);
      // $fatal;
    end

    #200
    // sll
    ui_in = 8'd20;
    uio_in = {5'd0, 3'b110};
    #10
    if (uo_out !== expected_out) begin
      $display("ERROR: opcode=%b A=%d B=%d Expected=%d Got=%d", uio_in[2:0], ui_in, uio_in[7:3], expected_out, uo_out);
      // $fatal;
    end
    if (uio_out[7] !== expected_carry) begin
      $display("ERROR: Carry mismatch opcode=%b A=%d B=%d Expected carry=%b Got carry=%b", uio_in[2:0], ui_in, uio_in[7:3], expected_carry, uio_out[7]);
      // $fatal;
    end

    #200
    // pass
    ui_in = 8'd20;
    uio_in = {5'd0, 3'b111};
    #10
    if (uo_out !== expected_out) begin
      $display("ERROR: opcode=%b A=%d B=%d Expected=%d Got=%d", uio_in[2:0], ui_in, uio_in[7:3], expected_out, uo_out);
      // $fatal;
    end
    if (uio_out[7] !== expected_carry) begin
      $display("ERROR: Carry mismatch opcode=%b A=%d B=%d Expected carry=%b Got carry=%b", uio_in[2:0], ui_in, uio_in[7:3], expected_carry, uio_out[7]);
      // $fatal;
    end

    #200
    ui_in = 8'd0;
    uio_in = {5'd0, 3'b000};

    $finish;
  end
endmodule
