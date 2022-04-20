`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/04/2021 06:25:07 PM
// Design Name: 
// Module Name: Policy_Server
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


module Policy_Server(
    input           clk,
    input           rst,
    input           wr_FW,
    input           wr_SB,
    input [31:0]    wr_policy_FW,
    input [31:0]    wr_policy_SB,
    //---Interface to IPFW---     
    output reg [31:0]  WSI_FW,    // sending access permission with process id and IP id from policy server
    input      [31:0]  WSO_FW,    // receiving process id and IP id pair to server for policy check
    output reg         CaptureWR_FW, // this signal act as ready
    input              UpdateWR_FW,   //this signal act as go
    //---Interface to Hardware Sandbox---     
    output reg [31:0]  WSI_SB,    
    input      [31:0]  WSO_SB,    
    output reg         CaptureWR_SB, // this signal act as ready
    input              UpdateWR_SB   //this signal act as go
    );
    
    //---Internal Signals---
    wire [3:0]   waddr_FW;
    wire [3:0]   raddr_FW;
    wire [31:0]  rdata_FW;
    wire         ready_FW;
    wire [3:0]   waddr_SB;
    wire [3:0]   raddr_SB;
    wire [31:0]  rdata_SB;
    wire         ready_SB;
    
    ram U0_RAM(
        .clk(clk),
        .rst(rst),
        .wen(wr_FW),
        .waddr(waddr_FW),
        .wdata(wr_policy_FW),
        .go_read(UpdateWR_FW),
        .raddr(raddr_FW),
        .rdata(rdata_FW),
        .ready(ready_FW)
    );
    
    ram U1_RAM(
        .clk(clk),
        .rst(rst),
        .wen(wr_SB),
        .waddr(waddr_SB),
        .wdata(wr_policy_SB),
        .go_read(UpdateWR_SB),
        .raddr(raddr_SB),
        .rdata(rdata_SB),
        .ready(ready_SB)
    );
    
    assign waddr_FW = wr_policy_FW[18:17] * 4 + wr_policy_FW[3:2];
    assign raddr_FW = WSO_FW[18:17] * 4 + WSO_FW[3:2];
  
    assign waddr_SB = wr_policy_SB[4:1];
    assign raddr_SB = WSO_SB[4:1];
    
    always @ ( posedge clk)
    begin
    if ( rst ) begin
        WSI_FW <= 0;
        CaptureWR_FW <= 0;
        WSI_SB <= 0;
        CaptureWR_SB <= 0;
    end
    else begin
        if ( wr_FW == 1'b1 ) begin
                WSI_FW <= 0;
                CaptureWR_FW <= 0;
        end
        else begin         
                if (ready_FW) begin
                    WSI_FW <= rdata_FW;
                    CaptureWR_FW <= 1;
                end
                else begin
                    WSI_FW <= 0;
                    CaptureWR_FW <= 0;
                end
            end
        end
        
        if ( wr_SB == 1'b1 ) begin
                WSI_SB <= 0;
                CaptureWR_SB <= 0;
        end
      else begin         
                if (ready_SB) begin
                    WSI_SB <= rdata_SB;
                    CaptureWR_SB <= 1;
                end
                else begin
                    WSI_SB <= 0;
                    CaptureWR_SB <= 0;
                end
            end
        end
endmodule
  
