<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

The project is a simple 8-bit ALU with 8 operations. The ALU expects two inputs, 8-bit A (from ui_in) and 5-bit B (extends to 8-bit), and a 3-bit operational code (both from uio_in). The outputs are as follows: uo_out will have the 8-bit result of the given operation and the carry_out will be placed in the uio_out path at the 8th bit.

## How to test

Given ui_in for input A, uio_in[7:3] for input B, and uio_in[2:0] for opcode the result is as follows:

Opcode  Operation   Result
000     ADD         A + B, carry_out
001     SUB         A - B, carry_out
010     NOT A       ~A
011     AND         A & B
100     OR          A | B
101     XOR         A ^ B
110     SLL         shift logical left A
111     PASS        passthrough A

## External hardware

No external hardware needed. Implemented only ALU cell.
