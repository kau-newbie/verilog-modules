// 7-segment dec display
// 
module decoder_seg7 #(
    parameter i_n_frac = 1,
    parameter i_n_int = 5
)(
    input wire [i_n_frac-1:0]i_frac,
    input wire [i_n_int-1:0]i_int,
    output wire [47:0]o // 8x6=48
);

wire [23:0]o_2_seg7; // output is fixed, because of DE10-Lite.

/*  요걸 이용해서 instance 및 routing.
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_name
            // 여기에 모듈 인스턴스나 assign을 씀.
        end
    endgenerate
*/

// devide i_frac, i_int into 4bits units each.

localparam lim_int = (i_n_int+3)/4; // because / operation is rouding-down.
localparam lim_frac = i_n_frac/4;

localparam remain=i_n_frac%4;

localparam fi_lim_frac = remain? lim_frac + 1: lim_frac;
// caution: fraction .11(2) means .1100(2) = .C(h). not .0011(2) = .3(10)
// {fi_lim_frac{1'b0}}+i_frac is padding 0s whenever i_n_frac%4==0. <- err.
localparam pad = remain ? 4 - remain : 0; // {0{1'b0}} is err;;; 아니 이게 왜 에러야. -> 구현 변경
wire [4*fi_lim_frac-1:0] frac_ext = i_frac << pad; // << sh는 0이어도 non-err.
assign o_2_seg7 = 24'b0 + {i_int, frac_ext};

genvar i;
generate
    for(i=0; i < (lim_int+fi_lim_frac); i=i+1)begin: seg_blk 
        seg7 s (
            .d(o_2_seg7[4*i+3:4*i]),
            .point(i==fi_lim_frac), // 소수 위 첫 자리에서 끝에 . 을 찍어야함.
            .hex(o[8*i+7:8*i]) 
        );
    end // 쓰지 않으려면야... 8'hff
    for(i=(lim_int+fi_lim_frac); i < 6; i=i+1)begin: seg_blk_no_use // 아 i무조건 초기화해야함.
        assign o[8*i+7:8*i] = 8'hff;
    end
endgenerate
endmodule

module seg7(
    input  wire [3:0] d,
    input  wire point,
    output wire  [7:0] hex      // hex[6:0] = segment 6..0 hex[7] is a point '.'
);

reg [6:0]hex_;
assign hex = point? {1'b0,hex_} : {1'b1,hex_};

always @(*) begin
    case (d)
        4'h0: hex_ = 7'b1000000;
        4'h1: hex_ = 7'b1111001;
        4'h2: hex_ = 7'b0100100;
        4'h3: hex_ = 7'b0110000;
        4'h4: hex_ = 7'b0011001;
        4'h5: hex_ = 7'b0010010;
        4'h6: hex_ = 7'b0000010;
        4'h7: hex_ = 7'b1111000;
        4'h8: hex_ = 7'b0000000;
        4'h9: hex_ = 7'b0010000;
        4'hA: hex_ = 7'b0001000; 
        4'hB: hex_ = 7'b0000011;   
        4'hC: hex_ = 7'b1000110;
        4'hD: hex_ = 7'b0100001;   
        4'hE: hex_ = 7'b0000110;
        4'hF: hex_ = 7'b0001110;
        default: hex_ = 7'b1111111;
    endcase
end

endmodule