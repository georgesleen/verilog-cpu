/**
 * @brief Shared testbench package for MMIO utility addresses.
 */
package tb_pkg;

    // Testbench-only MMIO addresses
    localparam logic [31:0] MMIO_DONE_ADDR  = 32'h0000_0100;
    localparam logic [31:0] MMIO_PRINT_ADDR = 32'h0000_0104;

endpackage
