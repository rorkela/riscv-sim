`include "common.sv"
module inst_dec (
    input logic [31:0] instruction,
    output control_sig_t ctrl,
    output logic [31:0] imm,
    output logic [4:0] rs2,
    output logic [4:0] rs1,
    output logic [4:0] rd
);
  logic [6:0] funct7;
  logic [2:0] funct3;
  logic [6:0] op;
  assign op     = instruction[6:0];
  assign rd     = instruction[11:7];
  assign funct3 = instruction[14:12];
  assign rs1    = instruction[19:15];
  assign rs2    = instruction[24:20];
  assign funct7 = instruction[31:25];
  //For R and I type, expected ALU_OP from funct3 and funct7 generation
  alu_ctrl_t alu_op_RI;
  always_comb begin
    case (funct3)
      3'b000: begin
        alu_op_RI = (op == 7'b0010011) ? (ALU_ADD) : ((funct7[5]) ? (ALU_SUB) : (ALU_ADD));
      end
      3'b001: begin
        alu_op_RI = ALU_SLL;
      end
      3'b010: begin
        alu_op_RI = ALU_SLT;
      end
      3'b011: begin
        alu_op_RI = ALU_SLTU;
      end
      3'b100: begin
        alu_op_RI = ALU_XOR;
      end
      3'b101: begin
        alu_op_RI = funct7[5] ? ALU_SRA : ALU_SRL;
      end
      3'b110: begin
        alu_op_RI = ALU_OR;
      end
      3'b111: begin
        alu_op_RI = ALU_AND;
      end
      default: begin
        alu_op_RI = ALU_ADD;
      end

    endcase
  end
  // Control signal generation
  always_comb begin
    ctrl.pc_type    = 2'b00;
    ctrl.result_src = 2'b00;
    ctrl.mem_write  = 1'b0;
    ctrl.mem_read   = 1'b0;
    ctrl.alu_src1   = 1'b0;
    ctrl.alu_src2   = 1'b0;
    ctrl.reg_write  = 1'b0;
    ctrl.alu_op     = ALU_ADD;
    ctrl.funct3     = funct3;
    case (op)
      //I type Load
      7'b0000011: begin
        ctrl.result_src = 2'b01;
        ctrl.alu_src2 = 1'b1;
        ctrl.mem_read = 1'b1;
        ctrl.reg_write = 1'b1;
        ctrl.alu_op = ALU_ADD;
      end
      //I type imm
      7'b0010011: begin
        ctrl.reg_write = 1'b1;
        ctrl.alu_src2 = 1'b1;
        ctrl.alu_op = alu_op_RI;
      end
      //U Type auipc
      7'b0010111: begin
        ctrl.reg_write = 1'b1;
        ctrl.alu_src1 = 1'b1;  // PC
        ctrl.alu_src2 = 1'b1;  // imm
        ctrl.alu_op = ALU_ADD;
      end
      //S type
      7'b0100011: begin
        ctrl.mem_write = 1'b1;
        ctrl.alu_src2 = 1'b1;
        ctrl.alu_op = ALU_ADD;
      end
      //R type
      7'b0110011: begin
        ctrl.reg_write = 1'b1;
        ctrl.alu_op = alu_op_RI;
      end
      //U Type LUI
      7'b0110111: begin
        ctrl.reg_write = 1'b1;
        ctrl.alu_src2 = 1'b1;
        ctrl.alu_op = ALU_PASS_2;
      end
      //B Type
      7'b1100011: begin
        ctrl.pc_type = 2'b01;
        ctrl.alu_op  = ALU_SUB;
      end
      //I Type  JALR
      7'b1100111: begin
        ctrl.reg_write = 1'b1;
        ctrl.result_src = 2'b10;  // PC+4
        ctrl.alu_src2 = 1'b1;
        ctrl.pc_type = 2'b11;
        ctrl.alu_op = ALU_ADD;
      end
      //J Type JAL
      7'b1101111: begin
        ctrl.reg_write = 1'b1;
        ctrl.result_src = 2'b10;
        ctrl.pc_type = 2'b10;
        ctrl.alu_op = ALU_ADD;
      end
      default: begin
      end
    endcase


  end
  // Immediate Generation
  always_comb begin
    case (op)
      // Uimm
      7'b0110111, 7'b0010111: imm = {instruction[31:12], {12{1'b0}}};
      // Iimm
      7'b1100111, 7'b0000011, 7'b0010011: imm = {{20{instruction[31]}}, instruction[31:20]};
      // Simm
      7'b0100011: imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
      // Bimm
      7'b1100011:
      imm = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
      // Jimm
      7'b1101111:
      imm = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
      default: imm = {32{1'bx}};
    endcase
  end
endmodule
