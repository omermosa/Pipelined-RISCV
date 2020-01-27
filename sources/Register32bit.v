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

module Register32bit #(parameter size = 32)(
    input clk, 
    input load, 
    input reset, 
    input [size-1:0] D, 
    output [size-1:0] regQ);
wire [size-1:0] muxout;
genvar i;
generate
    for (i=0; i < size; i=i+1) begin : gen1
        MUX2by1 mux(.A(regQ[i]), .B(D[i]), .S(load), .C(muxout[i]));
        DFF dff(.clk(clk), .rst(reset), .D(muxout[i]), .Q(regQ[i]));
    end
endgenerate
endmodule
