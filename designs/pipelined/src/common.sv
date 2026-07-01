`ifndef COMMON
`define COMMON
typedef enum logic [3:0] {
  ALU_ADD,
  ALU_SUB,
  ALU_AND,
  ALU_OR,
  ALU_XOR,
  ALU_SLL,
  ALU_SRL,
  ALU_SRA,
  ALU_SLT,
  ALU_SLTU,
  ALU_PASS_2,
  MUL,
  MUL_H,
  MUL_HSU,
  MUL_HU
} alu_ctrl_t;

typedef struct packed {
  logic [1:0] pc_type;  //00=normal 01=B-Type 10=JAL 11=JALR
  logic [1:0] result_src;  //00=aluresult 01=readdata 10=pc+4
  logic mem_write;
  logic mem_read;
  logic alu_src1;  //rs1 or pc
  logic alu_src2;  //rs2 or imm
  logic reg_write;
  logic [2:0] funct3;
  alu_ctrl_t alu_op;
} control_sig_t;
`endif
