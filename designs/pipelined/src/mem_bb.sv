`include "common.sv"
(* blackbox *)
module mem (
    input logic clk,
    input logic [31:0] addr1,  //PC
    input logic [31:0] addr2,  //Datamem
    output logic [31:0] data1,  //Instruction
    output logic [31:0] data2,  //Datamem
    input logic [31:0] write_data,
    input control_sig_t ctrl
);
endmodule
