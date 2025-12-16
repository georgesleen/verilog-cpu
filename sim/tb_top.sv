import tb_pkg::*;

module tb_top #(
    parameter string WAVE_FILE = "build/sim/wave.vcd"
);
    logic clk;
    logic n_rst;

    // Instantiate DUT
    top dut (
        .clk  (clk),
        .n_rst(n_rst)
    );
    defparam dut.rom.HEX_FILE = "build/sim/main.hex";

    // ----------------------------------------
    // Clock generation
    // ----------------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ----------------------------------------
    // Reset sequence
    // ----------------------------------------
    initial begin
        n_rst = 0;
        #20;
        n_rst = 1;
    end

    // ----------------------------------------
    // Waveform dumping
    // ----------------------------------------
    initial begin
        $dumpfile(WAVE_FILE);
        $dumpvars(0, dut);
    end

    // ----------------------------------------
    // MMIO monitor
    // ----------------------------------------
    always @(posedge clk) begin
        if (dut.cpu.memory_write_enable) begin

            // PRINT
            if (dut.cpu.memory_address == MMIO_PRINT_ADDR) begin
                $display("[TB PRINT] %0d (0x%08x)", dut.cpu.memory_write_data,
                         dut.cpu.memory_write_data);
            end

            // DONE
            if (dut.cpu.memory_address == MMIO_DONE_ADDR) begin
                $display("[TB] PROGRAM DONE");
                $finish;
            end
        end
    end

    // ----------------------------------------
    // Timeout
    // ----------------------------------------
    initial begin
        #100000;
        $display("[TB] TIMEOUT");
        $finish;
    end

endmodule
