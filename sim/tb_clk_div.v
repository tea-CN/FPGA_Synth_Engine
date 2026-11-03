`timescale 1ns / 1ns
module tb_clk_div;
reg clk;
reg rst_n;
wire sample_en;

clk_div u_clk_div(
    .clk        (clk),
    .rst_n      (rst_n),
    .sample_en  (sample_en)
);

initial begin
    clk = 1'b0;
    forever #18.5 clk = ~clk;
end

initial begin
    rst_n = 1'b0;
    #100;
    rst_n = 1'b1;
    #50000;
    $stop;
end
endmodule
