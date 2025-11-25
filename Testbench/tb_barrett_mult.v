`timescale 1ns / 1ps

module tb_barrett_mult;

    reg [255:0] a;
    reg [255:0] b;
    reg [255:0] n;
    wire [255:0] r;
    
    // Instantiate DUT (combinational - no clock/reset needed)
    barrett_mult dut (
        .clk(1'b0),      // Unused in combinational design
        .rst(1'b0),      // Unused in combinational design
        .en(1'b0),       // Unused in combinational design
        .a(a),
        .b(b),
        .n(n),
        .r(r),
        .valid()         // Unused in combinational design
    );
    
    // Test stimulus
    initial begin
        $dumpfile("barrett_fixed.vcd");
        $dumpvars(0, tb_barrett_mult);
        
        // ========================================
        // Test Case 1: Small numbers
        // ========================================
        a = 256'd7;
        b = 256'd23;
        n = 256'd13;
        
        #10; // Wait for combinational logic to settle
        
        $display("\n========================================");
        $display("Test 1: Small Numbers");
        $display("========================================");
        $display("A = %0d", a);
        $display("B = %0d", b);
        $display("N = %0d", n);
        $display("Expected: (%0d * %0d) mod %0d = %0d", a, b, n, (a*b) % n);
        $display("Result: %0d", r);
        
        if (r == ((a*b) % n))
            $display("✓ PASS");
        else
            $display("✗ FAIL (Got %0d, Expected %0d)", r, (a*b) % n);
        
        // ========================================
        // Test Case 2: Medium numbers
        // ========================================
        #50;
        a = 256'd12345678;
        b = 256'd87654321;
        n = 256'd1000000007;
        
        #10; // Wait for combinational logic
        
        $display("\n========================================");
        $display("Test 2: Medium Numbers");
        $display("========================================");
        $display("A = %0d", a);
        $display("B = %0d", b);
        $display("N = %0d", n);
        $display("Expected: %0d", (a*b) % n);
        $display("Result: %0d", r);
        
        if (r == ((a*b) % n))
            $display("✓ PASS");
        else
            $display("✗ FAIL");
        
        // ========================================
        // Test Case 3: Large prime (secp256k1)
        // ========================================
        #50;
        a = 256'hFEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210;
        b = 256'h123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0;
        n = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;
        
        #10; // Wait for combinational logic
        
        $display("\n========================================");
        $display("Test 3: Large 256-bit Numbers (secp256k1 prime)");
        $display("========================================");
        $display("A = %h", a);
        $display("B = %h", b);
        $display("N = %h", n);
        $display("Result: %h", r);
        $display("✓ Computation completed (no reference available for verification)");
        
        // ========================================
        // Test Case 4: Edge case (A=B=N-1)
        // ========================================
        #50;
        n = 256'd97;
        a = n - 1;
        b = n - 1;
        
        #10; // Wait for combinational logic
        
        $display("\n========================================");
        $display("Test 4: Edge Case (A=B=N-1)");
        $display("========================================");
        $display("A = %0d", a);
        $display("B = %0d", b);
        $display("N = %0d", n);
        $display("Expected: %0d", ((n-1) * (n-1)) % n);
        $display("Result: %0d", r);
        
        if (r == (((n-1) * (n-1)) % n))
            $display("✓ PASS");
        else
            $display("✗ FAIL");
        
        // ========================================
        // Test Case 5: Zero cases
        // ========================================
        #50;
        a = 256'd0;
        b = 256'd100;
        n = 256'd13;
        
        #10;
        
        $display("\n========================================");
        $display("Test 5: Zero Input (A=0)");
        $display("========================================");
        $display("A = %0d", a);
        $display("B = %0d", b);
        $display("N = %0d", n);
        $display("Expected: 0");
        $display("Result: %0d", r);
        
        if (r == 0)
            $display("✓ PASS");
        else
            $display("✗ FAIL");
        
        // ========================================
        // Test Case 6: A and B less than N
        // ========================================
        #50;
        a = 256'd5;
        b = 256'd7;
        n = 256'd100;
        
        #10;
        
        $display("\n========================================");
        $display("Test 6: Both inputs < N");
        $display("========================================");
        $display("A = %0d", a);
        $display("B = %0d", b);
        $display("N = %0d", n);
        $display("Expected: %0d", (a*b) % n);
        $display("Result: %0d", r);
        
        if (r == ((a*b) % n))
            $display("✓ PASS");
        else
            $display("✗ FAIL");
        
        #100;
        $display("\n========================================");
        $display("All tests completed");
        $display("========================================\n");
        $finish;
    end

endmodule
