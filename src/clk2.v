module clk2(
    input clk_27m,
    input rst_n,
    output reg clk_44k1
);
reg [9:0] cnt;
always @(posedge clk_27m or negedge rst_n) begin
    if(!rst_n) begin
        cnt <= 10'd0;
        clk_44k1 <= 1'b0;
    end
    else begin
        cnt <= cnt + 10'd1;
        if(cnt == 10'd306) begin
            cnt <= 10'd0;
            clk_44k1 <= ~clk_44k1;
        end
    end
end
endmodule
