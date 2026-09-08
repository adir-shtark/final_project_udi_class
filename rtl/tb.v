`timescale 1ns / 1ps

module tb_design_1;

    // -------------------------------------------------------------------------
    // Testbench Signals
    // -------------------------------------------------------------------------
    reg         clk_in1_0;
    reg         reset_0;
    reg         reset;
    reg  [15:0] sw_0;

    // -------------------------------------------------------------------------
    // Clock Generation (100 MHz -> 10 ns period)
    // -------------------------------------------------------------------------
    initial clk_in1_0 = 1'b0;
    always #5.0 clk_in1_0 = ~clk_in1_0;

    // -------------------------------------------------------------------------
    // Device Under Test (BD Wrapper)
    // Match the module name to your generated wrapper file (e.g., design_1_wrapper)
    // -------------------------------------------------------------------------
    design_1_wrapper dut (
        .clk_in1_0 (clk_in1_0),
        .reset_0   (reset_0),
        .reset     (reset),
        .sw_0      (sw_0)
    );

    // -------------------------------------------------------------------------
    // Stimulus Procedure
    // -------------------------------------------------------------------------
    initial begin
        // Initialize inputs
        reset_0 = 1'b1;     // Hold MMCM/PLL in reset
        reset   = 1'b1;     // Hold system reset block
        sw_0    = 16'd1;    // Increment address by 1 step per cycle

        // Release Clocking Wizard reset after 100 ns
        #100;
        @(posedge clk_in1_0);
        reset_0 = 1'b0;

        // Allow MMCM to lock and Processor System Reset to stabilize
        #400;
        @(posedge clk_in1_0);
        reset   = 1'b0;

        // Run with phase step = 1 through multiple full periods (512 samples)
        #20000;

        // Change step rate to increase waveform frequency
        @(posedge clk_in1_0);
        sw_0 = 16'd10;

        // Run long enough to observe FFT frame output packets
        #50000;

        $finish;
    end

endmodule