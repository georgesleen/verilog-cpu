`timescale 1ns / 1ps

module ProgramCounter_tb ();

  // Constant definition
  localparam int unsigned WIDTH = 32;
  localparam logic [WIDTH-1:0] RESET_VECTOR = 'h0;
  localparam logic [WIDTH-1:0] STRIDE = 'h1;
  localparam time CLOCK_PERIOD = 10ns;

  // Port connections
  logic clk, rst_n, enable, jump;
  logic [WIDTH-1:0] jump_address, pc_address;

  // Clock generation
  initial begin
    clk = 0;
  end

  always begin
    #(CLOCK_PERIOD / 2) clk = ~clk;
  end

  // Device under test
  ProgramCounter #(
      .WIDTH(WIDTH),
      .RESET_VECTOR(RESET_VECTOR),
      .STRIDE(STRIDE)
  ) dut (
      .clk_i(clk),
      .rst_ni(rst_n),
      .enable_i(enable),
      .jump_i(jump),
      .jump_address_i(jump_address),
      .pc_current_o(pc_address)
  );

  // Reference
  logic [WIDTH-1:0] test_counter;


  /// Applies a reset to the program counter
  task automatic apply_reset();
    rst_n = 0;
    enable = 0;
    jump = 0;
    jump_address = '0;
    repeat (2) @(posedge clk);
    rst_n = 1;
    @(posedge clk);
  endtask

  /// Checks if the program counter agrees with what we expect
  ///
  /// @param expected The address that the program counter should be at
  task automatic check_value(input logic [WIDTH-1:0] expected, string message = "");
    @(negedge clk);
    if (pc_address !== expected) begin
      $error("Program counter mismatch: got %0h, expected %0h", pc_address, expected);
    end
  endtask

  // Test counter update
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      test_counter <= RESET_VECTOR;
    end else if (jump) begin
      test_counter <= jump_address;
    end else if (enable) begin
      test_counter <= test_counter + STRIDE;
    end else begin
      test_counter <= test_counter;
    end
  end

  /// Test suite
  initial begin
    $dumpfile("program_counter.vcd");
    $dumpvars(0, ProgramCounter_tb);

    apply_reset();
    check_value(RESET_VECTOR, "after reset");

    repeat (3) @(posedge clk);
    check_value(RESET_VECTOR, "hold when idle");

    enable = 1;
    repeat (3) @(posedge clk);
    enable = 0;
    check_value(RESET_VECTOR + STRIDE * 3, "three clock cycles");

    jump_address = 'hABCD1234;
    jump = 1;
    @(posedge clk);
    jump = 0;
    check_value('hABCD1234, "after jump");

    enable = 1;
    repeat (5) @(posedge clk);
    enable = 0;
    check_value('hABCD1234 + STRIDE * 5, "five clock cycles after jump");

    jump_address = 'h0000FFFF;
    jump = 1;
    enable = 1;
    @(posedge clk);
    jump   = 0;
    enable = 0;
    check_value('h0000FFFF, "load priority check");

    $finish;
  end

endmodule
