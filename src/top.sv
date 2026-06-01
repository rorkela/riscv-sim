`include "common.sv"
module top (
    input wire clk,
    input wire reset,
    output reg [31:0] pc,
    output wire [31:0] inst,
    output logic halt
);
  initial begin
    pc = 32'h80000000;
  end
  //Memory
  logic [31:0] read_data;
  mem mem_1 (
      .clk(clk),
      .addr1(pc),
      .addr2(alu_out),
      .data1(inst),
      .data2(read_data),
      .write_data(rd2),
      .ctrl(ctrl)
  );
  //ID
  control_sig_t ctrl;
  logic [31:0] imm;
  logic [4:0] rs2;
  logic [4:0] rs1;
  logic [4:0] rd;
  inst_dec inst_dec_1 (
      .instruction(inst),
      .ctrl(ctrl),
      .imm(imm),
      .rs2(rs2),
      .rs1(rs1),
      .rd(rd)
  );
  logic [31:0] reg_write_data;
  logic [31:0] rd1, rd2;
  reg_file reg_file_1 (
      .clk(clk),
      .reset(reset),
      .reg_write(ctrl.reg_write),
      .rs1(rs1),
      .rs2(rs2),
      .rd(rd),
      .wd(reg_write_data),
      .rd1(rd1),
      .rd2(rd2)
  );

  logic [31:0] alu_a, alu_b, alu_out;
  logic branch_taken;
  assign alu_a = (ctrl.alu_src1) ? pc : rd1;
  assign alu_b = (ctrl.alu_src2) ? imm : rd2;
  alu alu_1 (
      .a(alu_a),
      .b(alu_b),
      .ctrl(ctrl),
      .branch_taken(branch_taken),
      .alu_out(alu_out)
  );


  //reg write data mux
  always_comb begin

    case (ctrl.result_src)
      2'b00:   reg_write_data = alu_out;
      2'b01:   reg_write_data = read_data;
      2'b10:   reg_write_data = pc + 4;
      default: reg_write_data = alu_out;


    endcase


  end
  //PC Update
  assign halt = inst == 32'h00000073;
  always_ff @(posedge clk) begin
    if (reset) pc <= 32'd80000000;
    else if (halt) begin
      pc <= pc;
    end else begin
      case (ctrl.pc_type)
        2'b00:   pc <= pc + 32'd4;
        2'b01:   pc <= branch_taken ? (imm + pc) : (pc + 32'd4);
        2'b10:   pc <= imm + pc;
        2'b11:   pc <= alu_out;
        default: pc <= pc + 32'd4;
      endcase

    end
  end


endmodule
