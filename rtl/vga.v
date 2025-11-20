`default_nettype none

`include "common.vh"
`include "vga.vh"
`include "palette.vh"

module vga #(
    parameter integer MODE = `MODE_640X480X3BPPX60HZ
)(
    input  wire clk_i,
    output reg  r_red_o    = 0,
    output reg  r_green_o  = 0,
    output reg  r_blue_o   = 0,
    output reg  r_hsync_no = 1,
    output reg  r_vsync_no = 1
);

localparam integer HSyncPulseTicks   = `GET_H_SYNC_PULSE_TICKS(MODE);
localparam integer HBackPorchTicks   = `GET_H_BACK_PORCH_TICKS(MODE);
localparam integer HLeftBorderTicks  = `GET_H_LEFT_BORDER_TICKS(MODE);
localparam integer HActiveVideoTicks = `GET_H_ACTIVE_VIDEO_TICKS(MODE);
localparam integer HRightBorderTicks = `GET_H_RIGHT_BORDER_TICKS(MODE);
localparam integer HFrontPorchTicks  = `GET_H_FRONT_PORCH_TICKS(MODE);
localparam integer HTicks            = `GET_H_TICKS(MODE);

localparam integer VSyncPulseTicks    = `GET_V_SYNC_PULSE_TICKS(MODE);
localparam integer VBackPorchTicks    = `GET_V_BACK_PORCH_TICKS(MODE);
localparam integer VTopBorderTicks    = `GET_V_TOP_BORDER_TICKS(MODE);
localparam integer VActiveVideoTicks  = `GET_V_ACTIVE_VIDEO_TICKS(MODE);
localparam integer VBottomBorderTicks = `GET_V_BOTTOM_BORDER_TICKS(MODE);
localparam integer VFrontPorchTicks   = `GET_V_FRONT_PORCH_TICKS(MODE);
localparam integer VTicks             = `GET_V_TICKS(MODE);

// Printable pixels include border and active video pixels
// TODO: cambiar nombre printable por screen
`define IS_PRINTABLE_PIXEL ((r_hcount > HSyncPulseTicks +             \
                                        HBackPorchTicks - 1) &&       \
                            (r_hcount < HTicks - HFrontPorchTicks) && \
                            (r_vcount > VSyncPulseTicks +             \
                                        VBackPorchTicks - 1) &&       \
                            (r_vcount < VTicks - VFrontPorchTicks)    \
)
// Addressable pixels are only the active video pixels
`define IS_ADDRESSABLE_PIXEL ((r_hcount > HSyncPulseTicks +           \
                                          HBackPorchTicks +           \
                                          HLeftBorderTicks - 1) &&    \
                              (r_hcount < HTicks - HFrontPorchTicks - \
                                          HRightBorderTicks) &&       \
                              (r_vcount > VSyncPulseTicks +           \
                                          VBackPorchTicks +           \
                                          VTopBorderTicks - 1) &&     \
                              (r_vcount < VTicks - VFrontPorchTicks - \
                                          VBottomBorderTicks)         \
)
`define IS_HSYNC_PIXEL (r_hcount < HSyncPulseTicks)
`define IS_VSYNC_PIXEL (r_vcount < VSyncPulseTicks)


// Colors and palette
/* This counter contains the current pixel number in the printable area of the
 * screen */
localparam integer VisibleScreenPixels = HActiveVideoTicks * VActiveVideoTicks;
reg [$clog2(VisibleScreenPixels)-1:0] r_current_screen_pixel = 0;

always @ (posedge clk_i) begin
    if (`IS_ADDRESSABLE_PIXEL) begin
        r_current_screen_pixel <=
            (r_current_screen_pixel == VisibleScreenPixels - 1) ? 0 :
                r_current_screen_pixel + 1;
    end
end

/* The color selection process is:
 * currentScreenPixel -pixel-idx-> frameBuffer -color-idx-> palette -> rgb out
 */
wire [`GET_BPP(MODE)-1:0] color_select;
frame_buffer #(
    .MODE(MODE)
) BUF(
    .pixel_select_i(r_current_screen_pixel),
    .data_o(color_select)
);

wire [`PALETTE_COLOR_BIT_SIZE-1:0] pixel_color;
palette #(
    .MODE(MODE)
) PAL (
    .color_select_i(color_select),
    .color_o(pixel_color)
);

always @ (posedge clk_i) begin
    if (`IS_PRINTABLE_PIXEL) begin
        if (`IS_ADDRESSABLE_PIXEL) begin
            // Addressable video
            r_red_o   <= pixel_color[12];
            r_blue_o  <= pixel_color[6];
            r_green_o <= pixel_color[0];
        end else begin
            // Border pixels
            // Printed for testing, should not be printed in a real controller
            r_red_o   <= 1;
            r_blue_o  <= 1;
            r_green_o <= 1;
        end
    end else begin
        // During off-screen pixels (sync time) color pins must be off
        r_red_o   <= 0;
        r_blue_o  <= 0;
        r_green_o <= 0;
    end
end

// Horizontal counter and Hsync
reg [9:0] r_hcount = 0;
always @ (posedge clk_i) begin
    if (r_hcount == HTicks - 1) begin
        r_hcount <= 0;
    end else begin
        r_hcount <= r_hcount + 1;
        if (`IS_HSYNC_PIXEL) begin
            r_hsync_no <= 0;
        end else begin
            r_hsync_no <= 1;
        end
    end
end

// Vertical counter and Vsync
reg [9:0] r_vcount = 0;
always @ (posedge clk_i) begin
    if (r_hcount == HTicks - 1) begin
        if (r_vcount == VTicks - 1) begin
            r_vcount <= 0;
        end else begin
            r_vcount <= r_vcount + 1;
            if (`IS_VSYNC_PIXEL) begin
                r_vsync_no <= 0;
            end else begin
                r_vsync_no <= 1;
            end
        end
    end
end

endmodule
