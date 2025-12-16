# Compilation commands

There are a lot of commands and stuff to do the things you want to do.
This is how you can do them.
Eventually this should be replaced with a script.

## Build RISC-V program
1. Generate ELF
```bash
riscv64-unknown-elf-gcc \
  -march=rv32i \
  -mabi=ilp32 \
  -nostdlib \
  -T sw/linker.ld \
  sw/start.S \
  sw/main.c \
  -o sw/main.elf
```
2. Convert to HEX
```bash
riscv64-unknown-elf-objcopy \
  -O verilog \
  sw/main.elf \
  sw/main.hex
```
3. Move to proper directory
```bash
mv sw/main.hex sim/
```
## Synthesize RTL
1. Synthesis with icarus verilog
```bash
iverilog -g2012 \
  -o sim/sim.out \
  sim/tb_core.sv \
  rtl/top.sv \
  rtl/riscv_pkg.sv \
  rtl/core/core.sv \
  rtl/core/decode.sv \
  rtl/core/imm_decode.sv \
  rtl/core/alu.sv \
  rtl/memory/instruction_rom.sv \
  rtl/memory/data_ram.sv
```
2. Run simulation
```bash
cd sim
vvp sim.out
```
3. View waveforms
```bash
gtkwave wave.vcd
```
## Disassembly
```bash
riscv64-unknown-elf-objdump -d sw/main.elf
```
