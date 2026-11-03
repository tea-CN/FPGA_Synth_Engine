module i2s_tx(
    input               clk,        // 27MHz
    input               rst_n,
    input signed [15:0] audio_l,
    input signed [15:0] audio_r,
    output reg          bclk,
    output reg          lrck,
    output reg          sdata
);

    localparam BCLK_DIV = 9'd10;
    reg [8:0] bclk_cnt;
    reg [4:0] bit_cnt;
    reg [31:0] shift_reg;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            bclk_cnt <= 9'd0;
            bclk <= 1'b0;
        end
        else begin
            if(bclk_cnt == BCLK_DIV) begin
                bclk_cnt <= 9'd0;
                bclk <= ~bclk;
            end
            else begin
                bclk_cnt <= bclk_cnt + 9'd1;
            end
        end
    end

    always @(negedge bclk or negedge rst_n) begin
        if(!rst_n) begin
            bit_cnt <= 5'd0;
            lrck <= 1'b0;
            sdata <= 1'b0;
            shift_reg <= 32'd0;
        end
        else begin
            if(bit_cnt == 5'd31) begin
                bit_cnt <= 5'd0;
                lrck <= ~lrck;
                shift_reg <= {audio_l, audio_r};
            end
            else begin
                bit_cnt <= bit_cnt + 5'd1;
                sdata <= shift_reg[31];
                shift_reg <= {shift_reg[30:0],1'b0};
            end
        end
    end
endmodule