`timescale 1ns / 1ps

module extended_euclidean(
    input wire clk,
    input wire rst,
    input wire start,
    input wire [255:0] e,
    input wire [255:0] phi,
    output reg [255:0] d,
    output reg valid
);

    // Registers for algorithm
    reg [255:0] r, old_r;
    reg signed [256:0] s, old_s;
    reg signed [256:0] t, old_t;
    reg [3:0] state;
    reg [255:0] quotient;

    localparam IDLE      = 4'd0,
               INIT      = 4'd1,
               COMPUTE_Q = 4'd2,
               COMPUTE   = 4'd3,
               DONE      = 4'd4;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            d <= 0;
            valid <= 0;
            r <= 0;
            old_r <= 0;
            s <= 0;
            old_s <= 0;
            t <= 0;
            old_t <= 0;
            quotient <= 0;
        end else begin
            case (state)
                IDLE: begin
                    valid <= 0;
                    if (start) begin
                        state <= INIT;
                    end
                end
                INIT: begin
                    old_r <= phi;
                    r <= e;
                    old_s <= 256'd1;
                    s <= 256'd0;
                    old_t <= 256'd0;
                    t <= 256'd1;
                    state <= COMPUTE_Q;
                end
                COMPUTE_Q: begin
                    if (r == 0) begin
                        state <= DONE;
                    end else begin
                        quotient <= old_r / r;
                        state <= COMPUTE;
                    end
                end
                COMPUTE: begin
                    // Euclid-steps
                    {
                        old_r, r
                    } <= {
                        r, old_r - quotient * r
                    };
                    {
                        old_s, s
                    } <= {
                        s, old_s - $signed(quotient) * s
                    };
                    {
                        old_t, t
                    } <= {
                        t, old_t - $signed(quotient) * t
                    };
                    state <= COMPUTE_Q;
                end
                DONE: begin
                    // Modular inverse is old_s mod phi
                    if (old_s < 0)
                        d <= old_s + phi;
                    else
                        d <= old_s;
                    valid <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
