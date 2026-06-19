`include "common.sv"
module mem (
    input logic clk,
    input logic [31:0] addr1,  //PC
    input logic [31:0] addr2,  //Datamem
    output logic [31:0] data1,  //Instruction
    output logic [31:0] data2,  //Datamem
    input logic [31:0] write_data,
    input control_sig_t ctrl
);
  logic [7:0] mem[524288];
  initial begin
    $readmemh("temp_outputs/program.hex", mem);
  end
  logic [18:0] a1, a2;
  assign a1 = addr1[18:0];
  assign a2 = addr2[18:0];
  assign data1 = {mem[a1+3], mem[a1+2], mem[a1+1], mem[a1]};
  always_comb begin
    case (ctrl.funct3)
      3'b000:  data2 = {{24{mem[a2][7]}}, mem[a2]};
      3'b001:  data2 = {{16{mem[a2+1][7]}}, mem[a2+1], mem[a2]};
      3'b010:  data2 = {mem[a2+3], mem[a2+2], mem[a2+1], mem[a2]};
      3'b100:  data2 = {{24{1'b0}}, mem[a2]};
      3'b101:  data2 = {{16{1'b0}}, mem[a2+1], mem[a2]};
      default: data2 = {mem[a2+3], mem[a2+2], mem[a2+1], mem[a2]};
    endcase

  end
  always_ff @(posedge clk) begin
    if (ctrl.mem_write) begin
      case (ctrl.funct3)
        3'b000:  {mem[a2]} <= write_data[7:0];
        3'b001:  {mem[a2+1], mem[a2]} <= write_data[15:0];
        3'b010:  {mem[a2+3], mem[a2+2], mem[a2+1], mem[a2]} <= write_data;
        default: {mem[a2+3], mem[a2+2], mem[a2+1], mem[a2]} <= write_data;

      endcase
    end
  end
endmodule
