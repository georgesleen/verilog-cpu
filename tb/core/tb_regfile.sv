`timescale 1ns/1ps

import riscv_pkg::*;

module tb_regfile #(
    parameter int XLEN = 32,
    parameter string WAVE_FILE = "build/tb/regfile_tb.vcd"
);
    logic clk;
    logic n_rst;

    logic [REGISTER_INDEX_WIDTH-1:0] rs1_addr;
    logic [REGISTER_INDEX_WIDTH-1:0] rs2_addr;
    logic [REGISTER_INDEX_WIDTH-1:0] rd_addr;

    logic rd_wen;
    logic [XLEN-1:0] rd_wdata;

    logic [XLEN-1:0] rs1_data;
    logic [XLEN-1:0] rs2_data;

    regfile #(.XLEN(XLEN)) dut (
        .clk    (clk),
        .n_rst  (n_rst),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr (rd_addr),
        .rd_wen  (rd_wen),
        .rd_wdata(rd_wdata),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    logic [XLEN-1:0] expected_regs[REGISTER_COUNT];
    int unsigned error_count;

    function automatic logic [REGISTER_INDEX_WIDTH-1:0] idx(input int unsigned i);
        return i[REGISTER_INDEX_WIDTH-1:0];
    endfunction

    task automatic tick();
        @(posedge clk);
        #1;
    endtask

    task automatic apply_reset();
        n_rst = 1'b0;
        rd_wen = 1'b0;
        rd_addr = '0;
        rd_wdata = '0;
        rs1_addr = '0;
        rs2_addr = '0;

        for (int i = 0; i < REGISTER_COUNT; i++) begin
            expected_regs[i] = '0;
        end

        tick();
        tick();
        n_rst = 1'b1;
        tick();
    endtask

    task automatic expect_eq(
        input logic [XLEN-1:0] actual,
        input logic [XLEN-1:0] expected,
        input string msg
    );
        if (actual !== expected) begin
            error_count++;
            $display("[TB][ERR] %s expected=0x%08x actual=0x%08x", msg, expected, actual);
        end
    endtask

    task automatic set_reads(
        input int unsigned rs1,
        input int unsigned rs2
    );
        rs1_addr = idx(rs1);
        rs2_addr = idx(rs2);
        #1;
    endtask

    task automatic write_reg(
        input int unsigned rd,
        input logic [XLEN-1:0] data
    );
        @(negedge clk);
        rd_addr = idx(rd);
        rd_wdata = data;
        rd_wen = 1'b1;

        tick();

        rd_wen = 1'b0;
        rd_addr = '0;
        rd_wdata = '0;

        if (rd != X0) begin
            expected_regs[rd] = data;
        end
    endtask

    task automatic check_read_port(
        input int unsigned port,
        input int unsigned reg_index
    );
        if (port == 1) begin
            rs1_addr = idx(reg_index);
            #1;
            expect_eq(rs1_data, expected_regs[reg_index], $sformatf("rs1 read x%0d", reg_index));
        end else begin
            rs2_addr = idx(reg_index);
            #1;
            expect_eq(rs2_data, expected_regs[reg_index], $sformatf("rs2 read x%0d", reg_index));
        end
    endtask

    // Clock generation
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // Waveforms
    initial begin
        $dumpfile(WAVE_FILE);
        $dumpvars(0, tb_regfile);
    end

    initial begin
        error_count = 0;
        apply_reset();

        // Sanity: after reset, everything reads as zero (including x0)
        for (int i = 0; i < REGISTER_COUNT; i++) begin
            expected_regs[i] = '0;
            check_read_port(1, i);
            check_read_port(2, i);
        end

        // x0 ignores writes
        write_reg(X0, 32'hffff_ffff);
        expected_regs[X0] = '0;
        set_reads(X0, X0);
        expect_eq(rs1_data, '0, "x0 is hardwired to zero (rs1)");
        expect_eq(rs2_data, '0, "x0 is hardwired to zero (rs2)");

        // Basic write/read behavior
        write_reg(1, 32'h1234_5678);
        write_reg(2, 32'hdead_beef);
        set_reads(1, 2);
        expect_eq(rs1_data, expected_regs[1], "readback x1");
        expect_eq(rs2_data, expected_regs[2], "readback x2");

        // rd_wen low means no write
        @(negedge clk);
        rd_addr = idx(3);
        rd_wdata = 32'h1111_1111;
        rd_wen = 1'b0;
        tick();
        rd_addr = '0;
        rd_wdata = '0;
        expected_regs[3] = '0;
        check_read_port(1, 3);

        // Same-cycle read/write: value updates after clock edge (no write-through bypass)
        write_reg(5, 32'haaaa_0001);
        @(negedge clk);
        set_reads(5, 0);
        rd_addr = idx(5);
        rd_wdata = 32'hbbbb_0002;
        rd_wen = 1'b1;
        #1;
        expect_eq(rs1_data, expected_regs[5], "RAW same-cycle read shows old value");
        tick();
        rd_wen = 1'b0;
        rd_addr = '0;
        rd_wdata = '0;
        expected_regs[5] = 32'hbbbb_0002;
        set_reads(5, 0);
        expect_eq(rs1_data, expected_regs[5], "after clock edge read shows new value");

        // Randomized smoke (writes only)
        for (int iter = 0; iter < 200; iter++) begin
            int unsigned r;
            logic [XLEN-1:0] d;
            r = $urandom_range(1, REGISTER_COUNT - 1);
            d = $urandom();
            write_reg(r, d);

            set_reads(r, X0);
            expect_eq(rs1_data, expected_regs[r], $sformatf("random readback x%0d", r));
            expect_eq(rs2_data, '0, "random: x0 still zero");
        end

        if (error_count == 0) begin
            $display("[TB] PASS");
        end else begin
            $display("[TB] FAIL (%0d errors)", error_count);
        end
        $finish;
    end

endmodule
