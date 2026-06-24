module decompressor (
    input logic [31:0] inst,
    output logic [31:0] dinst,
    output logic compressed
);
  logic [15:0] cinst = inst[15:0];
  logic [ 1:0] op = inst[1:0];
  logic [ 2:0] funct3 = inst[15:13];
  logic [ 3:0] funct4 = inst[15:12];
  logic [ 6:0] r_funct7;
  logic [ 2:0] r_funct3;
  always_comb begin
    compressed = cinst[1:0] != 2'b11;
  end
  always_comb begin
    case (cinst[6:5])
      2'b00: begin
        r_funct3 = 3'b000;
        r_funct7 = 7'b0100000;
      end
      2'b01: begin
        r_funct3 = 3'b100;
        r_funct7 = 7'b0000000;
      end
      2'b10: begin
        r_funct3 = 3'b110;
        r_funct7 = 7'b0000000;
      end
      2'b11: begin
        r_funct3 = 3'b111;
        r_funct7 = 7'b0000000;
      end
    endcase
  end
  always_comb begin
    case (op)
      // QUADRANT 1
      2'b00: begin
        casez (cinst[15:10])
          6'b000???:
          dinst = {
            2'b00,
            cinst[10:7],
            cinst[12:11],
            cinst[5],
            cinst[6],
            2'b00,
            5'b00010,
            3'b000,
            2'b01,
            cinst[4:2],
            7'b0010011
          };

          6'b110???:
          dinst = {
            {5{1'b0}},
            cinst[5],
            cinst[12],
            2'b01,
            cinst[4:2],
            2'b01,
            cinst[9:7],
            3'b010,
            cinst[11:10],
            cinst[6],
            2'b00,
            7'b0100011
          };


          6'b010???:
          dinst = {
            {5{1'b0}},
            cinst[5],
            cinst[12:10],
            cinst[6],
            2'b00,
            2'b01,
            cinst[9:7],
            3'b010,
            2'b01,
            cinst[4:2],
            7'b0000011
          };


          default: dinst = {32'd0};
        endcase
      end
      // QUADRANT 2
      2'b01: begin
        casez (cinst[15:10])
          6'b011???: begin
            if (cinst[11:7] == 5'b00010)
              dinst = {
                {2{cinst[12]}},
                cinst[12],
                cinst[4:3],
                cinst[5],
                cinst[2],
                cinst[6],
                4'b0000,
                5'b00010,
                3'b000,
                5'b00010,
                7'b0010011
              };
            else dinst = {{14{cinst[12]}}, cinst[12], cinst[6:2], cinst[11:7], 7'b0110111};

          end
          6'b000???:
          dinst = {{7{cinst[12]}}, cinst[6:2], cinst[11:7], 3'b000, cinst[11:7], 7'b0010011};

          6'b010???:
          dinst = {{7{cinst[12]}}, cinst[6:2], 5'b00000, 3'b000, cinst[11:7], 7'b0010011};

          6'b100?00:

          dinst = {
            {6{1'b0}},
            cinst[12],
            cinst[6:2],
            2'b01,
            cinst[9:7],
            3'b101,
            2'b01,
            cinst[9:7],
            7'b0010011
          };

          6'b100?01:

          dinst = {
            6'b010000,
            cinst[12],
            cinst[6:2],
            2'b01,
            cinst[9:7],
            3'b101,
            2'b01,
            cinst[9:7],
            7'b0010011
          };

          6'b100?10:

          dinst = {
            {6{cinst[12]}},
            cinst[12],
            cinst[6:2],
            2'b01,
            cinst[9:7],
            3'b111,
            2'b01,
            cinst[9:7],
            7'b0010011
          };

          6'b100?11:
          dinst = {
            r_funct7, 2'b01, cinst[4:2], 2'b01, cinst[9:7], r_funct3, 2'b01, cinst[9:7], 7'b0110011
          };
          6'b101???:
          dinst = {
            cinst[12],
            cinst[8],
            cinst[10:9],
            cinst[6],
            cinst[7],
            cinst[2],
            cinst[11],
            cinst[5:3],
            cinst[12],
            {8{cinst[12]}},
            5'b00000,
            7'b1101111
          };
          6'b110???:
          dinst = {
            {3{cinst[12]}},
            cinst[12],
            cinst[6:5],
            cinst[2],
            5'b00000,
            2'b01,
            cinst[9:7],
            3'b000,
            cinst[11:10],
            cinst[4:3],
            cinst[12],
            7'b1100011
          };
          6'b111???:
          dinst = {
            {3{cinst[12]}},
            cinst[12],
            cinst[6:5],
            cinst[2],
            5'b00000,
            2'b01,
            cinst[9:7],
            3'b001,
            cinst[11:10],
            cinst[4:3],
            cinst[12],
            7'b1100011
          };
          6'b001???:
          dinst = {
            cinst[12],
            cinst[8],
            cinst[10:9],
            cinst[6],
            cinst[7],
            cinst[2],
            cinst[11],
            cinst[5:3],
            cinst[12],
            {8{cinst[12]}},
            5'b00001,
            7'b1101111
          };
          default: dinst = 32'd0;
        endcase
      end
      // QUADRANT 3
      2'b10: begin
        casez (cinst[15:10])
          6'b000???:
          dinst = {{6{1'b0}}, cinst[12], cinst[6:2], cinst[11:7], 3'b001, cinst[11:7], 7'b0010011};
          6'b1000??: begin
            if (cinst[6:2] == 5'b0) dinst = {12'b0, cinst[11:7], 3'b000, 5'b00000, 7'b1100111};
            else dinst = {7'b0000000, cinst[6:2], 5'b0, 3'b0, cinst[11:7], 7'b0110011};
          end
          6'b1001??: begin
            if (cinst[11:7] == 5'b0) dinst = 32'h00100073;
            else if (cinst[6:2] == 5'b0) dinst = {12'b0, cinst[11:7], 3'b000, 5'b00001, 7'b1100111};
            else dinst = {7'b0000000, cinst[6:2], cinst[11:7], 3'b0, cinst[11:7], 7'b0110011};
          end
          6'b010???:
          dinst = {
            4'b0000,
            cinst[3:2],
            cinst[12],
            cinst[6:4],
            2'b00,
            5'b00010,
            3'b010,
            cinst[11:7],
            7'b0000011
          };
          6'b110???:
          dinst = {
            4'b0000,
            cinst[8:7],
            cinst[12],
            cinst[6:2],
            5'b00010,
            3'b010,
            cinst[11:9],
            2'b00,
            7'b0100011
          };
          default: dinst = 32'd0;
        endcase
      end
      2'b11: begin
        dinst = inst;
      end
      default: begin
        dinst = 32'd0;
      end
    endcase
  end


endmodule
