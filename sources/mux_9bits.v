`timescale 1ns / 1ps

/*******************************************************************
*
* Module: Datapath.v
* Project: Pipelined-RISCV
* Author1: Yahya Abbas.
* Email: yahya-abbas@aucegypt.edu
* Author2: Ali Ghazal.
* Email: AliGhazal@aucegypt.edu
* Author3: Omer Hassan.
* Email: omermosa@aucegypt.edu
* Description: Pipelined RISCV processor with support for RV32IC instructions that map to true 32I instructions
*              and support for the full RV32IM instruction set.
* Change history:
**********************************************************************/

module mux_9bits(
    input [8:0] x, 
    input [8:0] y, 
    input s, 
    output [8:0] out);

wire [8:0] innerOut;

genvar i;
generate
    for ( i =0; i < 9; i = i+1) begin
        MUX2by1 mm (.A(x[i]), .B(y[i]), .S(s), .C(innerOut[i]));
    end
endgenerate

assign out = innerOut;
endmodule
