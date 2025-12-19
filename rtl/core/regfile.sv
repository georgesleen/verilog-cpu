import riscv_pkg::*;

/**
 * @brief RISC-V integer register file (2 read ports, 1 write port).
 *
 * Provides two combinational read ports (rs1/rs2) and one synchronous write port
 * (rd) intended for single-cycle and simple pipelined cores.
 *
 * @param XLEN   Register width in bits.
 * @param clk    Clock input.
 * @param n_rst  Active-low synchronous reset.
 * @param rs1_addr Source register 1 index (x0-x31).
 * @param rs2_addr Source register 2 index (x0-x31).
 * @param rd_addr  Destination register index (x0-x31).
 * @param rd_wen   Write enable for destination register.
 * @param rd_wdata Write data for destination register.
 * @param rs1_data Read data for source register 1.
 * @param rs2_data Read data for source register 2.
 */
module regfile #(
    parameter int XLEN = 32
) (
    input logic clk,
    input logic n_rst,

    input logic [REGISTER_INDEX_WIDTH-1:0] rs1_addr,
    input logic [REGISTER_INDEX_WIDTH-1:0] rs2_addr,
    input logic [REGISTER_INDEX_WIDTH-1:0] rd_addr,

    input logic rd_wen,
    input logic [XLEN-1:0] rd_wdata,

    output logic [XLEN-1:0] rs1_data,
    output logic [XLEN-1:0] rs2_data
);
    logic [XLEN-1:0] registers[REGISTER_COUNT];

    always_comb begin
        // Register x0 must always be '0
        rs1_data = (rs1_addr == X0) ? '0 : registers[rs1_addr];
        rs2_data = (rs2_addr == X0) ? '0 : registers[rs2_addr];
    end

    always_ff @(posedge clk) begin
        if (~n_rst) begin
            for (int i = 0; i < REGISTER_COUNT; i++) begin
                registers[i] <= '0;
            end
        end else if (rd_wen && (rd_addr != X0)) begin
            registers[rd_addr] <= rd_wdata;
        end
    end
endmodule
