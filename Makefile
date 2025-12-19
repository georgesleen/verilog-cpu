RISCV_GCC := riscv64-unknown-elf-gcc
RISCV_OBJCOPY := riscv64-unknown-elf-objcopy
RISCV_OBJDUMP := riscv64-unknown-elf-objdump

BUILD_DIR := build
SW_BUILD := $(BUILD_DIR)/sw
TB_BUILD := $(BUILD_DIR)/tb

SW_ELF := $(SW_BUILD)/main.elf
SW_HEX := $(SW_BUILD)/main.hex
TB_HEX := $(TB_BUILD)/main.hex
TB_OUT := $(TB_BUILD)/tb_top.out
TB_VCD := $(TB_BUILD)/wave.vcd

SW_SRCS := sw/start.S sw/main.c
# Collect RTL sources automatically. Keep package files first so iverilog sees
# them before anything that imports them.
RTL_PKGS := $(shell find tb rtl -name '*pkg.sv' | sort)
RTL_ALL  := $(shell find tb rtl -name '*.sv' | sort)
RTL_SRCS := $(RTL_PKGS) $(filter-out $(RTL_PKGS),$(RTL_ALL))

TB_TOP_FILES := $(filter-out tb/tb_pkg.sv,$(shell find tb -name 'tb_*.sv' | sort))
TB_TOPS := $(basename $(notdir $(TB_TOP_FILES)))
TB_UNIT_TOPS := $(filter-out tb_top,$(TB_TOPS))
TB_UNIT_OUTS := $(addprefix $(TB_BUILD)/,$(addsuffix .out,$(TB_UNIT_TOPS)))

.PHONY: all help sw sim test disasm wave clean

all: sim

help:
	@printf "Usage: make [target]\n\n"
	@printf "Targets:\n"
	@printf "  all (default)  Build software, convert HEX, compile RTL, run sim (outputs in build/)\n"
	@printf "  sw             Build RISC-V ELF and HEX into build/sw/\n"
	@printf "  sim            Compile RTL with iverilog and run vvp (needs build/tb/main.hex)\n"
	@printf "  test           Compile and run all unit testbenches\n"
	@printf "  disasm         Disassemble build/sw/main.elf\n"
	@printf "  wave           Open gtkwave with build/tb/wave.vcd\n"
	@printf "  clean          Remove generated build artifacts\n"

sw: $(TB_HEX)

$(SW_ELF): $(SW_SRCS) sw/linker.ld | $(SW_BUILD)
	$(RISCV_GCC) -march=rv32i -mabi=ilp32 -nostdlib -T sw/linker.ld $(SW_SRCS) -o $@

$(SW_HEX): $(SW_ELF)
	$(RISCV_OBJCOPY) -O verilog $< $@

$(TB_HEX): $(SW_HEX) | $(TB_BUILD)
	cp $< $@

$(TB_BUILD)/%.out: $(RTL_SRCS) | $(TB_BUILD)
	iverilog -g2012 -o $@ -s $* $(RTL_SRCS)

sim: $(TB_HEX) $(TB_OUT)
	vvp $(TB_OUT)

disasm: $(SW_ELF)
	$(RISCV_OBJDUMP) -d $<

test: $(TB_UNIT_OUTS)
	@set -e; \
	for tb in $(TB_UNIT_TOPS); do \
		printf "[TEST] %s\n" "$$tb"; \
		vvp "$(TB_BUILD)/$$tb.out"; \
	done

wave: $(TB_HEX) $(TB_OUT)
	gtkwave $(TB_VCD)

clean:
	rm -rf $(BUILD_DIR)

$(SW_BUILD) $(TB_BUILD):
	mkdir -p $@
