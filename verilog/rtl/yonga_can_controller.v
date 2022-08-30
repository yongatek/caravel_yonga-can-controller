// MIT License

// Copyright (c) [2022] [Yonga Technology Microelectronics R&D]

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

// DESCRIPTION

// The yonga_can_controller module manages the operations in CAN peripheral

module yonga_can_controller(
    input	wire	i_controller_clk,
    input  	wire 	i_controller_rst,

	input  	wire 	i_pulse_gen_synced,
    input  	wire 	i_packetizer_rdy,
    input  	wire   	i_ack_slot,
	output 	reg  	o_packetizer_en,
    output 	reg  	o_pulse_gen_en,
		
	input  	wire 	i_packetizer_message_bit,
	input  	wire   	i_message_bit,
	output 	reg   	o_message_bit,

	input  	wire	i_drive_pulse,
	input  	wire	i_sample_pulse,

	input  	wire	i_config_enable,
	input  	wire	i_sys_ctrl_sts_send
	//output 	reg 	[2:0] o_sts_code,
	//output  reg     done_tx
);

	parameter STATE_RESET = 0, STATE_SYNC = 1, STATE_CHECK_IDLE = 2, STATE_DRIVE_DATA = 3, STATE_SAMPLE_DATA = 4, STATE_IFS = 5, STATE_ERROR = 6, STATE_EN_PACKETIZER = 7;
	reg [2:0] o_sts_code;
	reg done_tx;
  	reg [2:0] state_reg;
	reg bit_transmitted;
	reg [5:0] bitcounter_reg;
	reg prev_bit_reg;
	reg [3:0] consecutive_ones_reg;
	reg [3:0] zeros_reg;
	reg is_extended, is_standart;
	reg is_idle;

	always @(posedge i_controller_clk) begin
  		if(i_controller_rst) begin
      		state_reg <= STATE_RESET;
      		o_packetizer_en <= 1'b0;
      		o_pulse_gen_en <= 1'b0;
			o_sts_code <= 3'b0;
			o_message_bit <= 1'b1;
			done_tx <= 1'b0;
			bitcounter_reg <= 6'd0;
			consecutive_ones_reg <= 4'd0;
			is_standart <= 1'b1;
			is_extended <= 1'b0;
			zeros_reg <= 4'd0;
			prev_bit_reg <= 1'b0;
			is_idle <= 1'b0;
    	end
    	else begin
      		case(state_reg)
        		
        		STATE_RESET: begin
					o_sts_code <= 3'b0;
					o_message_bit <= 1'b1;
					done_tx <= 1'b0;
					bitcounter_reg <= 6'd0;
					is_standart <= 1'b1;
          			if((i_config_enable == 0) && (i_sys_ctrl_sts_send == 1)) begin
            			state_reg <= STATE_SYNC;
						o_pulse_gen_en <= 1'b1;
					end
          		end
        		
        		STATE_SYNC: begin
          			if(i_pulse_gen_synced) begin
                        state_reg <= STATE_CHECK_IDLE;
          			end
          		end
				
				STATE_CHECK_IDLE: begin
				o_sts_code <= 3'b0;
					if(i_sample_pulse) begin
						if(~is_idle) begin
							prev_bit_reg <= i_message_bit;
							if(prev_bit_reg) begin
								if(i_message_bit) begin
									consecutive_ones_reg <= consecutive_ones_reg + 1;
								end	
								else begin
									consecutive_ones_reg <= 4'd0;								
								end
								if(consecutive_ones_reg == 4'd9) begin
									consecutive_ones_reg = 4'd0;
									state_reg <= STATE_EN_PACKETIZER;
									is_idle <= 1'b0;
								end
							end
						end	
						else begin
							state_reg <= STATE_EN_PACKETIZER;
							is_idle <= 1'b0;
						end		
					end
				end	
				
				STATE_EN_PACKETIZER: begin
				    o_packetizer_en <= 1'b1;
				    if(i_drive_pulse == 1) begin
				    state_reg <= STATE_DRIVE_DATA;
					end	
				end
			
				STATE_DRIVE_DATA: begin
					if(i_drive_pulse == 1) begin

						state_reg <= STATE_SAMPLE_DATA;
						
						if(bitcounter_reg == 13 && i_packetizer_message_bit == 0) begin
						
							is_standart <= 1'b1;	
							is_extended <= 1'b0;
					
						end 
						else if(bitcounter_reg == 13 && i_packetizer_message_bit == 1) begin
					
						    is_standart <= 1'b0;
							is_extended <= 1'b1;	
					
						end
		
					    bit_transmitted <= i_packetizer_message_bit;
					    o_message_bit <= i_packetizer_message_bit;					    
					       	   						  	
					end
				end
		
				STATE_SAMPLE_DATA: begin
					if(i_sample_pulse == 1) begin
					   bitcounter_reg <= bitcounter_reg + 1;
					   prev_bit_reg <= i_message_bit;
						if(prev_bit_reg) begin
							if(i_message_bit) begin
								consecutive_ones_reg <= consecutive_ones_reg + 1;
							end	
							else begin
								consecutive_ones_reg <= 4'd0;									
							end
						end										
						if(bit_transmitted == i_message_bit) begin
							if(i_ack_slot) begin
								o_sts_code <= 3'h3;
								bitcounter_reg <= 0;
								o_packetizer_en <= 0;
								state_reg <= STATE_IFS;
							end
							else if(i_packetizer_rdy) begin // EOF flag
								o_packetizer_en <= 0;
								bitcounter_reg <= 0;
								state_reg <= STATE_IFS;
							end
							else begin
								state_reg <= STATE_DRIVE_DATA;
							end
						end
						else begin
							if(i_ack_slot == 1) begin
								o_sts_code <= 3'h1;
								state_reg <= STATE_DRIVE_DATA;
							end
							else begin
								if(is_standart) begin
								
									if(bitcounter_reg < 6'd14) begin // Why 14? SOF + 11 bit standart arbitration field + RTR.
										o_sts_code <= 3'h2;
										o_packetizer_en <= 0;				
										state_reg <= STATE_CHECK_IDLE; // Sampled data and transmitted data does not match. Arbitration is lost to another node. STANDART FORMAT
										bitcounter_reg <= 6'd0;
									end
									else begin
										o_sts_code <= 3'h2;
										o_packetizer_en <= 0;
										bitcounter_reg <= 6'd0; // Sampled data and data on bus does not match. Bit error occured. Push eror frame to bus. 
										state_reg <= STATE_ERROR;
									end	
								end
								
								if(is_extended) begin
								
									if(bitcounter_reg < 6'd34) begin // Why 34? SOF + 32 bit extended arbitration field.
										o_sts_code <= 3'h2;
										o_packetizer_en <= 0;			
										state_reg <= STATE_CHECK_IDLE;	// Sampled data and transmitted data does not match. Arbitration is lost to another node. EXTENDED FORMAT
										bitcounter_reg <= 6'd0;
									end
									else begin 
										
										o_sts_code <= 3'h2;
										o_packetizer_en <= 0;
										state_reg <= STATE_ERROR;	// Sampled data and data on bus does not match. Bit error occured. Push eror frame to bus. 
										bitcounter_reg <= 6'd0;								
										
									end
								end	
							end
						end
					end
				end
		
				STATE_IFS: begin
		        if(i_drive_pulse == 1'b1) begin  
					if(bitcounter_reg == 6'd2) begin		
						bitcounter_reg <= 6'd0;
						o_message_bit <= 1;
						is_idle <= 1'b1;
						consecutive_ones_reg <= consecutive_ones_reg + 1;
						done_tx <= 1'b1;
						state_reg <= STATE_RESET;
					end
					else begin	
						state_reg <= STATE_IFS;
						consecutive_ones_reg <= consecutive_ones_reg + 1;
						o_message_bit <= 1;
						bitcounter_reg <= bitcounter_reg + 1;
					end		
				end
			end	
				STATE_ERROR: begin
					state_reg <= STATE_ERROR;
				// FILL HERE 

				end		
			endcase
    	end
  	end
endmodule