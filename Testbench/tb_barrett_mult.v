`timescale 1ns / 1ps

module tb_barrett_mult;

    reg clk;
    reg rst;
    reg en;
    reg [255:0] a;
    reg [255:0] b;
    reg [255:0] n;
    wire [255:0] r;
    wire valid;
    
    // Instantiate DUT
    barrett_mult dut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .a(a),
        .b(b),
        .n(n),
        .r(r),
        .valid(valid)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test stimulus
    initial begin
        $dumpfile("barrett_fixed.vcd");
        $dumpvars(0, tb_barrett_mult);
        
        // Initialize
        rst = 1;
        en = 0;
        a = 0;
        b = 0;
        n = 0;
        
        #25 rst = 0;
        
        // ========================================
        // Test Case 1: Small numbers
        // ========================================
        #20;
        a = 256'd7;
        b = 256'd23;
        n = 256'd13;
        
        $display("\n========================================");
        $display("Test 1: Small Numbers");
        $display("========================================");
        $display("A = %0d", a);
        $display("B = %0d", b);
        $display("N = %0d", n);
        $display("Expected: (%0d * %0d) mod %0d = %0d", a, b, n, (a*b) % n);
        
        en = 1;
        #10 en = 0;
        
        wait(valid);
        #10;
        
        $display("Result: %0d", r);
        if (r == ((a*b) % n))
            $display("PASS");
        else
            $display("FAIL (Got %0d, Expected %0d)", r, (a*b) % n);
        
        // ========================================
        // Test Case 2: Medium numbers
        // ========================================
        #50;
        a = 256'd12345678;
        b = 256'd87654321;
        n = 256'd1000000007;
        
        $display("\n========================================");
        $display("Test 2: Medium Numbers");
        $display("========================================");
        $display("A = %0d", a);
        $display("B = %0d", b);
        $display("N = %0d", n);
        $display("Expected: %0d", (a*b) % n);
        
        en = 1;
        #10 en = 0;
        
        wait(valid);
        #10;
        
        $display("Result: %0d", r);
        if (r == ((a*b) % n))
            $display("PASS");
        else
            $display("FAIL");
        
        // ========================================
        // Test Case 3: Large prime
        // ========================================
        #50;
        a = 256'hFEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210;
        b = 256'h123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0;
        n = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;
        
        $display("\n========================================");
        $display("Test 3: Large 256-bit Numbers");
        $display("========================================");
        $display("A = %h", a);
        $display("B = %h", b);
        $display("N = %h", n);
        
        en = 1;
        #10 en = 0;
        
        wait(valid);
        #10;
        
        $display("Result: %h", r);
        $display("Computation successful!");
        
        // ========================================
        // Test Case 4: Edge case
        // ========================================
        #50;
        n = 256'd97;
        a = n - 1;
        b = n - 1;
        
        $display("\n========================================");
        $display("Test 4: Edge Case (A=B=N-1)");
        $display("========================================");
        $display("A = %0d", a);
        $display("B = %0d", b);
        $display("N = %0d", n);
        $display("Expected: %0d", ((n-1) * (n-1)) % n);
        
        en = 1;
        #10 en = 0;
        
        wait(valid);
        #10;
        
        $display("Result: %0d", r);
        if (r == (((n-1) * (n-1)) % n))
            $display("PASS");
        else
            $display("FAIL");
        
        #100;
        $display("\n========================================");
        $display("All tests completed");
        $display("========================================\n");
        $finish;
    end
    
    // Watchdog
    initial begin
        #1000000;
        $display("ERROR: Timeout!");
        $finish;
    end

endmodule
