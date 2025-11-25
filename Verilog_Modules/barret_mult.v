`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Barrett Modular Multiplier - COMPLETELY COMBINATIONAL
// Matches IEEE paper exactly
//////////////////////////////////////////////////////////////////////////////////

module barrett_mult  (
    input  wire        clk,
    input  wire        rst,
    input  wire        en,
    input  wire [255:0] a,
    input  wire [255:0] b,
    input  wire [255:0] n,
    output wire  [255:0] r,
    output reg          valid
);

    localparam [2:0] IDLE = 3'd0,
                     CALC = 3'd1,
                     DONE = 3'd2;

    reg [2:0] state;

    //---------------------------------------------
    // Find k (bit-length of n)
    //---------------------------------------------
    function [8:0] find_msb;
        input [255:0] val;
        integer i;
        begin
            find_msb = 9'd0;
            for (i = 255; i >= 0; i = i - 1) begin
                if (val[i] == 1'b1) begin
                    find_msb = i[8:0] + 9'd1;
                    i = -1;
                end
            end
        end
    endfunction

    //---------------------------------------------
    // Build 2^shift iteratively (prevents X values)
    //---------------------------------------------
    function [511:0] power_of_two;
        input [8:0] shift;
        reg [511:0] result;
        integer i;
        begin
            result = 512'd1;
            for (i = 0; i < shift && i < 512; i = i + 1) begin
                result = {result[510:0], 1'b0}; // Left shift by 1
            end
            power_of_two = result;
        end
    endfunction

    //---------------------------------------------
    // Safe right shift
    //---------------------------------------------
    function [511:0] rshift_512;
        input [511:0] val;
        input [8:0] shift;
        begin
            if (shift >= 512)
                rshift_512 = 512'd0;
            else if (shift == 0)
                rshift_512 = val;
            else
                rshift_512 = val >> shift;
        end
    endfunction

    function [1023:0] rshift_1024;
        input [1023:0] val;
        input [8:0] shift;
        begin
            if (shift >= 1024)
                rshift_1024 = 1024'd0;
            else if (shift == 0)
                rshift_1024 = val;
            else
                rshift_1024 = val >> shift;
        end
    endfunction

    //---------------------------------------------
    // Barrett Reduction - Step by Step
    //---------------------------------------------
    wire [8:0] k;
    wire [511:0] two_2k;
    wire [511:0] mu;
    wire [511:0] x;
    wire [511:0] q1;
    wire [1023:0] q2;
    wire [511:0] q3;
    wire [511:0] qn;
    wire [511:0] r0_full;
    wire [255:0] r0;
    wire [255:0] r_temp1;
    wire [255:0] r_temp2;
    wire [255:0] r_final;

    // Step 1: k = bit_length(n)
    assign k = find_msb(n);

    // Step 2: mu = floor(2^(2k) / n)
    assign two_2k = power_of_two(2 * k);
    assign mu = (k > 0) ? (two_2k / {256'd0, n}) : 512'd0;

    // Step 3: x = a * b
    assign x = a * b;

    // Step 4: q1 = floor(x / 2^(k-1))
    assign q1 = (k > 1) ? rshift_512(x, k - 1) : x;

    // Step 5: q2 = q1 * mu
    assign q2 = q1 * mu;

    // Step 6: q3 = floor(q2 / 2^(k+1))
    assign q3 = rshift_1024(q2, k + 1);

    // Step 7: qn = q3 * n (only lower 256 bits of q3)
    assign qn = q3[255:0] * n;

    // Step 8: r0 = (x - qn) mod 2^(k+1)
    // We take lower 256 bits as approximation
    assign r0_full = x - qn;
    assign r0 = r0_full[255:0];

    // Step 9: Correction (at most 2 subtractions)
    // First subtraction
    assign r_temp1 = (r0 >= n) ? (r0 - n) : r0;
    
    // Second subtraction (if still >= n)
    assign r_temp2 = (r_temp1 >= n) ? (r_temp1 - n) : r_temp1;
    
    // Final result
    assign r_final = r_temp2;
    assign r = r_temp2;
    

endmodule
