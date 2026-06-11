`ifndef PIPELINE
`include "common.sv"
`define PIPELINE
typedef struct packed {
  logic [31:0] inst;
  logic [31:0] pc;
} if_id_t;

typedef struct packed {
  logic [31:0]  inst;
  control_sig_t ctrl;
  logic [31:0]  pc;
  logic [31:0]  rd1;
  logic [31:0]  rd2;
  logic [31:0]  imm;
  logic [4:0]   rs1;
  logic [4:0]   rs2;
  logic [4:0]   rd;
} id_ex_t;


typedef struct packed {
  logic [31:0]  inst;
  control_sig_t ctrl;
  logic [31:0]  pc;
  logic [31:0]  alu_out;
  logic [31:0]  rd2;
  logic [4:0]   rd;
  logic [4:0]   rs1;
  logic [4:0]   rs2;
} ex_mem_t;


typedef struct packed {
  logic [31:0]  inst;
  control_sig_t ctrl;
  logic [31:0]  pc;
  logic [31:0]  alu_out;
  logic [31:0]  read_data;
  logic [4:0]   rd;
  logic [4:0]   rs1;
  logic [4:0]   rs2;
} mem_wb_t;

`endif
