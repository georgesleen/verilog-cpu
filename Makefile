RISCV_GCC := riscv64-unknown-elf-gcc
RISCV_OBJCOPY := riscv64-unknown-elf-objcopy
RISCV_OBJDUMP := riscv64-unknown-elf-objdump

BUILD_DIR := build
SW_BUILD := $(BUILD_DIR)/sw
SIM_BUILD := $(BUILD_DIR)/sim

SW_ELF := $(SW_BUILD)/main.elf
SW_HEX := $(SW_BUILD)/main.hex
SIM_HEX := $(SIM_BUILD)/main.hex
SIM_OUT := $(SIM_BUILD)/sim.out
SIM_VCD := $(SIM_BUILD)/wave.vcd

SW_SRCS := sw/start.S sw/main.c
RTL_SRCS := \
	sim/tb_pkg.sv \
	sim/tb_top.sv \
	rtl/riscv_pkg.sv \
	rtl/top.sv \
	rtl/core/core.sv \
	rtl/core/decode.sv \
	rtl/core/imm_decode.sv \
	rtl/core/alu.sv \
	rtl/memory/instruction_rom.sv \
	rtl/memory/data_ram.sv

.PHONY: all help sw sim disasm wave clean

all: sim

help:
	@printf "Usage: make [target]\n\n"
	@printf "Targets:\n"
	@printf "  all (default)  Build software, convert HEX, compile RTL, run sim (outputs in build/)\n"
	@printf "  sw             Build RISC-V ELF and HEX into build/sw/\n"
	@printf "  sim            Compile RTL with iverilog and run vvp (needs build/sim/main.hex)\n"
	@printf "  disasm         Disassemble build/sw/main.elf\n"
	@printf "  wave           Open gtkwave with build/sim/wave.vcd\n"
	@printf "  clean          Remove generated build artifacts\n"

sw: $(SIM_HEX)

$(SW_ELF): $(SW_SRCS) sw/linker.ld | $(SW_BUILD)
	$(RISCV_GCC) -march=rv32i -mabi=ilp32 -nostdlib -T sw/linker.ld $(SW_SRCS) -o $@

$(SW_HEX): $(SW_ELF)
	$(RISCV_OBJCOPY) -O verilog $< $@

$(SIM_HEX): $(SW_HEX) | $(SIM_BUILD)
	cp $< $@

$(SIM_OUT): $(RTL_SRCS) | $(SIM_BUILD)
	iverilog -g2012 -o $@ $(RTL_SRCS)

sim: $(SIM_HEX) $(SIM_OUT)
	vvp $(SIM_OUT)

disasm: $(SW_ELF)
	$(RISCV_OBJDUMP) -d $<

wave: $(SIM_HEX) $(SIM_OUT)
	gtkwave $(SIM_VCD)

clean:
	rm -rf $(BUILD_DIR)

$(SW_BUILD) $(SIM_BUILD):
	mkdir -p $@
