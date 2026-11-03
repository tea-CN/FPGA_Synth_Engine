module bclk_gen(
    input clk_27m,
    input rst_n,
    output reg bclk
);
// 27M / 19 = 1.421M，接近1.4112M，误差很小PCM5102可接受
reg [4:0] cnt;
localparam DIV = 5'd18;
always @(posedge clk_27m or negedge rst_n) begin
    if(!rst_n) begin
        cnt <= 0;
        bclk <= 0;
    end
    else if(cnt == DIV)begin
        cnt <= 0;
        bclk <= ~bclk;
    end
    else cnt <= cnt + 1'b1;
end
endmodule
