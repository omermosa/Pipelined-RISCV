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

module Hazard_Detection(
    input [4:0] IF_ID_RegisterRs1, 
    input [4:0] IF_ID_RegisterRs2, 
    input [4:0] ID_EX_RegisterRd,
    input ID_EX_MemRead, 
    output Stall);

assign Stall = (((IF_ID_RegisterRs1 == ID_EX_RegisterRd) || (IF_ID_RegisterRs2 == ID_EX_RegisterRd))
    && (ID_EX_MemRead) && (ID_EX_RegisterRd != 0)) ? 1 : 0;
   
endmodule