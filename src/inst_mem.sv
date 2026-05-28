module inst_mem (
    input  wire [31:0] address,
    output wire [31:0] instruction
);
  reg [7:0] mem[4096];

  initial begin
    $readmemh("temp_outputs/program.hex", mem);
  end
  assign instruction = {
    mem[address[11:0]+3], mem[address[11:0]+2], mem[address[11:0]+1], mem[address[11:0]]
  };
endmodule
