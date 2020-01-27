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

module ALU32bit (
    input [31:0] in1, 
    input [31:0] in2, 
    input [1:0] signed_unsigned, 
    input [3:0] aluSel, 
    output reg [31:0] result,
    output wire zero_flag,
    output wire carry_flag, 
    output wire overflow_flag, 
    output wire sign_flag);

wire [31:0] add_out, mulh_out, mulhu_out,mulhus_out;
wire[31:0] not_in2;

mulh mulh_mod (.in1(in1), .in2(in2), .out(mulh_out));
mulhu mulhu_mod (.in1(in1), .in2(in2), .out(mulhu_out));
mulhus mulhus_mod (.in1(in1), .in2(in2), .out(mulhus_out));

assign not_in2=~in2;
assign {carry_flag, add_out} = ~aluSel[0] ? (in1 + not_in2 + 1'b1) : (in1 + in2);

always @(*) begin
    case(aluSel)
        `ALU_AND: result = in1 & in2;
        `ALU_OR: result = in1 | in2;
        `ALU_ADD: result = add_out;
        `ALU_XOR: result = in1 ^ in2;
        `ALU_SLL: result = in1 << in2;
        `ALU_SRL: result = in1 >> in2;
        `ALU_SUB: result = add_out;
        `ALU_SRA: result = in1 >>> in2;
        `ALU_SLT: result = {31'b0, (sign_flag != overflow_flag)}; // slti, slt
        `ALU_PASS:result=in2;
        `ALU_SLTU:result={31'b0,~carry_flag};//sltu
        `ALU_MUL: result = $signed(in1) * $signed(in2) ;
        `ALU_MULHX: begin
            case (signed_unsigned)
                2'b00: result =  mulh_out;
                2'b01: result =  mulhu_out;
                2'b10: result = mulhus_out ;
                default: result = mulhus_out ;
            endcase
        end
        `ALU_DIVX: begin
            case (signed_unsigned)
                2'b00: result = $signed(in1) / $signed(in2) ;
                2'b01: result =  $unsigned(in1) / $unsigned(in2) ;
                default: result =  $unsigned(in1) / $unsigned(in2) ;
            endcase
         end  
        `ALU_REMX: begin
            case (signed_unsigned)
                2'b00: result = $signed(in1) % $signed(in2) ;
                2'b01: result =  $unsigned(in1) % $unsigned(in2) ;
                default: result =  $unsigned(in1) % $unsigned(in2) ;
            endcase
         end          
         default: result = 32'b0;
    endcase
end

assign zero_flag = (result == 0);
assign sign_flag=result[31]; //result or add_out??
assign overflow_flag=(in1[31]^not_in2[31]^result[31]^carry_flag);

endmodule