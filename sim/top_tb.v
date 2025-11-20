`default_nettype none
`timescale 1ns/1ps

module top_tb();

reg clk = 0;
always #1 clk = ~clk;

initial begin
    $dumpfile("top_tb.vcd");
    $dumpvars(0, top_tb);
end

initial begin
    # 1000000
    $finish;
end

wire red_o;
wire green_o;
wire blue_o;
wire hsync_no;
wire vsync_no;
top TOP (
    .clk_i(clk),
    .red_o(red_o),
    .green_o(green_o),
    .blue_o(blue_o),
    .hsync_no(hsync_no),
    .vsync_no(vsync_no)
);

endmodule
