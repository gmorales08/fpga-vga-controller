`ifndef PALETTE_VH
`define PALETTE_VH

`include "common.vh"

// Number of bits to represent one pixel color
// (6 bits for red, 6 bits for green, 6 bits for blue)
`define PALETTE_COLOR_BIT_SIZE 6 * 3

// Size in bits of each color stored in the palette rom
// This value has to be concordant to COLOR_BIT_SIZE
`define PALETTE_ROM_BIT_ALIGNMENT 8 * 3

// Rom size (number of colors) depending of the bits per pixel
`define GET_PALETTE_ROM_SIZE(MODE) (                \
    (MODE == `MODE_640X480X1BPPX60HZ) ? 2 ** 1 :    \
    (MODE == `MODE_640X480X2BPPX60HZ) ? 2 ** 2 :    \
    (MODE == `MODE_640X480X3BPPX60HZ) ? 2 ** 3 : -1 \
)

`endif // PALETTE_VH
