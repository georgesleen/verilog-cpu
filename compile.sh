#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./compile.sh [command]

Commands:
  all       Build software, convert/move HEX, compile and run simulation (default)
  sw        Build RISC-V ELF and HEX, move HEX to sim/
  sim       Compile RTL with iverilog and run vvp (requires sim/main.hex)
  disasm    Disassemble sw/main.elf
  wave      Open gtkwave with sim/wave.vcd
EOF
}

need_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: required tool '$1' not found in PATH" >&2
    exit 1
  fi
}

build_sw() {
  need_tool riscv64-unknown-elf-gcc
  need_tool riscv64-unknown-elf-objcopy

  riscv64-unknown-elf-gcc \
    -march=rv32i \
    -mabi=ilp32 \
    -nostdlib \
    -T sw/linker.ld \
    sw/start.S \
    sw/main.c \
    -o sw/main.elf

  riscv64-unknown-elf-objcopy \
    -O verilog \
    sw/main.elf \
    sw/main.hex

  mv sw/main.hex sim/
}

run_sim() {
  need_tool iverilog
  need_tool vvp

  iverilog -g2012 \
    -o sim/sim.out \
    sim/tb_top.sv \
    rtl/riscv_pkg.sv \
    rtl/top.sv \
    rtl/core/core.sv \
    rtl/core/decode.sv \
    rtl/core/imm_decode.sv \
    rtl/core/alu.sv \
    rtl/memory/instruction_rom.sv \
    rtl/memory/data_ram.sv

  (cd sim && vvp sim.out)
}

disasm() {
  need_tool riscv64-unknown-elf-objdump
  riscv64-unknown-elf-objdump -d sw/main.elf
}

open_wave() {
  need_tool gtkwave
  gtkwave sim/wave.vcd
}

cmd="${1:-all}"

case "$cmd" in
  all)
    build_sw
    run_sim
    ;;
  sw)
    build_sw
    ;;
  sim)
    run_sim
    ;;
  disasm)
    disasm
    ;;
  wave)
    open_wave
    ;;
  -h|--help)
    usage
    ;;
  *)
    usage
    exit 1
    ;;
esac
