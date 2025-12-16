module tb_top;

    logic clk;
    logic n_rst;

    // Instantiate DUT
    top dut (
        .clk  (clk),
        .n_rst(n_rst)
    );

    //
    // Clock generation
    //
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100 MHz equivalent
    end

    //
    // Reset sequence
    //
    initial begin
        n_rst = 0;
        #20;
        n_rst = 1;
    end

    //
    // Simulation control
    //
    initial begin
        // Dump waves
        $dumpfile("wave.vcd");
        $dumpvars(0, dut);

        // Run long enough to execute program
        #1000;

        $finish;
    end

endmodule
