`include "common.sv"
`include "pipeline_struct.sv"
module top (
    input wire clk,
    input wire reset,
    output reg [31:0] pc,
    output wire [31:0] inst,
    output logic halt
);
  //Pipeline Definations, w=input wire, r=output register
  if_id_t ifid_w, ifid_r;
  id_ex_t idex_w, idex_r;
  ex_mem_t exmem_w, exmem_r;
  mem_wb_t memwb_w, memwb_r;
  assign {idex_w.pc, idex_w.inst, idex_w.compressed} = {ifid_r.pc, ifid_r.inst, ifid_r.compressed};
  assign {exmem_w.rs1,exmem_w.rs2,exmem_w.pc, exmem_w.inst, exmem_w.ctrl, exmem_w.rd, exmem_w.rd2, exmem_w.compressed} = {
    idex_r.rs1,
    idex_r.rs2,
    idex_r.pc,
    idex_r.inst,
    idex_r.ctrl,
    idex_r.rd,
    ex_forwarded_rd2,
    idex_r.compressed
  };

  assign {memwb_w.rs1, memwb_w.rs2,memwb_w.pc, memwb_w.inst, memwb_w.ctrl, memwb_w.rd, memwb_w.alu_out, memwb_w.compressed} = {
    exmem_r.rs1,
    exmem_r.rs2,
    exmem_r.pc,
    exmem_r.inst,
    exmem_r.ctrl,
    exmem_r.rd,
    exmem_r.alu_out,
    exmem_r.compressed
  };
  initial begin
    pc = 32'h80000000;
  end
  assign ifid_w.pc = pc;
  //Memory
  logic [31:0] mem_write_data;
  always_comb begin
    if (memwb_r.ctrl.reg_write & memwb_r.rd != 0 & memwb_r.rd == exmem_r.rs2) begin
      mem_write_data = reg_write_data;
    end else begin
      mem_write_data = exmem_r.rd2;
    end

  end
  mem mem_1 (
      .clk(clk),
      .addr1(pc),
      .addr2(exmem_r.alu_out),
      .data1(inst),
      .data2(memwb_w.read_data),
      .write_data(mem_write_data),
      .ctrl(exmem_r.ctrl)
  );

  decompressor decompresser_1 (
      .inst(inst),
      .dinst(ifid_w.inst),
      .compressed(ifid_w.compressed)
  );
  //ID
  logic [4:0] id_rs1, id_rs2;
  inst_dec inst_dec_1 (
      .instruction(ifid_r.inst),
      .ctrl(idex_w.ctrl),
      .imm(idex_w.imm),
      .rs2(id_rs2),
      .rs1(id_rs1),
      .rd(idex_w.rd)
  );
  assign idex_w.rs1 = id_rs1;
  assign idex_w.rs2 = id_rs2;
  logic [31:0] reg_write_data;
  reg_file reg_file_1 (
      .clk(clk),
      .reset(reset),
      .reg_write(memwb_r.ctrl.reg_write),
      .rs1(id_rs1),
      .rs2(id_rs2),
      .rd(memwb_r.rd),
      .wd(reg_write_data),
      .rd1(idex_w.rd1),
      .rd2(idex_w.rd2)
  );

  logic [31:0] alu_a, alu_b;
  logic alu_branch_taken;
  //Stall + Forwarding logic
  logic stall;
  always_comb begin
    if((idex_r.ctrl.result_src==2'b01& idex_r.ctrl.reg_write & (idex_w.rs1!=5'b0) & idex_r.rd==idex_w.rs1) ||(idex_r.ctrl.result_src==2'b01 & idex_r.ctrl.reg_write & (idex_w.rs2!=5'b0) & idex_r.rd==idex_w.rs2))
    begin
      stall = 1'b1;
    end else begin
      stall = 1'b0;
    end
  end
  logic [31:0] ex_forwarded_rd2;
  logic [31:0] ex_forwarded_rd1;
  always_comb begin
    if (exmem_r.ctrl.reg_write & (exmem_r.rd != 0) & (exmem_r.rd == idex_r.rs1)) begin
      case (exmem_r.ctrl.result_src)
        2'b00:   ex_forwarded_rd1 = exmem_r.alu_out;
        2'b10:   ex_forwarded_rd1 = exmem_r.pc + (exmem_r.compressed ? 2 : 4);
        default: ex_forwarded_rd1 = exmem_r.alu_out;
      endcase
    end else if (memwb_r.ctrl.reg_write & memwb_r.rd != 0 & memwb_r.rd == idex_r.rs1) begin
      ex_forwarded_rd1 = reg_write_data;
    end else begin
      ex_forwarded_rd1 = idex_r.rd1;
    end
    if (exmem_r.ctrl.reg_write & (exmem_r.rd != 0) & (exmem_r.rd == idex_r.rs2)) begin
      case (exmem_r.ctrl.result_src)
        2'b00:   ex_forwarded_rd2 = exmem_r.alu_out;
        2'b10:   ex_forwarded_rd2 = exmem_r.pc + (exmem_r.compressed ? 2 : 4);
        default: ex_forwarded_rd2 = exmem_r.alu_out;
      endcase
    end else if (memwb_r.ctrl.reg_write & memwb_r.rd != 0 & memwb_r.rd == idex_r.rs2) begin
      ex_forwarded_rd2 = reg_write_data;
    end else begin
      ex_forwarded_rd2 = idex_r.rd2;
    end
  end
  assign alu_a = idex_r.ctrl.alu_src1 ? idex_r.pc : ex_forwarded_rd1;
  assign alu_b = (idex_r.ctrl.alu_src2) ? idex_r.imm : ex_forwarded_rd2;
  alu alu_1 (
      .a(alu_a),
      .b(alu_b),
      .ctrl(idex_r.ctrl),
      .branch_taken(alu_branch_taken),
      .alu_out(exmem_w.alu_out)
  );


  //reg write data mux
  always_comb begin
    case (memwb_r.ctrl.result_src)
      2'b00:   reg_write_data = memwb_r.alu_out;
      2'b01:   reg_write_data = memwb_r.read_data;
      2'b10:   reg_write_data = memwb_r.pc + (memwb_r.compressed ? 2 : 4);
      default: reg_write_data = memwb_r.alu_out;
    endcase
  end
  //branch logic
  logic ex_branch_taken;
  always_comb begin
    case (idex_r.ctrl.pc_type)
      2'b00:   ex_branch_taken = 1'b0;
      2'b01:   ex_branch_taken = alu_branch_taken;
      2'b10:   ex_branch_taken = 1'b1;
      2'b11:   ex_branch_taken = 1'b1;
      default: ex_branch_taken = 1'b0;

    endcase
  end
  // Pipeline update
  always_ff @(posedge clk) begin
    if (stall) begin
      ifid_r  <= ifid_r;
      idex_r  <= 0;
      exmem_r <= exmem_w;
    end else if (ex_branch_taken) begin
      ifid_r  <= 0;
      idex_r  <= 0;
      exmem_r <= exmem_w;
    end else begin
      ifid_r  <= ifid_w;
      idex_r  <= idex_w;
      exmem_r <= exmem_w;
    end
    memwb_r <= memwb_w;
  end
  //PC Update
  assign halt = memwb_r.inst == 32'h00000073;
  always_ff @(posedge clk) begin
    if (reset) pc <= 32'h80000000;
    else if (stall) begin
      pc <= pc;
    end else begin
      case (idex_r.ctrl.pc_type)
        2'b00: pc <= (inst == 32'h00000073) ? pc : (pc + (ifid_w.compressed ? 2 : 4));
        2'b01:
        pc <= alu_branch_taken ? (idex_r.imm + idex_r.pc) : (pc + (ifid_w.compressed ? 2 : 4));
        2'b10: pc <= idex_r.imm + idex_r.pc;
        2'b11: pc <= exmem_w.alu_out;
        default: pc <= (inst == 32'h00000073) ? pc : (pc + (ifid_w.compressed ? 2 : 4));
      endcase

    end
  end


endmodule
