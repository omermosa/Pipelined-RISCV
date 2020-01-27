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


module memory(
    input clk, 
    input clk_out, 
    input rst, 
    input [1:0] PCsrc, 
    input [2:0] func3, 
    input MemRead,
    input MemWrite, 
    input [8:0]addr,  
    input [8:0] addr2, 
    input [31:0] data_in, 
    output reg isInst,
    output reg [31:0] inst, 
    output reg [31:0] data_out);
/* inst <- input [5:0] addr, output [31:0] data_out
 data <-  (input clk,input [2:0] func3, input MemRead, input MemWrite, input [7:0] addr, input [31:0] data_in, output reg [31:0] data_out)*/

reg [7:0] mem [0:511];

always @ (posedge clk ) begin
     if 
        (rst) isInst=1'b0;
     else 
        isInst = ~isInst;    
end
    
always @ (negedge clk_out) begin
      inst = {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};      
end
    
always @ (posedge clk_out) begin 
    if (MemWrite) begin
         case (func3)
             3'b000: begin
                 mem[200+addr2] = data_in[7:0];
             end
             3'b001: begin
                 mem[200+addr2] = data_in[7:0];
                 mem[200+addr2+1] = data_in[15:8];
             end
             3'b010: begin
                 mem[200+addr2] = data_in[7:0];
                 mem[200+addr2+1] = data_in[15:8];
                 mem[200+addr2+2] = data_in[23:16];
                 mem[200+addr2+3] = data_in[31:24];
             end
             default: begin
                 mem[200+addr2] = data_in[7:0];
             end
         endcase   
    end 
    else begin
        mem[200+addr2] =   mem[200+addr2]; 
    end        
       
    if (MemRead) begin
        case (func3)
            3'b000: data_out =  {{24{mem[200+addr2][7]}}, mem[200+addr2]};
            3'b001: data_out =  {{16{mem[200+addr2+1][7]}}, mem[200+addr2+1], mem[200+addr2]};
            3'b010: data_out =  {mem[addr2+203], mem[addr2+202], mem[addr2+201], mem[addr2+200]};
            3'b100: data_out =  {{24{1'b0}}, mem[200+addr2]};
            3'b101: data_out =  {16'b0000000000000000, mem[200+addr2+1], mem[200+addr2]};
            default: data_out = {{24{mem[200+addr2][7]}}, mem[200+addr2]};
        endcase
    end 
    else begin
        data_out = 32'd0;
    end       
end

 

always @(*) begin

    {mem[3],  mem[2],  mem[1],  mem[0]} = 32'b000000000000_00000_010_00001_0000011 ; //lw x1, 0(x0)
    {mem[7],  mem[6],  mem[5],  mem[4]} = 32'b000000000100_00000_010_00010_0000011 ; //lw x2, 4(x0)
    {mem[11], mem[10], mem[9],  mem[8]} = 32'b000000001000_00000_010_00011_0000011 ; //lw x3, 8(x0)
    {mem[15], mem[14], mem[13], mem[12]} = 32'b0000000_00010_00001_110_00100_0110011 ; //or x4, x1, x2
    {mem[19], mem[18], mem[17], mem[16]} = 32'b0_000000_00011_00100_000_0100_0_1100011; //beq x4, x3, 4 
    {mem[23], mem[22], mem[21], mem[20]} = 32'b0000000_00010_00001_000_00011_0110011 ; //add x3, x1, x2
    {mem[27], mem[26], mem[25], mem[24]} = 32'b0000000_00010_00011_000_00101_0110011 ; //add x5, x3, x2
    {mem[31], mem[30], mem[29], mem[28]} = 32'b0000000_00000_00000_000_00000_0110011 ; //add x0, x0, x0
    {mem[35], mem[34], mem[33], mem[32]} = 32'b0000000_00101_00000_010_01100_0100011; //sw x5, 12(x0)
    {mem[39], mem[38], mem[37], mem[36]} = 32'b000000001100_00000_010_00110_0000011 ; //lw x6, 12(x0)
    {mem[43], mem[42], mem[41], mem[40]} = 32'b0000000_00001_00110_111_00111_0110011 ; //and x7, x6, x1
    {mem[47], mem[46], mem[45], mem[44]} = 32'b0100000_00010_00001_000_01000_0110011 ; //sub x8, x1, x2
    {mem[51], mem[50], mem[49], mem[48]} = 32'b0000000_00010_00001_000_00000_0110011 ; //add x0, x1, x2
    {mem[55], mem[54], mem[53], mem[52]} = 32'b0000000_00001_00000_000_01001_0110011 ; //add x9, x0, x1
    
    
    {mem[59], mem[58], mem[57], mem[56]} = 32'b000_1_10001_00000_01_010_000_000_00_010_00 ; //C.ADDI x17,32-C.LW x2,0x0)
    
    {mem[63], mem[62], mem[61], mem[60]} = 32'hfe000093 ; //add x1, x0, -32
    
    {mem[67], mem[66], mem[65], mem[64]} = 32'h00001537;//lui x10, 1  
    
    {mem[71], mem[70], mem[69], mem[68]}=32'h00000583; //lb x11, 0(x0)   
    {mem[75], mem[74], mem[73], mem[72]}=32'h00401603;//lh x12, 4(x0)
    {mem[79], mem[78], mem[77], mem[76]}=32'h00802683;//lw x13, 8(x0) 
    
    {mem[83], mem[82], mem[81], mem[80]}=32'hffe6f693;// andi x13, x13, -2 
    {mem[87], mem[86], mem[85], mem[84]}=32'h06460713;//addi x14, x12, 100 
    {mem[91], mem[90], mem[89], mem[88]}=32'h00f56513;//ori x10,x10,  15  
    
    {mem[95], mem[94], mem[93], mem[92]}=32'h00351513;//  slli x10, x10, 3  
    
    {mem[99], mem[98], mem[97], mem[96]}=32'h02100793;// addi x15, x0, 33
    {mem[103], mem[102], mem[101], mem[100]}=32'h02100813;//   addi x16, x0, 33
    
    {mem[107], mem[106], mem[105], mem[104]}=32'h01078663;//beq x15, x16, there(6) 
    
    {mem[111], mem[110], mem[109], mem[108]}=32'h03200593;//  addi x11, x0, 50 
    {mem[115], mem[114], mem[113], mem[112]}=32'h03c00613;//  addi x12, x0, 60
        
    {mem[119], mem[118], mem[117], mem[116]}=32'h40c588b3;// sub x17, x11, x12
    
    {mem[123], mem[122], mem[121], mem[120]}=32'h01102423;//   sw x17, 8(x0)  
    {mem[127], mem[126], mem[125], mem[124]}=32'h00a01623;//sh x10, 12(x0)
    
    {mem[131], mem[130], mem[129], mem[128]}=32'h01600913;//  addi x18, x0, 22 
    {mem[135], mem[134], mem[133], mem[132]}=32'h00f00993;//  addi x19, x0, 15 
    
    {mem[139], mem[138], mem[137], mem[136]}=32'h03390a33;//  mul  x20, x18, x19  
    
    {mem[143], mem[142], mem[141], mem[140]}=32'h01600913;// addi x18, x0, 22 
    {mem[147], mem[146], mem[145], mem[144]}=32'h00f00993;//addi x19, x0, 15
    
    {mem[151], mem[150], mem[149], mem[148]}=32'h03393a33 ;// mulh  x20, x18, x19    
    
    {mem[155], mem[154], mem[153], mem[152]}=32'hfff00913;// addi x18, x0, -1 
    {mem[159], mem[158], mem[157], mem[156]}=32'h00800993;//  addi x19, x0, 8 
    
    {mem[163], mem[162], mem[161], mem[160]}=32'h03393a33;//   mulhu  x20, x18, x19
        
    {mem[167], mem[166], mem[165], mem[164]}=32'h01400913;// addi x18, x0, 20
    {mem[171], mem[170], mem[169], mem[168]}=32'h00400993;// addi x19, x0, 4 
    
    {mem[175], mem[174], mem[173], mem[172]}=32'h03394a33;//  div  x20, x18, x19
    
    {mem[179], mem[178], mem[177], mem[176]}=32'h01400913;// addi x18, x0, 20  
    {mem[183], mem[182], mem[181], mem[180]}=32'h00600993;//addi x19, x0, 6 
    
    {mem[187], mem[186], mem[185], mem[184]}=32'h03396a33;//rem  x20, x18, x19
    
    { mem[189], mem[188]}=16'b010_0_01001_10001_01;//  C.LI  x9, 17
    { mem[191], mem[190]}=16'b100_0_01_001_00010_01; // C.SRAI  x9, 2
    { mem[193], mem[192]}=16'b111_0_00_001_00_11_0_01 ;// C.BNEZ  x9, 3
    
    {mem[197], mem[196], mem[195], mem[194]} = 32'b0000000_00000_00000_000_00000_0110011 ; //add x0, x0, x0

     
//    {mem[75], mem[74], mem[73], mem[72]} = 32'b0000000_00000_00000_000_00000_0110011 ; //add x0, x0, x0
     
    mem[200] = 8'd33;    
    mem[201] = 8'b00000000;
    mem[202] = 8'b00000000;
    mem[203] = 8'b00000000;
    
    mem[204] = 8'd13;
    mem[205] = 8'b00000000;
    mem[206] = 8'b00000000;
    mem[207] = 8'b00000000;
    
    mem[208] = 8'd0;
    mem[209] = 8'b00000000;
    mem[210] = 8'b00000000;
    mem[211] = 8'b00000000;   
end

endmodule
