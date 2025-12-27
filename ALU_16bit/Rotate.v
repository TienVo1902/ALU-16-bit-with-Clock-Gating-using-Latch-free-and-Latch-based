
module Rotate16_Left (
    input  wire [15:0] in,
    input  wire [3:0]  ctrl,
    output reg  [15:0] out
);
    always @(*) begin
        case (ctrl)
            4'd0:  out = in;
            4'd1:  out = {in[14:0], in[15]};
            4'd2:  out = {in[13:0], in[15:14]};
            4'd3:  out = {in[12:0], in[15:13]};
            4'd4:  out = {in[11:0], in[15:12]};
            4'd5:  out = {in[10:0], in[15:11]};
            4'd6:  out = {in[9:0],  in[15:10]};
            4'd7:  out = {in[8:0],  in[15:9]};
            4'd8:  out = {in[7:0],  in[15:8]};
            4'd9:  out = {in[6:0],  in[15:7]};
            4'd10: out = {in[5:0],  in[15:6]};
            4'd11: out = {in[4:0],  in[15:5]};
            4'd12: out = {in[3:0],  in[15:4]};
            4'd13: out = {in[2:0],  in[15:3]};
            4'd14: out = {in[1:0],  in[15:2]};
            4'd15: out = {in[0],    in[15:1]};
            default: out = {16{1'bx}};
        endcase
    end
endmodule


module Rotate16_Right (
    input  wire [15:0] in,
    input  wire [3:0]  ctrl,
    output reg  [15:0] out
);
    always @(*) begin
        case (ctrl)
            4'd0:  out = in;
            4'd1:  out = {in[0],    in[15:1]};
            4'd2:  out = {in[1:0],  in[15:2]};
            4'd3:  out = {in[2:0],  in[15:3]};
            4'd4:  out = {in[3:0],  in[15:4]};
            4'd5:  out = {in[4:0],  in[15:5]};
            4'd6:  out = {in[5:0],  in[15:6]};
            4'd7:  out = {in[6:0],  in[15:7]};
            4'd8:  out = {in[7:0],  in[15:8]};
            4'd9:  out = {in[8:0],  in[15:9]};
            4'd10: out = {in[9:0],  in[15:10]};
            4'd11: out = {in[10:0], in[15:11]};
            4'd12: out = {in[11:0], in[15:12]};
            4'd13: out = {in[12:0], in[15:13]};
            4'd14: out = {in[13:0], in[15:14]};
            4'd15: out = {in[14:0], in[15]};
            default: out = {16{1'bx}};
        endcase
    end
endmodule
