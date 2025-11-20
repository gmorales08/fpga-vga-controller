`include "common.vh"
`include "frame_buffer.vh"

// This module is combinational
module frame_buffer #(
    parameter integer MODE = `MODE_640X480X3BPPX60HZ
)(
    input  wire [$clog2(`GET_SIMULATED_FRAME_SIZE(MODE))-1:0] pixel_select_i,
    output wire [`GET_BPP(MODE)-1:0]                          data_o
);


reg [`GET_BPP(MODE)-1:0] buffer [0:`GET_ACTUAL_FRAME_SIZE(MODE)-1];

assign data_o = buffer[pixel_select_i[`GET_BPP(MODE)-1:0]];

// Initialization of the memory
initial begin
    case(MODE)
        `MODE_640X480X1BPPX60HZ: begin
            $readmemh("mem/frame640x480_1bpp.hex",buffer);
        end
        `MODE_640X480X2BPPX60HZ: begin
            $readmemh("mem/frame640x480_2bpp.hex",buffer);
        end
        `MODE_640X480X3BPPX60HZ: begin
            $readmemh("mem/frame640x480_3bpp.hex",buffer);
        end
        default: $error("Mode not supported");
    endcase
end

endmodule
