# Software

Bare-metal software used to bring up and test the CPU.

- `start.S` — Reset/startup code, vector table, and early init (stack, bss/data clearing).
- `main.c` — Firmware entrypoint for directed tests or demos.
- `linker.ld` — Memory map and section placement; adjust as the SoC memory map evolves.

Keep firmware small and deterministic so it can be driven from simulation and FPGA bring-up with the same binaries.
