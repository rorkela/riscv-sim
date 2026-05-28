`include "inst_mem.sv"
module top (
    input wire clk,
    input wire reset,
    output reg [31:0] pc,
    output wire [31:0] inst
);
  initial begin
    pc = 32'd0;
  end

  // counter
  always @(posedge clk) begin
    pc <= reset ? (32'd0) : (pc + 32'd4);
  end
  inst_mem inst_mem_1 (
      .address(pc),
      .instruction(inst)
  );
endmodule
