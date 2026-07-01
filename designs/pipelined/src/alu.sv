`include "common.sv"
`include "../../multdiv_unit/src/mult.sv"
module alu (
    input logic clk,
    input logic reset,
    input logic [31:0] a,
    input logic [31:0] b,
    input control_sig_t ctrl,
    output logic branch_taken,
    output logic [31:0] out,
    output logic busy
);
  //Output
  logic [31:0] alu_out;
  always_comb begin
    case (ctrl.alu_op)
      ALU_ADD: alu_out = a + b;
      ALU_SUB: alu_out = a - b;
      ALU_AND: alu_out = a & b;
      ALU_OR: alu_out = a | b;
      ALU_XOR: alu_out = a ^ b;
      ALU_SLL: alu_out = a << b[4:0];
      ALU_SRL: alu_out = a >> b[4:0];
      ALU_SRA: alu_out = $signed(a) >>> b[4:0];
      ALU_SLT: alu_out = {{31{1'b0}}, {($signed(a) < $signed(b)) ? 1'b1 : 1'b0}};
      ALU_SLTU: alu_out = {{31{1'b0}}, {(a < b) ? 1'b1 : 1'b0}};
      ALU_PASS_2: alu_out = b;
      default: alu_out = a + b;
    endcase
  end
  //Branch
  always_comb begin
    case (ctrl.funct3)
      3'b000:  branch_taken = (alu_out == 32'b0);
      3'b001:  branch_taken = (alu_out != 32'b0);
      3'b100:  branch_taken = ($signed(a) < $signed(b));
      3'b101:  branch_taken = ($signed(a) >= $signed(b));
      3'b110:  branch_taken = (a < b);
      3'b111:  branch_taken = (a >= b);
      default: branch_taken = 1'b0;
    endcase
  end
  //TODO: Mult
  logic mult_trig;
  logic [1:0] mult_op;
  logic [63:0] mult_out;
  logic [31:0] mult_out_turnc;
  logic mult_busy;
  always_comb begin
    case (ctrl.alu_op)
      MUL: begin
        mult_op = 2'b01;
        mult_trig = 1'b1;
        mult_out_turnc = mult_out[31:0];
      end
      MUL_H: begin
        mult_op = 2'b01;
        mult_trig = 1'b1;
        mult_out_turnc = mult_out[63:32];
      end
      MUL_HSU: begin
        mult_op = 2'b11;
        mult_trig = 1'b1;
        mult_out_turnc = mult_out[63:32];
      end
      MUL_HU: begin
        mult_op = 2'b10;
        mult_trig = 1'b1;
        mult_out_turnc = mult_out[63:32];
      end
      default: begin
        mult_op = 2'b00;
        mult_trig = 1'b0;
        mult_out_turnc = mult_out[63:32];
      end

    endcase
  end
  mult mult_1 (
      .clk(clk),
      .reset(reset),
      .a(a),
      .b(b),
      .op(mult_op),
      .mult_trig(mult_trig),
      .busy(mult_busy),
      .out(mult_out)
  );
  //Output
  assign out  = ((mult_op == 2'b00) ? alu_out : mult_out_turnc);
  //OR all busys
  assign busy = mult_busy;
endmodule
