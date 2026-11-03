module osc_adsr(
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
localparam SUSTAIN_LEVEL = 16'h4000;

// 这里为了绝对能出声，用三角波代替庞大的正弦表
reg signed [15:0] tri_wave;
always @(*) begin
    if (phase[31]) tri_wave = {1'b0, phase[30:16]};      // 下降
    else          tri_wave = -{1'b0, phase[30:16]};     // 上升
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
                        adsr_amp <= adsr_amp + 16'd200;
                end
                DECAY: begin
                    if (adsr_amp <= SUSTAIN_LEVEL)
                        state <= SUSTAIN;
                    else
                        adsr_amp <= adsr_amp - 16'd10;
                end
                SUSTAIN: begin
                    if (!note_on) state <= RELEASE;
                end
                RELEASE: begin
                    if (adsr_amp <= 16'd15)
                        state <= IDLE;
                    else
                        adsr_amp <= adsr_amp - 16'd15;
                end
                default: state <= IDLE;
            endcase

            // 【关键修复】先乘完整的 adsr_amp，再右移 15 位，绝对不会被截断成 0
                //wav_out <= (phase[31] ? 16'sh4000 : -16'sh4000) * $signed(adsr_amp[15:1]);
            wav_out <= (tri_wave * $signed(adsr_amp)) >>> 15;
           
        end
    end
end
endmodule