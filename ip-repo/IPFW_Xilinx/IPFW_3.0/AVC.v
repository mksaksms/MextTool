`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/04/2021 07:35:36 PM
// Design Name: 
// Module Name: AVC
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



module AVC(
input [14:0] proc_id,
input clk,
input rst,
input go,
input WR,
input [1:0]  permission,
output reg hit,
output reg [1:0] access_permission,
output reg ready
    );

//----Internal Constants----    
parameter cache_entry = 8;
parameter size = 2 ;
parameter IDLE = 2'b01, READ = 2'b10, WRITE = 2'b11;

//----Internal Variables----   
reg [size-1:0]  state; 
reg [16:0]      cache[cache_entry-1:0];

integer i, cache_index = 10, count = 0;

//----FSM starts here------
always @(posedge clk) 
begin : FSM
		if(rst) begin
		  for (i = 0; i < cache_entry; i= i + 1) begin
		      cache[i]<= 0;
		  end
		  hit <= 0;
		  access_permission <= 0;
		  ready <= 0;
		  state <= IDLE;
		end else 
			case(state)
		        IDLE: 
		          begin
		              //---Output---
		              hit <= 0;
		              access_permission <= 0;
		              ready <= 0;
		              //---Next State logic---
		              if(go) begin
		                  if (WR) state <= WRITE;
		                  else state <= READ;
		              end else state <= IDLE;
		          end
		        
		        READ: 
		          begin
		              for (i = 0; i < cache_entry; i= i + 1) begin
		                  if ( proc_id == cache[i][16:2]) begin
		                      cache_index = i;
		                  end 
		              end
		              if (cache_index < cache_entry) begin
		                  hit <= 1;
		                  access_permission <= cache[cache_index][1:0];
		                  ready <= 1;
		                  cache_index <= 10;
		              end else begin
		                  hit <= 0;
		                  access_permission <= 0;
		                  ready <= 1;
		              end
		              //---Next State logic---
		              if(go) begin
		                  if (WR) state <= WRITE;
		                  else state <= READ;
		              end else state <= IDLE;
		          end
		          
		        WRITE: 
		          begin
		              cache[count][16:2]<= proc_id;
		              cache[count][1:0]<= permission;
		              if (count >= (cache_entry - 1)) begin
		                  count <= 0;
		              end else count <= count + 1;
		              hit <= 0;
		              access_permission <= 0;
		              ready <= 1;
		              //---Next State logic---
		              if(go) begin
		                  if (WR) state <= WRITE;
		                  else state <= READ;
		              end else state <= IDLE;
		          end
		    endcase 
        end	
endmodule

