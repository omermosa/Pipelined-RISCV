`define     IR_rs1          19:15
`define     IR_rs2          24:20
`define     IR_rd           11:7
`define     IR_opcode       6:2
`define     IR_funct3       14:12
`define     IR_funct7       31:25
`define     IR_shamt        24:20
`define     IR_csr          31:20


`define     OPCODE_Branch   5'b11_000
`define     OPCODE_Load     5'b00_000
`define     OPCODE_Store    5'b01_000
`define     OPCODE_JALR     5'b11_001
`define     OPCODE_JAL      5'b11_011
`define     OPCODE_Arith_I  5'b00_100
`define     OPCODE_Arith_R  5'b01_100
`define     OPCODE_AUIPC    5'b00_101
`define     OPCODE_LUI      5'b01_101
`define     OPCODE_SYSTEM   5'b11_100 
`define     OPCODE_Custom   5'b00_011

`define     F3_ADD_MUL      3'b000
`define     F3_SLL_MULH     3'b001
`define     F3_SLT_MULHSU   3'b010
`define     F3_SLTU_MULHU   3'b011
`define     F3_XOR_DIV      3'b100
`define     F3_SRL_DIVU     3'b101
`define     F3_OR_REM       3'b110
`define     F3_AND_REMU     3'b111

`define     BR_BEQ          3'b000
`define     BR_BNE          3'b001
`define     BR_BLT          3'b100
`define     BR_BGE          3'b101
`define     BR_BLTU         3'b110
`define     BR_BGEU         3'b111

`define     OPCODE          inst[`IR_opcode]


`define     ALU_AND         4'b00_00
`define     ALU_ADD         4'b00_01
`define     ALU_OR          4'b00_10
`define     ALU_XOR         4'b00_11
`define     ALU_SLL         4'b01_00
`define     ALU_SUB         4'b01_10
`define     ALU_SRL         4'b01_01
`define     ALU_SRA         4'b01_11
`define     ALU_SLT         4'b10_00
`define     ALU_PASS        4'b10_01
`define     ALU_MUL         4'b10_10
`define     ALU_MULHX       4'b10_11
`define     ALU_SLTU        4'b11_00
`define     ALU_DIVX        4'b11_01
`define     ALU_REMX        4'b11_11


`define     SYS_EC_EB       3'b000
`define     SYS_CSRRW       3'b001
`define     SYS_CSRRS       3'b010
`define     SYS_CSRRC       3'b011
`define     SYS_CSRRWI      3'b101
`define     SYS_CSRRSI      3'b110
`define     SYS_CSRRCI      3'b111