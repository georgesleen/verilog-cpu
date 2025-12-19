# Simulation

Testbenches and verification assets live here. Typical usage:

- Place block-level testbenches alongside the RTL they target and import them here via filelists or scripts.
- Keep common utilities (clock/reset generators, BFMs, scoreboards) in reusable includes.
- Use waveform dumps (`*.vcd`) and logs in `build/` (gitignored) to keep the repo clean.

Add a simple run script or Makefile targets as tests come online to standardize sim invocation (e.g., iverilog/Verilator/Questa).
