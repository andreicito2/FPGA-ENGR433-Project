TOP_MODULE := VGA
SRCS := Ball_test.sv encoder.sv
PCF := pico2-ice.pcf
JSON := $(TOP_MODULE).json
ASC := $(TOP_MODULE).asc
BIN := $(TOP_MODULE).bin

YOSYS := yosys
NEXTPNR := nextpnr-ice40
ICEPACK := icepack
ICEPROG := iceprog

# nextpnr flags for iCE40UP5K SG48 (Pico2-ice)
NEXTPNR_FLAGS := --up5k --package sg48

all: dirs $(BIN)

dirs:
# Run synthesis with yosys to produce a JSON netlist (SystemVerilog)
$(JSON): $(SRCS) $(PCF)
	@echo "[yosys] Synthesizing SystemVerilog $(SRCS) -> $(JSON)"
	$(YOSYS) -p "read_verilog -sv $(SRCS); synth_ice40 -top $(TOP_MODULE) -json $(JSON)"

# Place & route with nextpnr-ice40 to produce an ASCII design file (.asc)
$(ASC): $(JSON) $(PCF)
	@echo "[nextpnr] Placing & routing -> $(ASC)"
	$(NEXTPNR) $(NEXTPNR_FLAGS) --json $(JSON) --pcf $(PCF) --asc $(ASC)

# Pack the .asc into a bitstream (.bin)
$(BIN): $(ASC)
	@echo "[icepack] Packing $(ASC) -> $(BIN)"
	$(ICEPACK) $(ASC) $(BIN)


clean:
	-del /Q $(JSON) $(ASC) $(BIN) 2>nul
	@echo " Clean complete"


# Convenience shortcuts
synth: $(JSON)
route: $(ASC)
pack: $(BIN)

.PHONY: all dirs synth route pack prog clean
# End of Makefile
