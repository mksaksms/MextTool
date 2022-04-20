`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/04/2021 06:23:36 PM
// Design Name: 
// Module Name: ram
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ram(
    input           clk,
    input           rst,
    input           wen,
    input [3:0]     waddr,
    input [31:0]    wdata,
    input           go_read,
    input [3:0]     raddr,
    output reg [31:0]rdata,
    output reg      ready
    );
 
reg [31:0] memory[15:0];

integer i;

always @ ( posedge clk)
    begin
    if ( rst ) begin
        for (i = 0; i < 16; i= i + 1) begin
		      memory[i]<= 0;
		  end
		  ready <= 0;
		  rdata <= 0;
    end
    else begin
        if ( wen == 1'b1 )
            begin
                memory[waddr] <= wdata;
                rdata <= 0;
                ready <= 0;
            end
         else begin
         if (go_read == 1) begin
            rdata <= memory[raddr];
            ready <= 1;
         end else begin
            rdata <= 0;
            ready <= 0;
         end
        end
    end
    end
endmodule

