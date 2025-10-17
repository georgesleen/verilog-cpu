`timescale 1ns/1ps;

/**
*  Testbench for the program counter in this directory
*/
module tb_program_counter ();

  /**
  *  Local constants
  */
  localparam WIDTH = 32;

  /**
  *  Inputs and outputs
  */
  logic clk, n_rst;
  logic [WIDTH-1:0] bus, address; 

  /**
  *  Device under test
  */
  program_counter #(
  .WIDTH(WIDTH)
  ) dut (
    .clk(clk),
    .n_rst(n_rst),
    .in_bus(bus),
    .out_address(address)
  );

  /**
  *  File output
  */
  initial begin
    $dumpfile("tb_program_counter.vcd");
    $dumpvars(0, tb_program_counter);
  end

  /**
  *  Test suite
  */
  initial begin
    // Reset pc
    n_rst = 1'b0;

    #1;
  
    clk = 1'b0;
    n_rst = 1'b1;
    bus = 32'hffff;

    // Test counting up
    for (int i = 0; i < 3; i++) begin
      @(posedge clk) begin
        if (address !== i) begin
          $error("Address not counting up!");
        end
      end
    end

    // Test n_rst
    @(posedge clk) begin
      n_rst = 1'b0;
      #10;
      if (address !== 0) begin
        $error("Reset not working!");
      end
    end
  
    #10 $finish;
  end

  /**
  *  Clock definition
  */
  always begin
    #10 clk = ~clk;
  end

endmodule
