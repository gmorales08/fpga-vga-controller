`include "../rtl/common.vh"
`include "../rtl/palette.vh"

`default_nettype none
`timescale 1ns/1ps

module palette_tb();

reg clk = 0;
always #1 clk = ~clk;

initial begin
    $dumpfile("palette_tb.vcd");
    $dumpvars(0, palette_tb);
    #1;
    PAL.dump_palette();
end

initial begin
    # ((2 ** `GET_BPP(MODE)) * 2)
    $finish;
end

// Change this parameter to test other modes
localparam integer MODE = `MODE_640X480X3BPPX60HZ;

wire [`GET_BPP(MODE)-1:0] COLOR_SELECT;
wire [5:0] RED_OUT;
wire [5:0] GREEN_OUT;
wire [5:0] BLUE_OUT;
palette #(
    .MODE(MODE)
) PAL (
    .color_select_i(COLOR_SELECT),
    .color_o({RED_OUT,GREEN_OUT,BLUE_OUT})
);

// Select all the colors of the palette
reg [`GET_BPP(MODE)-1:0] cont = 0;
assign COLOR_SELECT = cont;
always @ (posedge clk) begin
    cont <= (cont == (2 ** `GET_BPP(MODE)) - 1) ? 0 : cont + 1;
end

endmodule
