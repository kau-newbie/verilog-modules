// Q3.3 x Q3.3 => Q
// must be i_n_frac >= o_n_frac
module fxp_multiplier_1frac #(
    parameter i_n = 6,
    parameter i_n_frac = 3,
    parameter o_n_frac = 1,
    parameter o_n_int = 5
)(
    input wire signed [(i_n)-1:0] multiplicand,
    input wire signed [(i_n)-1:0] multiplier,
    output wire signed [(o_n_int+o_n_frac)-1:0] product,

    input wire clk,
    input wire rstb
);
localparam res_bits = o_n_int+o_n_frac;
localparam o_msb = (2*i_n_frac)+o_n_int-1;
localparam o_lsb = (2*i_n_frac)-o_n_frac;
/* simple implements
wire signed [2*(i_n)-1:0] tmp = a*b;

assign res = $signed(tmp[o_msb:o_lsb]);
*/
//states
localparam IDLE = 2'b00, PDCT=2'b01, PDSH=2'b10, RESU=2'b11;
integer i; // 32bits because input i_n is too.

reg [1:0] curr_state;
reg [1:0] next_state;
reg en;
// res and multiplier_ are memories.
reg signed [o_msb-1:0] res;
reg signed [(i_n)-1:0] multiplier_;
// ===========partial product implements=========
// sequential logic

// a. state 
always @(posedge clk)begin
    if(~rstb)begin
        curr_state <= IDLE;
    end
    else begin
        curr_state <= next_state;
    end
end

// b. multiplier_
always @(posedge clk)begin
    if(~rstb) multiplier_ <= multiplier;
    else if(curr_state == PDSH) multiplier_ <= multiplier_ >> 1;
end

// multiplicand_ is 2to1 mux
wire [(i_n)-1:0]multiplicand_1;
wire [(i_n)-1:0]multiplicand_2;
assign multiplicand_1 = multiplier_[0]? multiplicand: 0;
assign multiplicand_2 = multiplier_[1]? multiplicand: 0;
// c. res
always @(posedge clk)begin
    if(~rstb) begin
        res <= 0;
    end
    else if(curr_state == PDCT)begin
        if(i==i_n-2)begin
            res <= ((res + multiplicand_1) >>> 1) - multiplicand_2; // since MSB of multiplier is −x(w−1) · 2^(w−1).
        end
        else res <= res + multiplicand_1; // signed + signed -> signed extending
    end
    else if(curr_state == PDSH) res <= res >>> 1; // arithmetic sh
end

// d. i
always @(posedge clk)begin
    if(~rstb) begin
        i <= 0;
    end
    else if(curr_state == PDCT) 
        i <= i+1; 
    else 
        i <= i;
end

//combinational logic
assign product = en? res : 0;

always@(*)begin
    case(curr_state)
        IDLE:begin
            next_state = PDCT;
            en = 1'b0;
        end
        PDCT:begin
            if(i<i_n-2)begin
                next_state = PDSH;
            end
            else next_state = RESU;
            en = 1'b0;
        end
        PDSH:begin
            next_state = PDCT;
            en = 1'b0;
        end
        RESU: begin
            en = 1'b1;
            next_state = RESU;
        end
        default: begin
            next_state = IDLE;
            en = 1'b0;
        end
    endcase
end
endmodule