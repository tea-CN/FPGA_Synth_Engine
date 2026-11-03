module square_osc(
    input clk,
    input rst_n,
    input sample_clk,
    input note_on,
    input [16:0] freq_step,
    output reg signed [15:0] wav_out
);

reg [31:0] phase;
reg [15:0] adsr_amp;
reg [3:0]  state;
localparam IDLE=0, ATTACK=1, DECAY=2, SUSTAIN=3, RELEASE=4;

// 【修改 1：控制按住时的持续音量】
// 现在设为 16'h6000 (约 75% 音量)，声音会比较响亮
localparam SUSTAIN_LEVEL = 16'h6000; 

// ===== 硬件优化的锯齿波 =====
reg signed [15:0] sq_wave;
always @(*) begin
   sq_wave = phase[31:16];  // 极简，纯硬件生成锯齿波
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        phase      <= 32'd0;
        adsr_amp   <= 16'd0;
        state      <= IDLE;
        wav_out    <= 16'd0;
    end
    else begin
        if(sample_clk) begin
            phase <= phase + freq_step;

            case(state)
                IDLE: begin
                    adsr_amp <= 16'd0;
                    if (note_on) state <= ATTACK;
                end
                ATTACK: begin
                    if (adsr_amp >= 16'h7E00)
                        state <= DECAY;
                    else
                        // 【修改 2：渐入速度】200 很快，要慢点可以改成 20
                        adsr_amp <= adsr_amp + 16'd200; 
                end
                DECAY: begin
                    if (adsr_amp <= SUSTAIN_LEVEL)
                        state <= SUSTAIN;
                    else
                        // 【修改 3：渐出到持续音的速度】
                        adsr_amp <= adsr_amp - 16'd10;
                end
                SUSTAIN: begin
                    // 直接用 note_on 判断，松手立刻进入释放阶段
                    if (!note_on) state <= RELEASE;
                end
                RELEASE: begin
                    if (adsr_amp <= 16'd15)
                        state <= IDLE;
                    else
                        // 【修改 4：松手后的尾音长度】15 比较干脆，改成 3 会有长尾音
                        adsr_amp <= adsr_amp - 16'd15;
                end
                default: state <= IDLE;
            endcase

            // 输出方波 * 包络
            wav_out <= (sq_wave * $signed(adsr_amp)) >>> 15;
        end
    end
end
endmodule