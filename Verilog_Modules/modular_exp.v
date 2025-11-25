`timescale 1ns / 1ps

module modular_exp(
    input wire clk,
    input wire rst,
    input wire start,
    input wire [255:0] base,
    input wire [255:0] exp,
    input wire [255:0] n,
    output reg [255:0] result,
    output reg ready
);

 localparam S_IDLE    = 3'd0,
           S_LOAD    = 3'd1,
           S_INIT    = 3'd2,    // Wait for initialization to settle
           S_START   = 3'd3,
           S_WAIT    = 3'd4,
           S_ACC     = 3'd5,
           S_AWAIT   = 3'd6,
           S_DONE    = 3'd7;
    reg [2:0] state;
    reg [255:0] acc;
    reg [255:0] curr_base;
    reg [255:0] curr_exp;
    integer i;
    reg calc_needed;

    reg bm_start;
    reg [255:0] bm_A, bm_B, bm_N;
    wire [255:0] bm_result;
    wire bm_ready;

barrett_mult BM (
    .clk(clk),
    .rst(rst),
    .en(bm_start),         // changed from start to en
    .a(bm_A),             //  A -> a
    .b(bm_B),             //  B -> b
    .n(bm_N),
    .r(bm_result),        // result -> r
    .valid(bm_ready)      //ready -> valid
);


    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= S_IDLE;
            ready <= 1;
            result <= 0;
            acc    <= 1;
            curr_base <= 0;
            curr_exp  <= 0;
            i <= 0;
            bm_start <= 0;
            calc_needed <= 0;
        end else begin
            case (state)
                S_IDLE: begin
                    ready <= 1;
                    if (start) begin
                        acc        <= 1;
                        curr_base  <= base;
                        curr_exp   <= exp;
                        i          <= 1;
                        state      <= S_LOAD;
                        ready      <= 0;
                    end
                end

                S_LOAD: begin
                    // Set initial value
                    if (curr_exp[0] == 1'b1)
                        acc <= curr_base; // A is only if lsb is 1
                    state <= S_INIT;
                end

		S_INIT: begin
    			// Wait one clock cycle for acc to be updated
   			state <= S_START;
		end

                S_START: begin
                    if (i < 256) begin
                        bm_A <= curr_base;
                        bm_B <= curr_base; 
                        bm_N <= n;
                        bm_start <= 1;
                        state <= S_WAIT;
                    end else begin
                        state <= S_DONE;
                    end
                end

                S_WAIT: begin
                    bm_start <= 0;
                    if (bm_ready) begin
                        curr_base <= bm_result;
                        if (curr_exp[i]==1'b1) begin
                            state <=S_ACC;
                        end else begin
                            state <= S_START;
			    i <= i + 1;
                        end
		    
                    end
                end

                S_ACC: begin
                        bm_A <= acc;
                        bm_B <= curr_base;
                        bm_N <= n;
                        bm_start <= 1;
                        state <= S_AWAIT;
                    end

                S_AWAIT: begin
                    bm_start <= 0;
                    if (bm_ready) begin
                        acc <= bm_result;
                        state <=S_START;
                            i <= i + 1;
                        end
		    
                    end
                

                S_DONE: begin
                    result <= acc;
                    ready  <= 1;
                    state  <= S_IDLE;
                end

                default: state <= S_IDLE;
            endcase
        end
    end
endmodule
