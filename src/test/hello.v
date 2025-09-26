module main;

  reg clk;   // something to dump
  reg done;

  initial begin
    $dumpfile("main.vcd");   // create VCD
    $dumpvars(0, main);      // dump everything in "main"
  end

  // a clock so time advances and signals toggle
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    $display("Hello world");
    done = 0;
    #20 done = 1;            // change a signal
    #10 $finish;
  end

endmodule
