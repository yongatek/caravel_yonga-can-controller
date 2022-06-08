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
	input  	wire	i_sys_ctrl_sts_send,
	output 	reg 	[2:0] o_sts_code
);

	parameter STATE_IDLE = 0, STATE_SYNC = 1 , STATE_DRIVE_DATA = 2, STATE_SAMPLE_DATA = 3, STATE_UPDATE_STS = 4;

  	reg [2:0] state_reg;
	reg bit_transmitted;

	always @(posedge i_controller_clk) begin
  		if(i_controller_rst) begin
      		state_reg <= STATE_IDLE;
      		o_packetizer_en <= 1'b0;
      		o_pulse_gen_en <= 1'b0;
			o_sts_code <= 3'b0;
			o_message_bit <= 1'b1;
    	end
    	else begin
      		case(state_reg)
        		
        		STATE_IDLE: begin
					o_sts_code <= 3'b0;
					o_message_bit <= 1'b1;
          			if((i_config_enable == 0) && (i_sys_ctrl_sts_send == 1)) begin
            			state_reg <= STATE_SYNC;
						o_pulse_gen_en <= 1'b1;
					end
          		end
        		
        		STATE_SYNC: begin
          			if(i_pulse_gen_synced) begin
            			o_packetizer_en <= 1'b1;
						if(i_drive_pulse == 1)
						state_reg <= STATE_DRIVE_DATA;
						
          			end
          		end
				
				STATE_DRIVE_DATA: begin
					if(i_drive_pulse == 1) begin
						state_reg <= STATE_SAMPLE_DATA;
						bit_transmitted <= i_packetizer_message_bit;
						o_message_bit <= i_packetizer_message_bit;
					end
				end
		
				STATE_SAMPLE_DATA: begin
					if(i_sample_pulse == 1) begin
						if(bit_transmitted == i_message_bit) begin
							if(i_ack_slot) begin
								o_sts_code <= 3'h3;
								o_packetizer_en <= 0;
								state_reg <= STATE_UPDATE_STS;
							end
							else if(i_packetizer_rdy) begin // EOF flag
								o_packetizer_en <= 0;
								state_reg <= STATE_UPDATE_STS;
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
								o_sts_code <= 3'h2; // BIT ERROR
								o_packetizer_en <= 0;
								state_reg <= STATE_UPDATE_STS;
							end
						end
					end
				end
		
				STATE_UPDATE_STS: begin
					state_reg <= STATE_IDLE;
				end	
			endcase
    	end
  	end
endmodule
