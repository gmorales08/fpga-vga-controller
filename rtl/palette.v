`include "common.vh"
`include "palette.vh"

// This module is combinational
module palette #(
    parameter integer MODE = `MODE_640X480X3BPPX60HZ
)(
    input  wire [`GET_BPP(MODE)-1:0] color_select_i,
    output wire [`PALETTE_COLOR_BIT_SIZE-1:0] color_o
);

localparam integer PaletteROMSize = `GET_PALETTE_ROM_SIZE(MODE);

reg [`PALETTE_ROM_BIT_ALIGNMENT-1:0] palette_rom [0:PaletteROMSize-1];

// Assign the color bits discarding the padding
localparam integer Padding = `PALETTE_ROM_BIT_ALIGNMENT -
                             `PALETTE_COLOR_BIT_SIZE;
assign color_o = palette_rom[color_select_i][`PALETTE_ROM_BIT_ALIGNMENT-1:
                                                Padding];

initial begin
    case (`GET_BPP(MODE))
        1: $readmemb("mem/palette1bpp.mem", palette_rom);
        2: $readmemb("mem/palette2bpp.mem", palette_rom);
        3: $readmemb("mem/palette3bpp.mem", palette_rom);
        default: $error("Not supported palette size: %d", `GET_BPP(MODE));
    endcase
end

// Task to print the palette in the test bench
task automatic dump_palette;
    integer i;
    begin
    $display("=====Palette ROM dump=====");
    for (i = 0; i < PaletteROMSize; i = i + 1) begin
        $display("Palette_rom[%0d] = %b", i, palette_rom[i]);
    end
    $display("==========================");
    end
endtask

endmodule
