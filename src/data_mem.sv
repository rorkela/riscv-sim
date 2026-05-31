`include "common.sv"

module data_mem (
    input clk,
    input logic [31:0] address,
    input logic [31:0] write_data,
    input control_sig_t ctrl,
    output reg [31:0] read_data
);
  logic [7:0] mem[4096];
  initial begin
    $readmemh("temp_outputs/data.hex", mem);
  end
  assign read_data = {
    mem[address[11:0]+3], mem[address[11:0]+2], mem[address[11:0]+1], mem[address[11:0]]
  };
  always_ff @(posedge clk) begin
    if (ctrl.mem_write) begin
      {mem[address[11:0]+3], mem[address[11:0]+2], mem[address[11:0]+1], mem[address[11:0]]}<=write_data;
    end
  end
endmodule
