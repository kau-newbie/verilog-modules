// Q3.3 + Q3.3 => Q5.1
// must be i_n_frac >= o_n_frac
module fxp_adder_1frac #(
    parameter i_n = 6,
    parameter i_n_frac = 3,
    parameter o_n_frac = 1,
    parameter o_n_int = 5
)(
    input wire signed [(i_n)-1:0] b,
    input wire signed [(i_n)-1:0] a,
    output wire signed [(i_n)-1:0] res
    //output wire c
    //output wire ovf
);

wire [(i_n):0]tmp = a+b;
assign res = $signed(tmp[(i_n):i_n_frac-o_n_frac]) + $signed({1'b0, tmp[1]}); //rounding

// overflow detection - never happen in this module
/*
    assign ovf = (a[(i_n)-1]==b[(i_n)-1])&
            b([(i_n)-1]!=res[(i_n)-1]);
*/
endmodule