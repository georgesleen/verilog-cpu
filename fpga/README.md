# FPGA

Board-specific collateral for prototyping the CPU on hardware.

- Constraint files (e.g., `.xdc`, `.sdc`) for pin assignments and timing.
- Synthesis/project files for your target toolchain (Quartus/Vivado/Radiant/etc.).
- Board-level top modules that wrap `rtl/top.sv` with clock/reset conditioning and I/O buffers.

Keep tool-generated output (e.g., build directories) out of source control; commit only hand-authored sources and scripts.
