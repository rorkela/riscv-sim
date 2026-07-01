module mult (
    input wire clk,
    input wire reset,
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [1:0] op,  //00 - not mult | 01 - SS mult | 10 - UU mult | 11 - SU mult
    input logic mult_trig,
    output logic busy,
    output logic [63:0] out
);
  logic [32:0] M;
  logic [32:0] Q;
  logic signed [65:0] acc;
  logic Qprev;
  logic [3:0] state;
  logic [6:0] counter;
  localparam WAIT = 0, DO = 1, DONE = 2;
  logic [32:0] M_2c;
  assign M_2c = ~M + 33'd1;
  assign busy = (state == DO) || (op != 2'b00 && state == WAIT);
  assign out  = acc[63:0];
  logic [32:0] a_tran, b_tran;
  assign a_tran = {{(op == 2'b01 || op == 2'b11) ? a[31] : 1'b0}, a};
  assign b_tran = {{(op == 2'b01) ? b[31] : 1'b0}, b};
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
          acc <= 0;
          M <= a_tran;
          Q <= b_tran;
        end
        DO: begin
          state <= (counter == 32) ? DONE : DO;
          Qprev <= Q[0];
          Q <= {Q[32], Q[32:1]};
          M <= M;
          case ({
            Q[0], Qprev
          })
            2'b01:   acc <= $signed({{acc[65:33] + M}, acc[32:0]}) >>> 1;
            2'b10:   acc <= $signed({{acc[65:33] + M_2c}, acc[32:0]}) >>> 1;
            default: acc <= acc >>> 1;
          endcase
          counter <= counter + 7'b1;
        end
        DONE: begin
          state <= WAIT;
          Qprev <= 0;
          counter <= 0;
          acc <= acc;
          M <= a_tran;
          Q <= b_tran;
        end
      endcase
    end
  end

endmodule
