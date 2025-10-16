`timescale 1ns/10ps

module tb_traffic_light (
  );
  // Inputs
  logic clk, rst_n, timer_done;
  // Outputs
  logic [2:0] ns_light, ew_light;

  // DUT
  traffic_light dut (
    .clk(clk),
    .rst_n(rst_n),
    .timer_done(timer_done),
    .ns_light(ns_light),
    .ew_light(ew_light)
  );

  initial begin
    // Dump everything in this module to the .vcd output
    $dumpfile("traffic_light.vcd");
    $dumpvars(0, tb_traffic_light);

    clk = 1'b0;
    rst_n = 1'b0;
    timer_done = 1'b0;

    for (int i = 0; i < 10; i++) begin
      @(posedge clk);
      timer_done = 1;
      @(posedge clk);
      timer_done = 0;
    end

    #30 rst_n = 1'b1;

    $finish;
  end

  always begin
    #10 clk = ~clk;
  end

endmodule
