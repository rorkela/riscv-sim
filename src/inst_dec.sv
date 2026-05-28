typedef struct packed {
wire reg_write;
wire mem_read;
wire mem_write;
wire branch;
wire alu_src;
wire [3:0] 




  } control_sig;

module inst_dec (input wire [31:0] instruction output )
