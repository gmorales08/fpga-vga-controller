`ifndef COMMON_VH
`define COMMON_VH

// BPP = Bits per pixel
`define MODE_640X480X1BPPX60HZ 1
`define MODE_640X480X2BPPX60HZ 2
`define MODE_640X480X3BPPX60HZ 3

`define GET_BPP(MODE) (                        \
    (MODE == `MODE_640X480X1BPPX60HZ) ? 1 :    \
    (MODE == `MODE_640X480X2BPPX60HZ) ? 2 :    \
    (MODE == `MODE_640X480X3BPPX60HZ) ? 3 : -1 \
)

`endif // COMMON_VH
