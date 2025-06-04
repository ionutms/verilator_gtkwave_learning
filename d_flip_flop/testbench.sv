// Testbench
module test;

  reg clk;
  reg reset;
  reg d;
  wire q;
  wire qb;
  
  // Instantiate design under test
  dff DFF(.clk(clk), .reset(reset), .d(d), .q(q), .qb(qb));

  initial begin
    // Dump waves
    $dumpfile("test.vcd");
    $dumpvars(0, test);
    
    $display("Reset flop.");
    clk = 0;
    reset = 1;
    d = 1'bx;
    display;
    
    $display("Release reset.");
    d = 1;
    reset = 0;
    display;

    $display("Toggle clk.");
    clk = 1;
    display;

    for (int i = 0; i < 10; i++) begin
      clk = ~clk; // Toggle clock
      display; // Display current state
      end

  end
  
  task display;
    #1 $display("d:%0h, q:%0h, qb:%0h",
      d, q, qb);
  endtask

endmodule