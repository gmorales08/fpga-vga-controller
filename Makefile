PROJECT	:= vga

RTL_DIR := rtl
RTLS    := $(RTL_DIR)/top.v \
		   $(RTL_DIR)/vga.v \
		   $(RTL_DIR)/palette.v \
		   $(RTL_DIR)/frame_buffer.v \
		   $(RTL_DIR)/debouncer.v
PLL := $(RTL_DIR)/pll.v

TBS_DIR := sim

# Directory with the .vh files
INCLUDE_DIR := $(RTL_DIR)

FPGA_BOARD := alhambraII
CONSTRAINTS_FILE := constraints/$(FPGA_BOARD).pcf

BUILD_DIR := build


.PHONY: all
all: synt

# Synthesis
.PHONY: synt
synt: $(BUILD_DIR)/$(PROJECT).bin

$(BUILD_DIR)/$(PROJECT).bin: $(BUILD_DIR) $(CONSTRAINTS_FILE) $(RTLS)
	yosys -p 'synth_ice40 -top top -json $(BUILD_DIR)/$(PROJECT).json' \
		$(RTLS) $(PLL)
	nextpnr-ice40 --hx8k --package tq144:4k --json \
		$(BUILD_DIR)/$(PROJECT).json --pcf $(CONSTRAINTS_FILE) --asc \
		$(BUILD_DIR)/$(PROJECT).asc
	icepack $(BUILD_DIR)/$(PROJECT).asc $(BUILD_DIR)/$(PROJECT).bin

.PHONY: flash
flash: $(BUILD_DIR)/$(PROJECT).bin
	iceprog -d i:0x0403:0x6010:0 $(BUILD_DIR)/$(PROJECT).bin


# Simulation
.PHONY: sim
sim: $(BUILD_DIR) $(BUILD_DIR)/top_tb.vcd

.PHONY: sim_palette
sim_palette: $(BUILD_DIR) $(BUILD_DIR)/palette_tb.vcd


$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/%.vcd: $(TBS_DIR)/%.v $(RTLS)
	iverilog -g2001 -I$(INCLUDE_DIR) $^ -o $(BUILD_DIR)/$*.out && \
	vvp $(BUILD_DIR)/$*.out && \
	mv $*.vcd $(BUILD_DIR) && \
	gtkwave $@ $*.gtkw &


.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)
