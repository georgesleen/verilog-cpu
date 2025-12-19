import tb_pkg::*;

/**
 * @brief Full-system testbench driving the CPU top-level.
 *
 * @param WAVE_FILE output VCD path for waveform dumps.
 */
module tb_top #(
    parameter string WAVE_FILE = "build/tb/wave.vcd"
);
    logic clk;
    logic n_rst;

    // Instantiate DUT
    top dut (
        .clk  (clk),
        .n_rst(n_rst)
    );

    // Jank way to load in program
    defparam dut.rom.HEX_FILE = "build/tb/main.hex";

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Reset sequence
    initial begin
        n_rst = 0;
        #20;
        n_rst = 1;
    end

    // Waveform dumping
    initial begin
        $dumpfile(WAVE_FILE);
        $dumpvars(0, dut);
    end

    // MMIO monitor
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

    // Timeout
    initial begin
        #100000;
        $display("[TB] TIMEOUT");
        $finish;
    end

endmodule
