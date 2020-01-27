`timescale 1ns / 1ps
`include "defines.vh"

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

module Datapath_final(
    input clk, 
    output reg [3:0] Anode, 
    output reg [6:0] LED_out ,
    input RiscV_clk, 
    input rst, 
    input [1:0] ledSel, 
    input [3:0] ssdSel, 
    output reg [15:0] LEDs);
wire [3:0] An; wire [6:0] Ledout;
wire[15:0] leds; wire [12:0] SSD;

Datapath RiscV(RiscV_clk,rst,ledSel,ssdSel,leds,SSD);
Disp Seg(clk,SSD,An,Ledout);

always @(*) begin 
    Anode=An;
    LED_out=Ledout;
    LEDs=leds;
end

endmodule
