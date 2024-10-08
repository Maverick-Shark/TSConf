module keyboard
(
  input             clk,
  input             reset,
  input       [7:0] a,
  output      [4:0] keyb,
  output reg        key_reset,
  output reg  [7:0] scancode,
  input      [10:0] ps2_key,
  input       [1:0] cfg_joystick1,
  input       [1:0] cfg_joystick2,
  input       [7:0] joystick1,
  input       [7:0] joystick2
);

reg [4:0] keys [7:0];

wire [4:0] row0 = a[0]? 5'b11111 : keys[0];
wire [4:0] row1 = a[1]? 5'b11111 : keys[1];
wire [4:0] row2 = a[2]? 5'b11111 : keys[2];
wire [4:0] row3 = a[3]? 5'b11111 : keys[3];
wire [4:0] row4 = a[4]? 5'b11111 : keys[4];
wire [4:0] row5 = a[5]? 5'b11111 : keys[5];
wire [4:0] row6 = a[6]? 5'b11111 : keys[6];
wire [4:0] row7 = a[7]? 5'b11111 : keys[7];
assign keyb = row0 & row1 & row2 & row3 & row4 & row5 & row6 & row7;


wire [15:0] joys = {joystick2, joystick1};
reg [15:0] joys_r = 0;
reg joys_ch = 0;
reg [3:0] joys_chn;

reg strobe = 0;
reg press;
reg [8:0] code;

reg flg = 0;
always @(posedge clk)
  flg <= ps2_key[10];


always @(posedge clk) begin
  strobe <= 1'b0;

  if (joys[15] != joys_r[15]) {joys_ch, joys_chn} <= {1'b1, 4'd15};
  if (joys[14] != joys_r[14]) {joys_ch, joys_chn} <= {1'b1, 4'd14};
  if (joys[13] != joys_r[13]) {joys_ch, joys_chn} <= {1'b1, 4'd13};
  if (joys[12] != joys_r[12]) {joys_ch, joys_chn} <= {1'b1, 4'd12};
  if (joys[11] != joys_r[11]) {joys_ch, joys_chn} <= {1'b1, 4'd11};
  if (joys[10] != joys_r[10]) {joys_ch, joys_chn} <= {1'b1, 4'd10};
  if (joys[9]  != joys_r[9])  {joys_ch, joys_chn} <= {1'b1, 4'd9};
  if (joys[8]  != joys_r[8])  {joys_ch, joys_chn} <= {1'b1, 4'd8};
  if (joys[7]  != joys_r[7])  {joys_ch, joys_chn} <= {1'b1, 4'd7};
  if (joys[6]  != joys_r[6])  {joys_ch, joys_chn} <= {1'b1, 4'd6};
  if (joys[5]  != joys_r[5])  {joys_ch, joys_chn} <= {1'b1, 4'd5};
  if (joys[4]  != joys_r[4])  {joys_ch, joys_chn} <= {1'b1, 4'd4};
  if (joys[3]  != joys_r[3])  {joys_ch, joys_chn} <= {1'b1, 4'd3};
  if (joys[2]  != joys_r[2])  {joys_ch, joys_chn} <= {1'b1, 4'd2};
  if (joys[1]  != joys_r[1])  {joys_ch, joys_chn} <= {1'b1, 4'd1};
  if (joys[0]  != joys_r[0])  {joys_ch, joys_chn} <= {1'b1, 4'd0};

  if (ps2_key[10] && !flg) begin
    {strobe, press, code} <= ps2_key;
  end
  else if (joys_ch) begin
    joys_ch <= 1'b0;
    joys_r[joys_chn] <= joys[joys_chn];
    case (cfg_joystick1)
    2'b01: begin // Sinclair 1
      case (joys_chn)
      0:  {strobe, press, code} <= {1'b1, joys[0 ], 9'h3d}; // Right  | 7
      1:  {strobe, press, code} <= {1'b1, joys[1 ], 9'h36}; // Left   | 6
      2:  {strobe, press, code} <= {1'b1, joys[2 ], 9'h3e}; // Down   | 8
      3:  {strobe, press, code} <= {1'b1, joys[3 ], 9'h46}; // Up     | 9
      4:  {strobe, press, code} <= {1'b1, joys[4 ], 9'h45}; // Fire 1 | 0
      5:  {strobe, press, code} <= {1'b1, joys[5 ], 9'h3a}; // Fire 2 | m
      6:  {strobe, press, code} <= {1'b1, joys[6 ], 9'h31}; // Fire 3 | n
      7:  {strobe, press, code} <= {1'b1, joys[7 ], 9'h32}; // Fire 4 | b
      endcase
    end
    2'b10: begin // Sinclair 2
      case (joys_chn)
      0:  {strobe, press, code} <= {1'b1, joys[0 ], 9'h1e}; // Right  | 2
      1:  {strobe, press, code} <= {1'b1, joys[1 ], 9'h16}; // Left   | 1
      2:  {strobe, press, code} <= {1'b1, joys[2 ], 9'h26}; // Down   | 3
      3:  {strobe, press, code} <= {1'b1, joys[3 ], 9'h25}; // Up     | 4
      4:  {strobe, press, code} <= {1'b1, joys[4 ], 9'h2e}; // Fire 1 | 5
      5:  {strobe, press, code} <= {1'b1, joys[5 ], 9'h1a}; // Fire 2 | z
      6:  {strobe, press, code} <= {1'b1, joys[6 ], 9'h22}; // Fire 3 | x
      7:  {strobe, press, code} <= {1'b1, joys[7 ], 9'h21}; // Fire 4 | c
      endcase
    end
    2'b11: begin // Cursor
      case (joys_chn)
      0:  {strobe, press, code} <= {1'b1, joys[0 ], 9'h74}; // Right  | Right
      1:  {strobe, press, code} <= {1'b1, joys[1 ], 9'h6b}; // Left   | Left
      2:  {strobe, press, code} <= {1'b1, joys[2 ], 9'h72}; // Down   | Down
      3:  {strobe, press, code} <= {1'b1, joys[3 ], 9'h75}; // Up     | Up
      4:  {strobe, press, code} <= {1'b1, joys[4 ], 9'h5a}; // Fire 1 | Enter
      5:  {strobe, press, code} <= {1'b1, joys[5 ], 9'h0d}; // Fire 2 | Tab
      6:  {strobe, press, code} <= {1'b1, joys[6 ], 9'h29}; // Fire 3 | Space
      7:  {strobe, press, code} <= {1'b1, joys[7 ], 9'h76}; // Fire 4 | Esc
      endcase
    end
    endcase
    case (cfg_joystick2)
    2'b01: begin // Sinclair 1
      case (joys_chn)
      8:  {strobe, press, code} <= {1'b1, joys[8 ], 9'h3d}; // Right  | 7
      9:  {strobe, press, code} <= {1'b1, joys[9 ], 9'h36}; // Left   | 6
      10: {strobe, press, code} <= {1'b1, joys[10], 9'h3e}; // Down   | 8
      11: {strobe, press, code} <= {1'b1, joys[11], 9'h46}; // Up     | 9
      12: {strobe, press, code} <= {1'b1, joys[12], 9'h45}; // Fire 1 | 0
      13: {strobe, press, code} <= {1'b1, joys[13], 9'h3a}; // Fire 2 | m
      14: {strobe, press, code} <= {1'b1, joys[14], 9'h31}; // Fire 3 | n
      15: {strobe, press, code} <= {1'b1, joys[15], 9'h32}; // Fire 4 | b
      endcase
    end
    2'b10: begin // Sinclair 2
      case (joys_chn)
      8:  {strobe, press, code} <= {1'b1, joys[8 ], 9'h1e}; // Right  | 2
      9:  {strobe, press, code} <= {1'b1, joys[9 ], 9'h16}; // Left   | 1
      10: {strobe, press, code} <= {1'b1, joys[10], 9'h26}; // Down   | 3
      11: {strobe, press, code} <= {1'b1, joys[11], 9'h25}; // Up     | 4
      12: {strobe, press, code} <= {1'b1, joys[12], 9'h2e}; // Fire 1 | 5
      13: {strobe, press, code} <= {1'b1, joys[13], 9'h1a}; // Fire 2 | z
      14: {strobe, press, code} <= {1'b1, joys[14], 9'h22}; // Fire 3 | x
      15: {strobe, press, code} <= {1'b1, joys[15], 9'h21}; // Fire 4 | c
      endcase
    end
    2'b11: begin // Cursor
      case (joys_chn)
      8:  {strobe, press, code} <= {1'b1, joys[8 ], 9'h74}; // Right  | Right
      9:  {strobe, press, code} <= {1'b1, joys[9 ], 9'h6b}; // Left   | Left
      10: {strobe, press, code} <= {1'b1, joys[10], 9'h72}; // Down   | Down
      11: {strobe, press, code} <= {1'b1, joys[11], 9'h75}; // Up     | Up
      12: {strobe, press, code} <= {1'b1, joys[12], 9'h5a}; // Fire 1 | Enter
      13: {strobe, press, code} <= {1'b1, joys[13], 9'h0d}; // Fire 2 | Tab
      14: {strobe, press, code} <= {1'b1, joys[14], 9'h29}; // Fire 3 | Space
      15: {strobe, press, code} <= {1'b1, joys[15], 9'h76}; // Fire 4 | Esc
      endcase
    end
    endcase
  end
end


always @(posedge clk or posedge reset) begin
  if (reset) begin
    keys[0] <= 5'b11111;
    keys[1] <= 5'b11111;
    keys[2] <= 5'b11111;
    keys[3] <= 5'b11111;
    keys[4] <= 5'b11111;
    keys[5] <= 5'b11111;
    keys[6] <= 5'b11111;
    keys[7] <= 5'b11111;
    key_reset <= 0;
    scancode <= 0;
  end
  else begin
    if (strobe) begin
      if (press)
        scancode <= code[7:0];
      else
        scancode <= 8'hFF;
      case (code[7:0])
        8'h12: keys[0][0] <= ~press; // Left shift (CAPS SHIFT)
        8'h59: keys[0][0] <= ~press; // Right shift (CAPS SHIFT)
        8'h1a: keys[0][1] <= ~press; // Z
        8'h22: keys[0][2] <= ~press; // X
        8'h21: keys[0][3] <= ~press; // C
        8'h2a: keys[0][4] <= ~press; // V

        8'h1c: keys[1][0] <= ~press; // A
        8'h1b: keys[1][1] <= ~press; // S
        8'h23: keys[1][2] <= ~press; // D
        8'h2b: keys[1][3] <= ~press; // F
        8'h34: keys[1][4] <= ~press; // G

        8'h15: keys[2][0] <= ~press; // Q
        8'h1d: keys[2][1] <= ~press; // W
        8'h24: keys[2][2] <= ~press; // E
        8'h2d: keys[2][3] <= ~press; // R
        8'h2c: keys[2][4] <= ~press; // T

        8'h16: keys[3][0] <= ~press; // 1
        8'h1e: keys[3][1] <= ~press; // 2
        8'h26: keys[3][2] <= ~press; // 3
        8'h25: keys[3][3] <= ~press; // 4
        8'h2e: keys[3][4] <= ~press; // 5

        8'h45: keys[4][0] <= ~press; // 0
        8'h46: keys[4][1] <= ~press; // 9
        8'h3e: keys[4][2] <= ~press; // 8
        8'h3d: keys[4][3] <= ~press; // 7
        8'h36: keys[4][4] <= ~press; // 6

        8'h4d: keys[5][0] <= ~press; // P
        8'h44: keys[5][1] <= ~press; // O
        8'h43: keys[5][2] <= ~press; // I
        8'h3c: keys[5][3] <= ~press; // U
        8'h35: keys[5][4] <= ~press; // Y

        8'h5a: keys[6][0] <= ~press; // ENTER
        8'h4b: keys[6][1] <= ~press; // L
        8'h42: keys[6][2] <= ~press; // K
        8'h3b: keys[6][3] <= ~press; // J
        8'h33: keys[6][4] <= ~press; // H

        8'h29: keys[7][0] <= ~press; // SPACE
        8'h14: keys[7][1] <= ~press; // CTRL (Symbol Shift)
        8'h3a: keys[7][2] <= ~press; // M
        8'h31: keys[7][3] <= ~press; // N
        8'h32: keys[7][4] <= ~press; // B

        // Cursor keys
        8'h6b: begin
          keys[0][0] <= ~press; // Left (CAPS 5)
          keys[3][4] <= ~press;
        end
        8'h72: begin
          keys[0][0] <= ~press; // Down (CAPS 6)
          keys[4][4] <= ~press;
        end
        8'h75: begin
          keys[0][0] <= ~press; // Up (CAPS 7)
          keys[4][3] <= ~press;
        end
        8'h74: begin
          keys[0][0] <= ~press; // Right (CAPS 8)
          keys[4][2] <= ~press;
        end

        // Other special keys sent to the ULA as key combinations
        8'h66: begin
          keys[0][0] <= ~press; // Backspace (CAPS 0)
          keys[4][0] <= ~press;
        end
        8'h58: begin
          keys[0][0] <= ~press; // Caps lock (CAPS 2)
          keys[3][1] <= ~press;
        end
        8'h0d: begin
          keys[0][0] <= ~press; // Tab (CAPS SPACE)
          keys[7][0] <= ~press;
        end
        8'h49: begin
          keys[7][2] <= ~press; // .
          keys[7][1] <= ~press;
        end
        8'h4e: begin
          keys[6][3] <= ~press; // -
          keys[7][1] <= ~press;
        end
        8'h0e: begin
          keys[3][0] <= ~press; // ` (EDIT)
          keys[0][0] <= ~press;
        end
        8'h41: begin
          keys[7][3] <= ~press; // ,
          keys[7][1] <= ~press;
        end
        8'h4c: begin
          keys[5][1] <= ~press; // ;
          keys[7][1] <= ~press;
        end
        8'h52: begin
          keys[5][0] <= ~press; // "
          keys[7][1] <= ~press;
        end
        8'h5d: begin
          keys[0][1] <= ~press; // :
          keys[7][1] <= ~press;
        end
        8'h55: begin
          keys[6][1] <= ~press; // =
          keys[7][1] <= ~press;
        end
        8'h54: begin
          keys[4][2] <= ~press; // (
          keys[7][1] <= ~press;
        end
        8'h5b: begin
          keys[4][1] <= ~press; // )
          keys[7][1] <= ~press;
        end
        8'h4a: begin
          keys[0][3] <= ~press; // ?
          keys[7][1] <= ~press;
        end

        8'h78: key_reset <= press;
      endcase
    end
  end
end

endmodule
