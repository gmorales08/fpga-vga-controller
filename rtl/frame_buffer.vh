`ifndef FRAME_BUFFER_VH
`define FRAME_BUFFER_VH

`define GET_SIMULATED_FRAME_SIZE(MODE) (               \
    (MODE == `MODE_640X480X1BPPX60HZ) ? 640 * 480 :    \
    (MODE == `MODE_640X480X2BPPX60HZ) ? 640 * 480 :    \
    (MODE == `MODE_640X480X3BPPX60HZ) ? 640 * 480 : -1 \
)

// The actual frame size is equal to the number of colors of the palette
`define GET_ACTUAL_FRAME_SIZE(MODE) (2 ** `GET_BPP(MODE))

`endif // FRAME_BUFFER_VH
