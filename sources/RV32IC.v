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

module RV32IC(
    input [31:0] in, 
    output [31:0] out, 
    output reg Is_compressed);

reg [15:0] compressed_inst;
reg [31:0] decompressed_inst;

always @(in) begin
    if(in[1:0] == 2'b11) begin
        Is_compressed = 0;
        compressed_inst = {16{1'b0}};
    end 
    else begin
        compressed_inst = in[15:0];
        Is_compressed = 1;
    end
end

always @(compressed_inst) begin
    if(compressed_inst[1:0] == 2'b00) begin
        case(compressed_inst[15:14])
            2'b01:  begin   //C.LW
                decompressed_inst = {{5{1'b0}}, compressed_inst[5], compressed_inst[12:10], compressed_inst[6], 2'b00,  2'b01, compressed_inst[9:7], compressed_inst[15:13], 2'b01, compressed_inst[4:2], 7'b0000011};
            end
            2'b11:  begin   //C.SW
                decompressed_inst = {{5{1'b0}}, compressed_inst[5], compressed_inst[12], 2'b01, compressed_inst[4:2], 2'b01, compressed_inst[9:7], 3'b010, compressed_inst[11:10], compressed_inst[6], 2'b00, 7'b0100011};
            end
            default: begin  //C.SW
                decompressed_inst = {{5{1'b0}}, compressed_inst[5], compressed_inst[12], 2'b01, compressed_inst[4:2], 2'b01, compressed_inst[9:7], 3'b010, compressed_inst[11:10], compressed_inst[6], 2'b00, 7'b0100011};
            end
        endcase
    end
    
    else if(compressed_inst[1:0] == 2'b01) begin
        if(compressed_inst[15:13] == 3'b000) begin
            if(compressed_inst[11:7] == {5{1'b0}}) begin
                decompressed_inst = {{25{1'b0}}, 7'b0010011}; //C.NOP
            end
            else begin  //C.ADDI
                decompressed_inst = {{6{1'b0}}, compressed_inst[12], compressed_inst[6:2], compressed_inst[11:7], 3'b000, compressed_inst[11:7], 7'b0010011};
            end
        end
        else if(compressed_inst[15:13] == 3'b001) begin //C.JAL
            decompressed_inst = {1'b0, compressed_inst[8], compressed_inst[10:9], compressed_inst[6], compressed_inst[7], compressed_inst[2], compressed_inst[11], compressed_inst[5:3], compressed_inst[12], {8{1'b0}}, 5'b00001, 7'b1101111};
        end        
        else if (compressed_inst[15:13] == 3'b010) begin    //C.LI
            decompressed_inst = {{6{1'b0}}, compressed_inst[12], compressed_inst[6:2], 5'b00000, 3'b000, compressed_inst[11:7], 7'b0010011};
        end
        else if(compressed_inst[15:13] == 3'b011) begin //C.LUI,    rd(compressed_inst[11:7] shouldn't equal 0 or 2 as it is reserved
            decompressed_inst = {{14{1'b0}}, compressed_inst[12], compressed_inst[6:2], compressed_inst[11:7], 7'b0110111};
        end
        else if(compressed_inst[15:13] == 3'b100) begin
            if(compressed_inst[11:10] == 2'b11) begin
                case(compressed_inst[6:5])
                    2'b00:  begin   //C.SUB
                        decompressed_inst = {7'b0100000, 2'b01, compressed_inst[4:2], 2'b01, compressed_inst[9:7], 3'b000, 2'b01, compressed_inst[9:7], 7'b0110011};
                    end
                    2'b01:  begin   //C.XOR
                        decompressed_inst = {7'b0000000, 2'b01, compressed_inst[4:2], 2'b01, compressed_inst[9:7], 3'b100, 2'b01, compressed_inst[9:7], 7'b0110011};
                    end
                    2'b10:  begin   //C.OR
                        decompressed_inst = {7'b0000000, 2'b01, compressed_inst[4:2], 2'b01, compressed_inst[9:7], 3'b110, 2'b01, compressed_inst[9:7], 7'b0110011};
                    end
                    2'b11:  begin   //C.AND
                        decompressed_inst = {7'b0000000, 2'b01, compressed_inst[4:2], 2'b01, compressed_inst[9:7], 3'b111, 2'b01, compressed_inst[9:7], 7'b0110011};
                    end
                    default: begin  //C.AND
                        decompressed_inst = {7'b0000000, 2'b01, compressed_inst[4:2], 2'b01, compressed_inst[9:7], 3'b111, 2'b01, compressed_inst[9:7], 7'b0110011};
                    end                
                endcase 
            end
            else if(compressed_inst[11:10] == 2'b10) begin  //C.ANDI
                decompressed_inst = {{6{1'b0}}, compressed_inst[12], compressed_inst[6:2], 2'b01, compressed_inst[9:7], 3'b111, 2'b01, compressed_inst[9:7], 7'b0010011};
            end
            else if(compressed_inst[11:10] == 2'b01) begin  //C.SRAI
                decompressed_inst = {7'b0100000, compressed_inst[6:2], 2'b01, compressed_inst[9:7], 3'b101, 2'b01, compressed_inst[9:7], 7'b0010011};
            end
            else begin  //C.SRLI
                decompressed_inst = {7'b0000000, compressed_inst[12], compressed_inst[6:2], 2'b01, compressed_inst[9:7], 3'b101, 2'b01, compressed_inst[9:7], 7'b0010011};
            end
        end
        else if(compressed_inst[15:13] == 3'b101) begin //C.J
            decompressed_inst = {1'b0, compressed_inst[8], compressed_inst[10:9], compressed_inst[6], compressed_inst[7], compressed_inst[2], compressed_inst[11], compressed_inst[5:3], compressed_inst[12], {8{1'b0}}, 5'b00000, 7'b1101111};
        end    
        else if(compressed_inst[15:13] == 3'b110) begin //C.BEQZ
            decompressed_inst = {3'b000, compressed_inst[12], compressed_inst[6:5], compressed_inst[2], 5'b00000, 2'b01, compressed_inst[9:7], 3'b000, compressed_inst[11:10], compressed_inst[4:3], 1'b0, 7'b1100011};
        end
        else begin //C.BNEZ
            decompressed_inst = {3'b000, compressed_inst[12], compressed_inst[6:5], compressed_inst[2], 5'b00000, 2'b01, compressed_inst[9:7], 3'b001, compressed_inst[11:10], compressed_inst[4:3], 1'b0, 7'b1100011};
        end        
    end
    
    else if(compressed_inst[1:0] == 2'b10) begin
        if(compressed_inst[15:13] == 3'b000) begin  //C.SLLI
            decompressed_inst = {7'b0000000, compressed_inst[12], compressed_inst[6:2], compressed_inst[11:7], 3'b001 ,compressed_inst[11:7], 7'b0010011};
        end
        else begin
            if(compressed_inst[12] == 1'b0) begin   //C.MV
                decompressed_inst = {7'b0000000, compressed_inst[6:2], 5'b00000, 3'b000, compressed_inst[11:7], 7'b0110011};
            end
            else begin
                if(compressed_inst[11:7] == {5{1'b0}} && compressed_inst[6:2] == {5{1'b0}}) begin
                    decompressed_inst = 32'b000000000001_00000_000_00000_1110011;   //C.EBREAK
                end
                else if(compressed_inst[6:2] == {5{1'b0}}) begin    //C.JALR
                    decompressed_inst = {{12{1'b0}}, compressed_inst[11:7], 3'b000, 5'b00001, 7'b1100111};
                end
                else begin  //C.ADD
                    decompressed_inst = {7'b0000000, compressed_inst[6:2], compressed_inst[11:7], 3'b000, compressed_inst[11:7], 7'b0110011};
                end
            end
        end
    end
    else begin
        decompressed_inst = {32{1'b0}};
    end
end

assign out = (in[1:0] == 2'b11) ? in : decompressed_inst;
endmodule