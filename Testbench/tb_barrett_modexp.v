`timescale 1ns / 1ps

module tb_modular_exp;

    reg clk;
    reg rst;
    reg start;
    reg [255:0] base;
    reg [255:0] exp;
    reg [255:0] n;

    wire [255:0] result;
    wire ready;

    modular_exp uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .base(base),
        .exp(exp),
        .n(n),
        .result(result),
        .ready(ready)
    );

    initial clk = 0;
    always #5 clk = ~clk;

task run_test;
    input [255:0] test_base;
    input [255:0] test_exp;
    input [255:0] test_n;
    input [255:0] expected;
    input [127:0] test_name;
    begin
        wait (ready == 1);
        @(posedge clk);
        @(posedge clk);        // ← ADD THIS (let non-blocking updates settle)
        
        // Now apply inputs
        base = test_base;
        exp = test_exp;
        n = test_n;
        start = 1;
        @(posedge clk);
        start = 0;

        wait (ready == 1);
        @(posedge clk);
        @(posedge clk);        // ← ADD THIS (let result settle)

        $display("Test: %s", test_name);
        $display("  Result = %0d", result);
        $display("  Expected = %0d", expected);
        
        if (result == expected) 
            $display("PASS\n");
        else 
            $display("FAIL\n");
    end
endtask

    initial begin
        rst = 1;
        start = 0;

        $dumpfile("modular_exp_tb.vcd");
        $dumpvars(0, tb_modular_exp);

        #20;
        rst = 0;
	#50;
        // Test 1: 7^5 mod 13 = 11 
        run_test(7, 5, 13, 11, "7^5 mod 13");

        // Test 2: 23^8 mod 97 = 16 (NOT 90)
        run_test(23, 8, 97, 16, "23^8 mod 97");

        // Test 3: Small modulus
        run_test(2, 10, 7, 2, "2^10 mod 7");

        // Test 4: Edge case
        run_test(1, 100, 512, 1, "1^100 mod 512");

        // Test 5: Another small test
        run_test(3, 4, 5, 1, "3^4 mod 5");

        // Test 6: 7^5 mod 13 = 11 (NOT 2)
        run_test(12345, 65537, 2168699983, 443164720, "7^5 mod 13");

        // Test 6: 7^5 mod 13 = 11 (NOT 2)
        run_test(443164720, 700808673, 2168699983, 12345, "7^5 mod 13");

        $display("All tests completed.");
        $finish;
    end

endmodule
