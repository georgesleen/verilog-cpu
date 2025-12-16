# Compilation commands

There are a lot of commands and stuff to do the things you want to do.
This is how you can do them.
Eventually this should be replaced with a script.

Outputs land in `build/` to keep the repo tidy:
```bash
mkdir -p build/sw build/sim
```

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
  -o build/sw/main.elf
```
2. Convert to HEX
```bash
riscv64-unknown-elf-objcopy \
  -O verilog \
  build/sw/main.elf \
  build/sw/main.hex
```
## Synthesize RTL
1. Synthesis with icarus verilog
```bash
iverilog -g2012 \
  -o build/sim/sim.out \
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
 ```
**Note**: ```rtl/riscv_pkg.sv``` *MUST* be compiled before everything else

2. Run simulation
```bash
vvp build/sim/sim.out
```
3. View waveforms
```bash
gtkwave build/sim/wave.vcd
```
## Disassembly
```bash
riscv64-unknown-elf-objdump -d build/sw/main.elf
```
