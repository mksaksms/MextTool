`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/04/2021 07:36:58 PM
// Design Name: 
// Module Name: IPFW
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

module IPFW(
    input               clk,
    input               rst,
    input               go,
    input [31:0]        indata_from_bus,
    input [31:0]        inexp_from_bus,
    input [31:0]        inmod_from_bus,
    input [31:0]        header,
    output reg [31:0]   cypher_to_bus,  
    output reg          ready,
    //----IP Interfaces----
    input               ready_IP,
    input [31:0]        cypher_from_ip,
    output reg [31:0]   indata_to_ip,
    output reg [31:0]   inexp_to_ip,
    output reg [31:0]   inmod_to_ip,
    output reg          go_IP,
    //----P1500 Interface to communicate with Policy Server---
    input  [31:0]       WSI,    // Received access permission with process id and IP id from policy server
    output reg [31:0]   WSO,    // sending process id and IP id pair to server for policy check
    input               CaptureWR, // this signal act as ready
    output reg          UpdateWR   //this signal act as go
    );
    
    //----Internal Constants----    
    parameter size = 3 ;
    parameter IDLE = 3'b000, READ_AVC = 3'b001, READ_WAIT_AVC =3'b010, DECISION_AVC = 3'b011, WAIT_IP =3'b100, WAIT_SERVER =3'b101, DECISION_SERVER = 3'b110, WRITE_AVC = 3'b111;
    //parameter IDLE = 2'b00, READ_AVC = 2'b01, DECISION = 2'b10, WRITE_AVC = 2'b11;
    //----Internal Variables----  
    wire [14:0]  IP_id;
    reg [size-1:0]  state;
    reg          hit_reg;
    reg  [1:0]   permission_AVC_reg;
    reg  [31:0]  WSI_reg;  
    wire [1:0]   permission_data;
          
    //----Signals for IP-------;
    //wire [31:0]  data1_in, data2_in;        // input data to IP
   // reg          go_IP;                     // go signal for IP
   // wire         ready_IP;                  // ready signal for IP
    //wire [31:0]  dataout_IP;                // output from IP
    reg          ready_IP_internal;
    reg [31:0]   cypher_from_IP_internal;
    
    reg [31:0]   WSI_internal;
    reg          CaptureWR_internal;
    //----Signals for AVC access----
    reg          go_AVC, WR;
    wire         hit, ready_AVC;        
    wire [14:0]  process_id_data;
    wire [1:0]   permission_AVC;           // access permission received from AVC
    wire [1:0]   permission_server;          // access permission received from policy server
    
    
    //----Static data assignment---
    //assign data1_in = input1_from_bus[63:32];
    //assign data2_in = input2_from_bus[63:32];
    assign IP_id = header[31:17];
    assign process_id_data = header[16:2];
    assign permission_data = header[1:0];
    //assign dataout_IP = output_from_ip;
    //assign permission_server = WSI[1:0];
    assign permission_server = WSI_reg[1:0];
    
    //---AVC instantiation-----
    AVC U0_AVC(
        .proc_id(process_id_data),
        .clk(clk),
        .rst(rst),
        .go(go_AVC),
        .WR(WR),
        .permission(permission_server),
        .hit(hit),
        .access_permission(permission_AVC),
        .ready(ready_AVC)
    );
    
    always @(posedge clk) 
    begin
    if (rst) begin
        ready_IP_internal <= 0;
        cypher_from_IP_internal <= 0;
        WSI_internal <= 0;
        CaptureWR_internal <= 0;
    end else begin
        ready_IP_internal <= ready_IP;
        cypher_from_IP_internal <= cypher_from_ip;
        WSI_internal <= WSI;
        CaptureWR_internal <= CaptureWR;
     end
    end
    //----FSM starts here------
always @(posedge clk) 
begin : FSM
		if(rst) state <= IDLE;
		else begin
		    //---Default Outputs---
//		    go_IP <= 0;
//		              input1_to_ip <= 0;
//                      input2_to_ip <= 0;
//                      output_to_bus <= 0;
//                      ready <= 0;
//                      go_AVC <= 0;
//                      WR <= 0;
//                      WSO <= 0;
//                      UpdateWR <= 0;    
			case(state)
		        IDLE: begin
		              go_IP <= 0;
		              indata_to_ip <= 0;
                      inexp_to_ip <= 0;
                      inmod_to_ip <= 0;
                      cypher_to_bus <= 0;
                      ready <= 0;
                      go_AVC <= 0;
                      WR <= 0;
                      WSO <= 0;
                      UpdateWR <= 0;
		              //---Next State logic---
		              if(go) state <= READ_AVC;
		              else state <= IDLE;
		          end
		        
		        READ_AVC: begin
		              if (IP_id == 1) begin
                          go_AVC <= 1;
                          WR <= 0;
                          //added code for testing..remove it after test
                          //input1_to_ip <= data1_in;  // check with the ready_IP signal later on
                          //input2_to_ip <= data2_in;
                          //go_IP <= 1;
                          //---Next State logic---
                          //state <= WAIT_IP;
                          //---Next State logic---
                          state <= READ_WAIT_AVC;
		              end else begin
		                  //---Output---
		                  ready <= 1;
		                  //output_to_bus <= 1; //added for debug
                          //---Next State logic---
		                  //if(go) state <= READ_AVC;
		                  //else state <= IDLE;
		                  if(go == 0) state <= IDLE;
		              end
		          end
		        
		        READ_WAIT_AVC: begin
		              //---Next State logic---
		              if(ready_AVC) begin
		                  hit_reg <= hit;
		                  permission_AVC_reg <= permission_AVC;
		                  state <= DECISION_AVC;
		                 end
		              else state <= READ_WAIT_AVC;
		        end
		        
		        DECISION_AVC: begin
		                  if (hit_reg == 1) begin
		                      //if (permission_AVC_reg == permission_data) begin
		                      if (permission_data == 3) begin
                                  indata_to_ip <= indata_from_bus;  // check with the ready_IP signal later on
                                  inexp_to_ip <= inexp_from_bus;
                                  inmod_to_ip <= inmod_from_bus;
                                  go_IP <= 1;
                                  //---Next State logic---
                                  state <= WAIT_IP;
		                      end else begin
		                          ready <= 1;      //decision if permission is not granted.
                                  //output_to_bus <= 2;  //added for debug
                                  //---Next State logic---
		                          //if(go) state <= READ_AVC;
		                          //else state <= IDLE;
		                          if(go == 0) state <= IDLE;
		                      end
		                  end else begin
		                  // Access to Poilcy Server
		                      WSO <= header;
                              UpdateWR <= 1;
                              state <= WAIT_SERVER;
		                  end
		          end
		        
		        WAIT_IP: begin
		        //---Next State logic---
		        //if(ready_IP == 1) begin
		        if(ready_IP_internal == 1) begin
		              //output_to_bus <= dataout_IP;
		              cypher_to_bus <= cypher_from_IP_internal;
		              ready <= 1;
		              //if(go) state <= READ_AVC;
		              //else state <= IDLE;
		              if(go == 0) state <= IDLE;
		          end
		              else state <= WAIT_IP;
		        end 
		        
		        WAIT_SERVER: begin
		        if(CaptureWR_internal == 1) begin
		              WSI_reg <= WSI_internal;
		              //ready <= 1;      //added for debug
                      //output_to_bus <= 4;
		              state <= WRITE_AVC;
		          end
		              else state <= WAIT_SERVER;
		        end
		        
		        DECISION_SERVER: begin
		              //if (WSI_reg[1:0] == permission_data) begin
		              if (permission_data == 3) begin
                            indata_to_ip <= indata_from_bus;  // check with the ready_IP signal later on
                            inexp_to_ip <= inexp_from_bus;
                            inmod_to_ip <= inmod_from_bus;
                            go_IP <= 1;
                                  //---Next State logic---
                            state <= WAIT_IP;
		              end else begin
		                    ready <= 1;      //decision if permission is not granted.
                            //output_to_bus <= 3; //added for debug
                            //---Next State logic---
		                    //if(go) state <= READ_AVC;
		                    //else state <= IDLE;
		                    if(go == 0) state <= IDLE;
		              end
		        end
		        
		        WRITE_AVC: begin
                      go_AVC <= 1;
                      WR <= 1;
		              //---Next State logic---
		              if(ready_AVC) state <= DECISION_SERVER;
		              else state <= WRITE_AVC;
		          end
		    endcase 
		  end
        end	
endmodule
