module reg_file (
    input logic clk,
    input logic reset,
    input logic reg_write,
    input logic [4:0] rs1,
    input logic [4:0] rs2,
    input logic [4:0] rd,
    input logic [31:0] wd,
    output logic [31:0] rd1,
    output logic [31:0] rd2
);
  logic [31:0] regfile[32];
  always_comb begin
    if (reg_write && (rd != 0) && (rd == rs1)) rd1 = wd;
    else rd1 = regfile[rs1];

    if (reg_write && (rd != 0) && (rd == rs2)) rd2 = wd;
    else rd2 = regfile[rs2];
  end
  integer i;
  always_ff @(posedge clk) begin
    if (reset) begin
      for (i = 0; i < 32; i++) begin
        regfile[i] <= 32'b0;
      end
    end else begin
      if ((reg_write) && (rd != 5'd0)) begin
        regfile[rd] <= wd;
      end
    end
  end
endmodule
