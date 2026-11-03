//分频模块
module clk_div(
    input        clk,        // 27MHz 主时钟
    input        rst_n,
    output reg   sample_en   // 44.1kHz 采样使能
);
// 27000000 / 44100 ≈ 612
reg [9:0] cnt;
localparam DIV_NUM = 10'd612;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt <= 10'd0;
        sample_en <= 1'b0;
    end
    else if(cnt == DIV_NUM - 1'b1) begin
        cnt <= 10'd0;
        sample_en <= 1'b1;
    end
    else begin
        cnt <= cnt + 1'b1;
        sample_en <= 1'b0;
    end
end
endmodule
