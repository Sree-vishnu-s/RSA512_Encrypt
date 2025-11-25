`timescale 1ns / 1ps

module tb_extended_euclidean;

    reg clk, rst, start;
    reg [255:0] e, phi;
    wire [255:0] d;
    wire valid;

    extended_euclidean uut(
        .clk(clk),
        .rst(rst),
        .start(start),
        .e(e),
        .phi(phi),
        .d(d),
        .valid(valid)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("extended_euclidean.vcd");
        $dumpvars(0, tb_extended_euclidean);

        rst = 1; start = 0;
        #20 rst = 0;

        // Test Case: e = 17, phi = 3120 (from RSA example)
        e = 256'd17;
        phi = 256'd3120;
        start = 1; #10 start = 0;

wait(valid);
#10;
$display("Modular inverse d of e = %0d mod phi = %0d is:", e, phi);
$display("%0d", d);

        // Expected d=2753 since 17*2753 mod 3120 = 1

        #50 $finish;
    end

    initial begin
        #5000;
        $display("Simulation timeout");
        $finish;
    end

endmodule
