module top (
    input wire clk,
    input wire reset,
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [1:0] op,  //00 - not mult | 01 - SS mult | 10 - UU mult
    input logic mult_trig,
    output logic busy,
    output logic [31:0] out
);
  mult mult_1 (
      clk,
      reset,
      a,
      b,
      op,
      mult_trig,
      busy,
      out
  );

endmodule
