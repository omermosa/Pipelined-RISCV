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

module Forwarding_Unit(
    input EX_MEM_regwrite, 
    input MEM_WB_regwrite, 
    input [4:0] EX_MEM_rd, 
    input [4:0] MEM_WB_rd, 
    input [4:0] ID_EX_rs1, 
    input [4:0] ID_EX_rs2,
    output reg [1:0] forwardA, 
    output reg [1:0] forwardB );

/*if ( EX/MEM.RegWrite and (EX/MEM.RegisterRd ? 0)  and (EX/MEM.RegisterRd == ID/EX.RegisterRs1) )
    forwardA = 10
  if ( EX/MEM.RegWrite and (EX/MEM.RegisterRd ? 0) and (EX/MEM.RegisterRd == ID/EX.RegisterRs2) )
    forwardB = 10
if ( MEM/WB.RegWrite and (MEM/WB.RegisterRd ? 0) and (MEM/WB.RegisterRd == ID/EX.RegisterRs1) )
    and not ( EX/MEM.RegWrite and (EX/MEM.RegisterRd ? 0) and (EX/MEM.RegisterRd == ID/EX.RegisterRs1) )
        forwardA = 01
if ( MEM/WB.RegWrite and (MEM/WB.RegisterRd ? 0) and (MEM/WB.RegisterRd == ID/EX.RegisterRs2) )
    and not ( EX/MEM.RegWrite and (EX/MEM.RegisterRd ? 0) and (EX/MEM.RegisterRd == ID/EX.RegisterRs2) )
        forwardB = 01*/
        
always @(*)begin
    if (EX_MEM_regwrite && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rs1))
        forwardA=2'b10;
    else if ((MEM_WB_regwrite && (MEM_WB_rd != 0) && (MEM_WB_rd == ID_EX_rs1)) && !(EX_MEM_regwrite && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rs1)))
        forwardA=2'b01;
    else
        forwardA=2'b00;
    
    if(EX_MEM_regwrite && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rs2))
        forwardB=2'b10; 
    else if ((MEM_WB_regwrite && (MEM_WB_rd != 0) && (MEM_WB_rd == ID_EX_rs2)) && !(EX_MEM_regwrite && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rs2)))
        forwardB=2'b01;
    else
        forwardB=2'b00; 
end

endmodule
