module led(
    input        clk,
    output reg   led
);

reg [23:0] cnt;

always @(posedge clk) begin
    cnt <= cnt + 1'b1;
    if(cnt == 24'd9999999) begin
        cnt <= 24'd0;
        led <= ~led;
    end
end

endmodule
