`default_nettype none

`include "common.vh"

module top(
    input  wire clk_i,
    input  wire button1_i,
    input  wire button2_i,
    output wire red_o,
    output wire green_o,
    output wire blue_o,
    output wire hsync_no,
    output wire vsync_no
);

wire pixel_clk;
`ifdef YOSYS
    // 12 MHz FPGA clock  (clk_i)
    // 25 MHz pixel clock (pixel_clk)
    pll PLL (
        .clock_in(clk_i),
        .clock_out(pixel_clk),
        .locked()
    );
`else
    // Simulation
    assign pixel_clk = clk_i;
`endif

// Modules of VGA controllers with different video modes
wire vga1_red_o;
wire vga1_green_o;
wire vga1_blue_o;
wire vga1_hsync_no;
wire vga1_vsync_no;
vga #(
    .MODE(`MODE_640X480X1BPPX60HZ)
) VGA_MODE1BPP(
    .clk_i   (pixel_clk),
    .r_red_o   (vga1_red_o    ),
    .r_green_o (vga1_green_o  ),
    .r_blue_o  (vga1_blue_o   ),
    .r_hsync_no(vga1_hsync_no ),
    .r_vsync_no(vga1_vsync_no )
);

wire vga2_red_o;
wire vga2_green_o;
wire vga2_blue_o;
wire vga2_hsync_no;
wire vga2_vsync_no;
vga #(
    .MODE(`MODE_640X480X2BPPX60HZ)
) VGA_MODE2BPP(
    .clk_i   (pixel_clk),
    .r_red_o   (vga2_red_o    ),
    .r_green_o (vga2_green_o  ),
    .r_blue_o  (vga2_blue_o   ),
    .r_hsync_no(vga2_hsync_no ),
    .r_vsync_no(vga2_vsync_no )
);

wire vga3_red_o;
wire vga3_green_o;
wire vga3_blue_o;
wire vga3_hsync_no;
wire vga3_vsync_no;
vga #(
    .MODE(`MODE_640X480X3BPPX60HZ)
) VGA_MODE3BPP(
    .clk_i   (pixel_clk),
    .r_red_o   (vga3_red_o    ),
    .r_green_o (vga3_green_o  ),
    .r_blue_o  (vga3_blue_o   ),
    .r_hsync_no(vga3_hsync_no ),
    .r_vsync_no(vga3_vsync_no )
);


// Register the button pulsations
// Button 1 changes to the next vga mode
// Button 2 changes to the previous vga mode
reg [1:0] r_vga_select = 0;

wire button1_pulsation;
debouncer DEB1 (
    .clk_i(clk_i),
    .button_i(button1_i),
    .r_button_o(button1_pulsation)
);
reg r_button1_pulsation_prev = 0;

wire button2_pulsation;
debouncer DEB2 (
    .clk_i(clk_i),
    .button_i(button2_i),
    .r_button_o(button2_pulsation)
);
reg r_button2_pulsation_prev = 0;

always @ (posedge clk_i) begin
    r_button1_pulsation_prev <= button1_pulsation;
    r_button2_pulsation_prev <= button2_pulsation;
    if (button1_pulsation && ~r_button1_pulsation_prev) begin
        r_vga_select <= (r_vga_select == 2) ? 0 : r_vga_select + 1;
    end else if (button2_pulsation && ~r_button2_pulsation_prev) begin
        r_vga_select <= (r_vga_select == 0) ? 2 : r_vga_select - 1;
    end
end

// The outputs are assigned to the selected vga mode
assign red_o    = (r_vga_select == 0) ? vga1_red_o    :
                  (r_vga_select == 1) ? vga2_red_o    :
                  (r_vga_select == 2) ? vga3_red_o    : -1;
assign green_o  = (r_vga_select == 0) ? vga1_green_o  :
                  (r_vga_select == 1) ? vga2_green_o  :
                  (r_vga_select == 2) ? vga3_green_o  : -1;
assign blue_o   = (r_vga_select == 0) ? vga1_blue_o   :
                  (r_vga_select == 1) ? vga2_blue_o   :
                  (r_vga_select == 2) ? vga3_blue_o   : -1;
assign hsync_no = (r_vga_select == 0) ? vga1_hsync_no :
                  (r_vga_select == 1) ? vga2_hsync_no :
                  (r_vga_select == 2) ? vga3_hsync_no : -1;
assign vsync_no = (r_vga_select == 0) ? vga1_vsync_no :
                  (r_vga_select == 1) ? vga2_vsync_no :
                  (r_vga_select == 2) ? vga3_vsync_no : -1;

endmodule
