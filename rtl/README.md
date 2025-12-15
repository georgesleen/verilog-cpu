# RTL

Hardware description lives here, organized to keep core logic separate from platform glue.

- `core/` — CPU pipeline, control, ALU, register file, CSR, and related microarchitecture blocks.
- `memory/` — SRAM interfaces, caches, and memory-mapped bus logic.
- `peripherals/` — Simple I/O (UART/GPIO/timers), interrupt controller, and any board-facing IP.
- `top.sv` — Integration point that wires the core, memory system, and peripherals into a synthesizable SoC.

Add new modules under the appropriate subdirectory and keep top-level parameters centralized in `top.sv`.
