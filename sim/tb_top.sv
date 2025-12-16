module tb_top;

    logic clk;
    logic reset;

    // Instantiate DUT
    top dut (
        .clk  (clk),
        .reset(reset)
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
        reset = 1;
        #20;
        reset = 0;
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
