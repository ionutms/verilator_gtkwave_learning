// Testbench
module test_bench_module;  // Testbench module
  design_module_name DESIGN_INSTANCE_NAME();  // Instantiate design under test

  initial begin
    // Dump waves
    $dumpfile("test_bench_module.vcd");  // Specify the VCD file
    $dumpvars(0, test_bench_module);     // Dump all variables in the test module
    #1;                                 // Wait for a time unit
    $display("Hello from testbench!");  // Display message

  end

endmodule