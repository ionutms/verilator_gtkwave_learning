module tb; // Testbench module
    test dut(); // Instantiate the test module
    initial begin // Initial block to run at the start of the simulation
        $display("Hello from the testbench"); // Display message from the testbench
        #1; // Wait for 1 time units
        $finish; // End the simulation
    end // End of initial block
endmodule // End of testbench module