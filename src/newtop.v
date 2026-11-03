module newtop(
    input        clk,          //27M
    input        rst_n,
    output [3:0] col,
    input  [3:0] row,
    output       bclk,
    output       lrck,
    output       sdata,
    output       led
);

wire sample_clk;
wire [15:0] key_mask;
wire [6:0]  note_en = key_mask[6:0];

// ===== 关键 1：freq_step 改成 16 位（和 note_lut/osc_adsr 对齐）=====
wire signed [15:0] osc_wave[0:6];//三角波
wire        [16:0] freq_step[0:6];
wire signed [15:0] sq_wave[0:6];   // 锯齿波
// 和弦生成器输出的频率线网
wire [16:0] t0, t1, t2, t3, t4, t5, t6;
wire [16:0] f0, f1, f2, f3, f4, f5, f6;


// 键盘扫描
(* KEEP_HIERARCHY = "TRUE" *)
key_debounce u_key(
    .clk(clk), .rst_n(rst_n),
    .col(col), .row(row),
    .key_mask(key_mask)
);

// 采样时钟
clk_div u_sample_clk(
    .clk(clk), .rst_n(rst_n),
    .sample_en(sample_clk)
);


// 例化和弦生成器
chord_generator u_chord(
    .key_mask(key_mask), 
    .t0(t0), .t1(t1), .t2(t2), .t3(t3), .t4(t4), .t5(t5), .t6(t6),
    .f0(f0), .f1(f1), .f2(f2), .f3(f3), .f4(f4), .f5(f5), .f6(f6)
);


// ===== 关键 2：用 generate 例化 7 路，替换原来的 u_lut0/u_adsr0 =====
// ===== 7 路 note_lut：每路固定不同音高 0~6 =====
/*(* KEEP_HIERARCHY = "TRUE" *)
note_lut u_lut0(.note_idx(3'd0), .freq_step(freq_step[0]));
(* KEEP_HIERARCHY = "TRUE" *)
note_lut u_lut1(.note_idx(3'd1), .freq_step(freq_step[1]));
(* KEEP_HIERARCHY = "TRUE" *)
note_lut u_lut2(.note_idx(3'd2), .freq_step(freq_step[2]));
(* KEEP_HIERARCHY = "TRUE" *)
note_lut u_lut3(.note_idx(3'd3), .freq_step(freq_step[3]));
(* KEEP_HIERARCHY = "TRUE" *)
note_lut u_lut4(.note_idx(3'd4), .freq_step(freq_step[4]));
(* KEEP_HIERARCHY = "TRUE" *)
note_lut u_lut5(.note_idx(3'd5), .freq_step(freq_step[5]));
(* KEEP_HIERARCHY = "TRUE" *)
note_lut u_lut6(.note_idx(3'd6), .freq_step(freq_step[6]));
*/
// ===== 7 路 osc_adsr：第 i 路由 key_mask[i] 触发 =====
(* KEEP_HIERARCHY = "TRUE" *)
osc_adsr u_adsr0(
    .clk(clk), .rst_n(rst_n), .sample_clk(sample_clk),
    .note_on(note_en[0]), .freq_step(t0), .wav_out(osc_wave[0])
);
(* KEEP_HIERARCHY = "TRUE" *)
osc_adsr u_adsr1(
    .clk(clk), .rst_n(rst_n), .sample_clk(sample_clk),
    .note_on(note_en[1]), .freq_step(t1), .wav_out(osc_wave[1])
);
(* KEEP_HIERARCHY = "TRUE" *)
osc_adsr u_adsr2(
    .clk(clk), .rst_n(rst_n), .sample_clk(sample_clk),
    .note_on(note_en[2]), .freq_step(t2), .wav_out(osc_wave[2])
);
(* KEEP_HIERARCHY = "TRUE" *)
osc_adsr u_adsr3(
    .clk(clk), .rst_n(rst_n), .sample_clk(sample_clk),
    .note_on(note_en[3]), .freq_step(t3), .wav_out(osc_wave[3])
);
(* KEEP_HIERARCHY = "TRUE" *)
osc_adsr u_adsr4(
    .clk(clk), .rst_n(rst_n), .sample_clk(sample_clk),
    .note_on(note_en[4]), .freq_step(t4), .wav_out(osc_wave[4])
);
(* KEEP_HIERARCHY = "TRUE" *)
osc_adsr u_adsr5(
    .clk(clk), .rst_n(rst_n), .sample_clk(sample_clk),
    .note_on(note_en[5]), .freq_step(t5), .wav_out(osc_wave[5])
);
(* KEEP_HIERARCHY = "TRUE" *)
osc_adsr u_adsr6(
    .clk(clk), .rst_n(rst_n), .sample_clk(sample_clk),
    .note_on(note_en[6]), .freq_step(t6), .wav_out(osc_wave[6])
);

// 例化 7 个独立的方波振荡器
(* KEEP_HIERARCHY = "TRUE" *) square_osc u_sq0(.clk(clk), .rst_n(rst_n), .sample_clk(sample_clk), .note_on(key_mask[8]), .freq_step(f0), .wav_out(sq_wave[0]));
(* KEEP_HIERARCHY = "TRUE" *) square_osc u_sq1(.clk(clk), .rst_n(rst_n), .sample_clk(sample_clk), .note_on(key_mask[9]), .freq_step(f1), .wav_out(sq_wave[1]));
(* KEEP_HIERARCHY = "TRUE" *) square_osc u_sq2(.clk(clk), .rst_n(rst_n), .sample_clk(sample_clk), .note_on(key_mask[10]), .freq_step(f2), .wav_out(sq_wave[2]));
(* KEEP_HIERARCHY = "TRUE" *) square_osc u_sq3(.clk(clk), .rst_n(rst_n), .sample_clk(sample_clk), .note_on(key_mask[11]), .freq_step(f3), .wav_out(sq_wave[3]));
(* KEEP_HIERARCHY = "TRUE" *) square_osc u_sq4(.clk(clk), .rst_n(rst_n), .sample_clk(sample_clk), .note_on(key_mask[12]), .freq_step(f4), .wav_out(sq_wave[4]));
(* KEEP_HIERARCHY = "TRUE" *) square_osc u_sq5(.clk(clk), .rst_n(rst_n), .sample_clk(sample_clk), .note_on(key_mask[13]), .freq_step(f5), .wav_out(sq_wave[5]));
(* KEEP_HIERARCHY = "TRUE" *) square_osc u_sq6(.clk(clk), .rst_n(rst_n), .sample_clk(sample_clk), .note_on(key_mask[14]), .freq_step(f6), .wav_out(sq_wave[6]));
// u_sin1 到 u_sin6 照此格式写，note_on 依次接 key_mask[9]~[14]，
// .wav_sin 依次接 sin_wave[1] 到 sin_wave[6]。

// ===== 14 路混音 =====
wire signed [18:0] sum_wave = osc_wave[0] + osc_wave[1] + osc_wave[2] + osc_wave[3] + osc_wave[4] + osc_wave[5] + osc_wave[6]
                            + sq_wave[0] + sq_wave[1] + sq_wave[2] + sq_wave[3] + sq_wave[4] + sq_wave[5] + sq_wave[6];

wire signed [15:0] audio_mix = sum_wave[17:2]; // 除以 4，防止音量叠加爆音

// I2S 发送
i2s_tx u_i2s(
    .clk(clk), .rst_n(rst_n),
    .audio_l(audio_mix),
    .audio_r(audio_mix),
    .bclk(bclk), .lrck(lrck), .sdata(sdata)
);

assign led = |note_en;    // note_en[0]~[6] 任意一位为 1 就亮

endmodule