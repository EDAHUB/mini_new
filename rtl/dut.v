module async_reg ( 
    input clk 
    ,input [31:0] cnt_in 
    ,output reg [31:0] cnt_out
); 

    reg [31:0] cnt_d1; 

    always @ (posedge clk) begin 
        cnt_d1 <= cnt_in ;
        cnt_out <= cnt_d1 ;
    end

endmodule 

module clkgate ( 
    input clk 
    ,input clk_en 
    ,output clk_out 
); 

    assign clk_out = (clk_en == 1) ? clk : 0 ;

endmodule 

module sram_1p  ( 
    input clk 
    ,input ce 
    ,input we 
    ,input [31:0] bwe 
    ,input [31:0] addr 
    ,input [31:0] data 
    ,output reg [31:0] q 
); 

    reg [31:0] mem [0:65536] ;
    
    always @ (posedge clk) begin
        if (ce && we) begin
            mem[addr] = (data & bwe) | (mem[addr] & ~bwe); 
        end
        if (!ce) begin
            q <= mem[addr];
        end
    end

endmodule 

module counter0 ( 
    input clk_1, 
    input clk_2, 
    input clk_3, 
    input clken, 
    output [31:0] cnt, 
    input rstn 
); 

    reg [31:0] cnt_1; 
    reg [31:0] cnt_2; 
    reg [31:0] cnt_3; 
    wire [31:0] cnt_mem; 

    wire [31:0] cnt_2_sync; 
    wire [31:0] cnt_3_sync; 

    wire clk_1_gated; 
    wire clk_2_gated; 
    wire clk_3_gated; 

    assign cnt = cnt_1  | cnt_2_sync  | cnt_3_sync  | cnt_mem ;

    clkgate u_clkgate_1 (
        .clk(clk_1),
        .clk_en (clken),
        .clk_out (clk_1_gated)
    );

    clkgate u_clkgate_2 (
        .clk(clk_2),
        .clk_en (clken),
        .clk_out (clk_2_gated)
    );

    clkgate u_clkgate_3 (
        .clk(clk_3),
        .clk_en (clken),
        .clk_out (clk_3_gated)
    );

    async_reg u_async_reg_2 (
        .clk(clk_1),
        .cnt_in (cnt_2),
        .cnt_out (cnt_2_sync)
    );

    async_reg u_async_reg_3 (
        .clk(clk_1),
        .cnt_in (cnt_3),
        .cnt_out (cnt_3_sync)
    );

    sram_1p u_sram (
        .clk(clk_1),
        .ce(~clk_1),
        .bwe(32'b11111111111111111111111111111111),
        .we(1'b1),
        .addr(cnt),
        .data(cnt),
        .q (cnt_mem)
    );

    always @ (posedge clk_1_gated or negedge rstn) begin 
        if (~rstn) begin 
            cnt_1 <= 'h0 ; 
        end 
        else begin 
            cnt_1 <= cnt_1 + 1 ;
        end 
    end 
    
    always @ (posedge clk_2_gated or negedge rstn) begin 
        if (~rstn) begin 
            cnt_2 <= 'h0 ; 
        end 
        else begin 
            cnt_2 <= cnt_2 + 1 ;
        end 
    end 
    
    always @ (posedge clk_3_gated or negedge rstn) begin 
        if (~rstn) begin 
            cnt_3 <= 'h0 ; 
        end 
        else begin 
            cnt_3 <= cnt_3 + 1 ;
        end 
    end 
    
endmodule 
    
module counter ( 
    input clk_1, 
    input clk_2, 
    input clk_3, 
    input clken, 
    input [31:0] start, 
    output [31:0] cnt, 
    input rstn 
); 

    reg [31:0] cnt_1; 
    reg [31:0] cnt_2; 
    reg [31:0] cnt_3; 
    wire [31:0] cnt_mem; 

    wire [31:0] cnt_2_sync; 
    wire [31:0] cnt_3_sync; 

    wire clk_1_gated; 
    wire clk_2_gated; 
    wire clk_3_gated; 

    assign cnt = cnt_1  | cnt_2_sync  | cnt_3_sync  | start | cnt_mem ;

    clkgate u_clkgate_1 (
        .clk(clk_1),
        .clk_en (clken),
        .clk_out (clk_1_gated)
    );

    clkgate u_clkgate_2 (
        .clk(clk_2),
        .clk_en (clken),
        .clk_out (clk_2_gated)
    );

    clkgate u_clkgate_3 (
        .clk(clk_3),
        .clk_en (clken),
        .clk_out (clk_3_gated)
    );

    async_reg u_async_reg_2 (
        .clk(clk_1),
        .cnt_in (cnt_2),
        .cnt_out (cnt_2_sync)
    );

    async_reg u_async_reg_3 (
        .clk(clk_1),
        .cnt_in (cnt_3),
        .cnt_out (cnt_3_sync)
    );

    sram_1p u_sram (
        .clk(clk_1),
        .ce(~clk_1),
        .bwe(32'b11111111111111111111111111111111),
        .we(1'b1),
        .addr(cnt),
        .data(cnt),
        .q (cnt_mem)
    );

    always @ (posedge clk_1_gated or negedge rstn) begin 
        if (~rstn) begin 
            cnt_1 <= start ; 
        end 
        else begin 
            cnt_1 <= cnt_1 + 1 ;
        end 
    end 
    
    always @ (posedge clk_2_gated or negedge rstn) begin 
        if (~rstn) begin 
            cnt_2 <= start ; 
        end 
        else begin 
            cnt_2 <= cnt_2 + 1 ;
        end 
    end 
    
    always @ (posedge clk_3_gated or negedge rstn) begin 
        if (~rstn) begin 
            cnt_3 <= start ; 
        end 
        else begin 
            cnt_3 <= cnt_3 + 1 ;
        end 
    end 
    
endmodule 
    
module counter_group (
    input clk_1, 
    input clk_2, 
    input clk_3, 
    input clken, 
    input rstn, 
    output[31:0] cnt 
); 
    
    wire clk_1_gated; 
    wire clk_2_gated; 
    wire clk_3_gated; 

    wire[31:0] outcnt_0_0; 
    wire[31:0] outcnt_0_1; 
    wire[31:0] outcnt_0_2; 
    wire[31:0] outcnt_0_3; 
    wire[31:0] outcnt_1_0; 
    wire[31:0] outcnt_1_1; 
    wire[31:0] outcnt_1_2; 
    wire[31:0] outcnt_1_3; 
    wire[31:0] outcnt_2_0; 
    wire[31:0] outcnt_2_1; 
    wire[31:0] outcnt_2_2; 
    wire[31:0] outcnt_2_3; 
    
    assign cnt = 
                outcnt_2_0 | 
                outcnt_2_1 | 
                outcnt_2_2 | 
                outcnt_2_3 ; 
    
    clkgate u_clkgate_1 (
        .clk(clk_1),
        .clk_en (clken),
        .clk_out (clk_1_gated)
    );

    clkgate u_clkgate_2 (
        .clk(clk_2),
        .clk_en (clken),
        .clk_out (clk_2_gated)
    );

    clkgate u_clkgate_3 (
        .clk(clk_3),
        .clk_en (clken),
        .clk_out (clk_3_gated)
    );

    counter0 u_counter_0_0 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .cnt(outcnt_0_0)
    );

    counter0 u_counter_0_1 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .cnt(outcnt_0_1)
    );

    counter0 u_counter_0_2 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .cnt(outcnt_0_2)
    );

    counter0 u_counter_0_3 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .cnt(outcnt_0_3)
    );

    counter u_counter_1_0 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .start(outcnt_0_0),
        .cnt(outcnt_1_0)
    );

    counter u_counter_1_1 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .start(outcnt_0_1),
        .cnt(outcnt_1_1)
    );

    counter u_counter_1_2 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .start(outcnt_0_2),
        .cnt(outcnt_1_2)
    );

    counter u_counter_1_3 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .start(outcnt_0_3),
        .cnt(outcnt_1_3)
    );

    counter u_counter_2_0 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .start(outcnt_1_0),
        .cnt(outcnt_2_0)
    );

    counter u_counter_2_1 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .start(outcnt_1_1),
        .cnt(outcnt_2_1)
    );

    counter u_counter_2_2 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .start(outcnt_1_2),
        .cnt(outcnt_2_2)
    );

    counter u_counter_2_3 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .start(outcnt_1_3),
        .cnt(outcnt_2_3)
    );

    
endmodule 

module counter_group_l1 (
    input clk_1, 
    input clk_2, 
    input clk_3, 
    input clken, 
    input rstn, 
    output[31:0] cnt 
);  
    
    wire clk_1_gated; 
    wire clk_2_gated; 
    wire clk_3_gated; 

    wire[31:0] outcnt_0_0; 
    wire[31:0] outcnt_0_1; 
    wire[31:0] outcnt_0_2; 
    wire[31:0] outcnt_0_3; 
    wire[31:0] outcnt_1_0; 
    wire[31:0] outcnt_1_1; 
    wire[31:0] outcnt_1_2; 
    wire[31:0] outcnt_1_3; 
    wire[31:0] outcnt_2_0; 
    wire[31:0] outcnt_2_1; 
    wire[31:0] outcnt_2_2; 
    wire[31:0] outcnt_2_3; 
    
    assign cnt = 
	        outcnt_0_0 |
                outcnt_0_1 |
                outcnt_0_2 |
                outcnt_0_3 |
	        outcnt_1_0 |
                outcnt_1_1 |
                outcnt_1_2 |
                outcnt_1_3 |
	        outcnt_2_0 |
                outcnt_2_1 |
                outcnt_2_2 |
                outcnt_2_3 ;
    
    clkgate u_clkgate_1 (
        .clk(clk_1),
        .clk_en (clken),
        .clk_out (clk_1_gated)
    );

    clkgate u_clkgate_2 (
        .clk(clk_2),
        .clk_en (clken),
        .clk_out (clk_2_gated)
    );

    clkgate u_clkgate_3 (
        .clk(clk_3),
        .clk_en (clken),
        .clk_out (clk_3_gated)
    );

    counter_group u_counter_0_0 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .cnt(outcnt_0_0)
    );

    counter_group u_counter_0_1 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .cnt(outcnt_0_1)
    );

    counter_group u_counter_0_2 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .cnt(outcnt_0_2)
    );

    counter_group u_counter_0_3 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .cnt(outcnt_0_3)
    );

    counter_group u_counter_1_0 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .cnt(outcnt_1_0)
    );

    counter_group u_counter_1_1 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .cnt(outcnt_1_1)
    );

    counter_group u_counter_1_2 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .cnt(outcnt_1_2)
    );

    counter_group u_counter_1_3 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .cnt(outcnt_1_3)
    );

    counter_group u_counter_2_0 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .cnt(outcnt_2_0)
    );

    counter_group u_counter_2_1 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .cnt(outcnt_2_1)
    );

    counter_group u_counter_2_2 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .cnt(outcnt_2_2)
    );

    counter_group u_counter_2_3 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .cnt(outcnt_2_3)
    );

    
endmodule 

module counter_group_l2 (
    input clk_1, 
    input clk_2, 
    input clk_3, 
    input clken, 
    input rstn, 
    output[31:0] cnt 
); 
    
    wire clk_1_gated ;
    wire clk_2_gated ; 
    wire clk_3_gated ;

    wire[31:0] outcnt_0_0; 
    wire[31:0] outcnt_0_1; 
    wire[31:0] outcnt_0_2; 
    wire[31:0] outcnt_0_3; 
    wire[31:0] outcnt_1_0; 
    wire[31:0] outcnt_1_1; 
    wire[31:0] outcnt_1_2; 
    wire[31:0] outcnt_1_3; 
    wire[31:0] outcnt_2_0; 
    wire[31:0] outcnt_2_1; 
    wire[31:0] outcnt_2_2; 
    wire[31:0] outcnt_2_3; 
    
    assign cnt = 
                outcnt_0_0 | 
                outcnt_0_1 | 
                outcnt_0_2 | 
                outcnt_0_3 |
                outcnt_1_0 | 
                outcnt_1_1 | 
                outcnt_1_2 | 
                outcnt_1_3 |
                outcnt_2_0 | 
                outcnt_2_1 | 
                outcnt_2_2 | 
                outcnt_2_3 ;
    
    clkgate u_clkgate_1 (
        .clk(clk_1),
        .clk_en (clken),
        .clk_out (clk_1_gated)
    );

    clkgate u_clkgate_2 (
        .clk(clk_2),
        .clk_en (clken),
        .clk_out (clk_2_gated)
    );

    clkgate u_clkgate_3 (
        .clk(clk_3),
        .clk_en (clken),
        .clk_out (clk_3_gated)
    );

    counter_group_l1 u_counter_0_0_l1 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .cnt(outcnt_0_0)
    );

    counter_group_l1 u_counter_0_1_l1 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .cnt(outcnt_0_1)
    );

    counter_group_l1 u_counter_0_2_l1 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .cnt(outcnt_0_2)
    );

    counter_group_l1 u_counter_0_3_l1 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .cnt(outcnt_0_3)
    );

    counter_group_l1 u_counter_1_0_l1 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .cnt(outcnt_1_0)
    );

    counter_group_l1 u_counter_1_1_l1 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .cnt(outcnt_1_1)
    );

    counter_group_l1 u_counter_1_2_l1 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .cnt(outcnt_1_2)
    );

    counter_group_l1 u_counter_1_3_l1 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .cnt(outcnt_1_3)
    );

    counter_group_l1 u_counter_2_0_l1 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .cnt(outcnt_2_0)
    );

    counter_group_l1 u_counter_2_1_l1 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .cnt(outcnt_2_1)
    );

    counter_group_l1 u_counter_2_2_l1 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .cnt(outcnt_2_2)
    );

    counter_group_l1 u_counter_2_3_l1 (
        .clk_1(clk_1_gated),
        .clk_2(clk_2_gated),
        .clk_3(clk_3_gated),
        .rstn(rstn),
        .clken(clken),
        .cnt(outcnt_2_3)
    );

    
endmodule 

module dut_top (
    input clk_1, 
    input clk_2, 
    input clk_3, 
    input clken, 
    input rstn, 
    output[31:0] cnt 
); 
    
    counter_group_l2 u_counter_group_l2 (
        .clk_1(clk_1),
        .clk_2(clk_2),
        .clk_3(clk_3),
        .clken(clken),
        .rstn(rstn),
        .cnt(cnt)
    );

    
endmodule 

