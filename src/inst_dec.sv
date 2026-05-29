typedef struct packed {
  logic pc_src;
  logic [1:0] result_src;  //00=aluresult 01=readdata 10=pc+4
  logic mem_write;
  logic alu_src1;  //rs1 or pc 
  logic alu_src2;  //rs2 or imm
  logic reg_write;
} control_sig_t;

module inst_dec (
    input logic [31:0] instruction,
    output control_sig_t ctrl,
    output logic [3:0] alu_op,
    output logic [31:0] imm
);
  logic [6:0] funct7;
  logic [2:0] funct3;
  logic [6:0] op;
  logic [4:0] rs2;
  logic [4:0] rs1;
  logic [4:0] rd;
  assign op     = instruction[6:0];
  assign rd     = instruction[11:7];
  assign funct3 = instruction[14:12];
  assign rs1    = instruction[19:15];
  assign rs2    = instruction[24:20];
  assign funct7 = instruction[31:25];


  always_comb begin
    case (op)
      //I type Load
      7'b0000011: begin
        ctrl = 7'b0010011;
      end
      //I type imm
      7'b0010011: begin
        ctrl = 7'b0000011;
      end
      //U Type auipc
      7'b0010111: begin
        ctrl = 7'b0000111;
      end
      //S type
      7'b0100011: begin
        ctrl = 7'b0001010;
      end
      //R type
      7'b0110011: begin
        ctrl = 7'b0000001;
      end
      //U Type LUI
      7'b0110111: begin
        ctrl = 7'b0000011;
      end
      //B Type
      7'b1100011: begin
        ctrl = 7'b1000000;
      end
      //I Type  JALR
      7'b1100111: begin
        ctrl = 7'b1100011;
      end
      //J Type JAL
      7'b1101111: begin
        ctrl = 7'b0100001;
      end
      default: begin
        ctrl = 7'b0000000;
      end
    endcase


  end
endmodule
