module mult (
    input wire clk,
    input wire reset,
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [1:0] op,  //00 - not mult | 01 - SS mult | 10 - UU mult
    input logic mult_trig,
    output logic busy,
    output logic [31:0] out
);
  logic outsign;
  assign outsign = a[31] ^ b[31];
  logic [31:0] M;
  logic [31:0] Q;
  logic [63:0] acc;
  logic Qprev;
  logic [3:0] state;
  logic [6:0] counter;
  localparam WAIT = 0, DO = 1, DONE = 2;
  logic [31:0] M_2c;
  assign M_2c = ~M + 32'd1;
  assign busy = state == DO;
  assign out  = acc[31:0];
  always_ff @(posedge clk) begin
    if (reset) begin
      state <= WAIT;
      Qprev <= 0;
      counter <= 0;
      acc <= 0;
      M <= 0;
      Q <= 0;

    end else begin
      case (state)
        WAIT: begin
          state <= mult_trig ? DO : WAIT;
          Qprev <= 0;
          counter <= 0;
          acc <= acc;
          M <= a;
          Q <= b;
        end
        DO: begin
          state <= (counter == 31) ? DONE : DO;
          Qprev <= Q[0];
          Q <= {Q[31], Q[31:1]};
          M <= M;
          case ({
            Q[0], Qprev
          })
            2'b01:   acc <= {{acc[63:32] + M}, acc[31:0]} >> 1;
            2'b10:   acc <= {{acc[63:32] + M_2c}, acc[31:0]} >> 1;
            default: acc <= acc >> 1;
          endcase
          counter <= counter + 7'b1;
        end
        DONE: begin
          state <= WAIT;
          Qprev <= 0;
          counter <= 0;
          acc <= acc;
          M <= a;
          M <= b;
        end
      endcase
    end
  end

endmodule
