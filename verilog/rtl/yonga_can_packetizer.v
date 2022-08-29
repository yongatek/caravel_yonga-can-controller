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

// The yonga_can_packetizer module forms a CAN frame in accordance with CAN 2.0B standard

module yonga_can_packetizer(
    input wire i_packetizer_clk,
    input wire i_packetizer_rst,

    input wire i_packetizer_en,
		input wire i_drive_pulse,
    input wire [11-1:0] i_packetizer_message_sid,
    input wire i_packetizer_message_ide,
    input wire i_packetizer_message_r0,
	input wire i_packetizer_message_r1,
	input wire i_packetizer_message_srr,
    input wire [18-1:0] i_packetizer_message_eid,

    input wire i_packetizer_message_rtr,
    input wire [4-1:0] i_packetizer_message_dlc,

    input wire [8-1:0] i_packetizer_message_data_byte_0,
    input wire [8-1:0] i_packetizer_message_data_byte_1,
    input wire [8-1:0] i_packetizer_message_data_byte_2,
    input wire [8-1:0] i_packetizer_message_data_byte_3,
    input wire [8-1:0] i_packetizer_message_data_byte_4,
    input wire [8-1:0] i_packetizer_message_data_byte_5,
    input wire [8-1:0] i_packetizer_message_data_byte_6,
    input wire [8-1:0] i_packetizer_message_data_byte_7,

    output wire o_packetizer_rdy,
    input wire i_packetizer_req,

		output reg o_packetizer_message_bit,
		input wire i_packetizer_message_bit,
		output reg o_ack_slot
  );

    // state registers
    parameter STATE_IDLE = 0, STATE_SOF = 1 , STATE_SID = 2, STATE_RTR = 3, STATE_SRR = 4, STATE_IDE = 5, STATE_EID = 6,STATE_CTRL = 7,
			STATE_DATA = 8, STATE_CRC = 9, STATE_ACK = 10, STATE_EOF = 11, STATE_IFS = 12;
	
	reg  [3:0] state_reg;
	reg  [3:0] state_reg_previous; 
  // data registers
  reg [11-1:0] message_sid;
  reg message_ide;
  reg message_r0;
  reg [18-1:0] message_eid;
  reg message_rtr;
  reg message_srr;  
  reg [6-1:0] message_control;
  reg [4-1:0] message_dlc;
  reg [64-1:0] message_data;

  // control and status registers
  reg prev_bit_reg;
  reg [7-1:0] bit_counter_reg;
  reg stuff_bit_exception_reg;
  reg [4-1:0] num_of_consec_ones_reg;
  reg [4-1:0] num_of_consec_zeros_reg;
  reg packetizer_rdy_reg;
  wire stuff_bit_exception_negedge;
  reg stuff_bit_exception_prev;

  // CRC register
  reg [14:0] crc_reg;
  wire       next_bit;
  wire       crc_valid;
  reg crc_enable;
  reg prev_drive;
	wire negedge_drive;

  assign next_bit  = state_reg != STATE_CRC ? o_packetizer_message_bit : 1'b0;
  assign crc_valid = crc_enable & ~stuff_bit_exception_negedge;
  assign negedge_drive = prev_drive & ~i_drive_pulse;
  assign stuff_bit_exception_negedge = stuff_bit_exception_prev & ~stuff_bit_exception_reg;
  always@(posedge i_packetizer_clk)
  begin
	prev_drive <= i_drive_pulse;
    if(i_packetizer_rst == 1'b1)
    begin
      prev_bit_reg            <= 1'b0;
      stuff_bit_exception_reg <= 1'b0;
      num_of_consec_ones_reg  <= 4'b0;
      num_of_consec_zeros_reg <= 4'b0;
      bit_counter_reg         <= 7'b0;
      packetizer_rdy_reg      <= 1'b0;
      state_reg               <= STATE_IDLE;
      crc_reg                 <= 15'b0; 
		o_ack_slot   						<= 1'b0;
		crc_enable <= 1'b0;
		
    end
    else
    begin
	  stuff_bit_exception_prev <= stuff_bit_exception_reg;
	  state_reg_previous <= state_reg;
	  if(prev_drive) begin
      if(crc_valid)
      begin
		//crc_next = next_bit ^ crc_reg[14];
        crc_reg <= crc_reg << 1'b1;
        if(next_bit ^ crc_reg[14])
        begin
          crc_reg <= (crc_reg<<1'b1) ^ 16'hC599;
        end
		//crc_reg = crc_reg & 16'h7FFF;
      end
	  end
			if(i_drive_pulse) begin
				case(state_reg)
					STATE_IDLE:
					begin
						packetizer_rdy_reg <= 1'b0;
						o_packetizer_message_bit <= 1'b1;
						message_sid 	 <= i_packetizer_message_sid;
						message_ide 	 <= i_packetizer_message_ide;
						message_eid 	 <= i_packetizer_message_eid;
						message_rtr 	 <= i_packetizer_message_rtr;
						message_srr 	 <= i_packetizer_message_srr;
						
						message_data 	 <= {i_packetizer_message_data_byte_7,i_packetizer_message_data_byte_6, i_packetizer_message_data_byte_5, i_packetizer_message_data_byte_4, i_packetizer_message_data_byte_3, i_packetizer_message_data_byte_2, i_packetizer_message_data_byte_1, i_packetizer_message_data_byte_0};
						if(i_packetizer_message_ide==1)
						begin
							message_control  <= {i_packetizer_message_r1, i_packetizer_message_r0, i_packetizer_message_dlc};
						end
						else
						begin
							message_control  <= {i_packetizer_message_ide, i_packetizer_message_r0, i_packetizer_message_dlc};
						end
						crc_reg <= 15'b0;
						
						if(i_packetizer_message_dlc >= 4'd8 )
						begin
							message_dlc <= 4'd8;
						end
						else
						begin
							message_dlc <= i_packetizer_message_dlc;
						end
						//if(i_packetizer_en)
						//begin
							state_reg 		 <= STATE_SOF;
							crc_enable <= 1'b0;
								
								//prev_bit_reg <= 1'b0;
								
						//end
					end
	
					STATE_SOF :
					begin
						
						if(i_packetizer_en == 0)
							state_reg <= STATE_IDLE;
						else begin
						o_packetizer_message_bit <= 1'b0;
						// start counting bit levels - this is needed to inject stuff bits into bitstream
						prev_bit_reg <= 1'b0;
						num_of_consec_zeros_reg <= num_of_consec_zeros_reg + 1'b1;
						crc_enable <= 1'b1;
						state_reg <= STATE_SID;
							
						end
						
					end
	
					STATE_SID :
					begin
						if(stuff_bit_exception_reg)
						begin
							o_packetizer_message_bit <= ~message_sid[10];
							crc_enable <= 1'b1;
							prev_bit_reg <= ~message_sid[10];			
				
							// shift message_sid register left by 1-bit
							message_sid <= message_sid << 1'b1;
	
							// reset stuff_bit_exception_reg
							stuff_bit_exception_reg <= 1'b0;
							if(i_packetizer_en == 0)
								state_reg <= STATE_IDLE;
							else if(bit_counter_reg == 7'd10)
							begin
								bit_counter_reg <= 7'd0;
								if(message_ide==1)
									state_reg <= STATE_SRR;
								else
									state_reg <= STATE_RTR;
							end
							else
							begin
							// increment bit counter
								bit_counter_reg <= bit_counter_reg + 1'b1;
								state_reg <= STATE_SID;
							end
						end
						else
						begin
							// check possible stuff condition
							if(prev_bit_reg == message_sid[10])
							begin
								if(message_sid[10] == 1'b1)
								begin
									o_packetizer_message_bit <= message_sid[10];
									crc_enable <= 1'b1;
									// set next value of prev_bit_reg
									prev_bit_reg <= message_sid[10];
						
									if(num_of_consec_ones_reg == 4'd3 && message_sid[10] == 1'b1)
									begin
										// stuff condition occurs
										stuff_bit_exception_reg <= 1'b1;
										//message_sid <= message_sid << 1'b1;
										// reset num_of_consec_ones_reg
										num_of_consec_ones_reg <= 4'd0;
									end
									else
									begin
										// increment num_of_consec_ones_reg
										num_of_consec_ones_reg <= num_of_consec_ones_reg + 1'b1;
	
										// shift message_sid register left by 1-bit
										message_sid <= message_sid << 1'b1;
	
										// check if the current bit sent is the last bit of SID field
										if(i_packetizer_en == 0)
											state_reg <= STATE_IDLE;
										else if(bit_counter_reg == 7'd10)
										begin
											bit_counter_reg <= 7'd0;
											if(message_ide==1)
												state_reg <= STATE_SRR;
											else
												state_reg <= STATE_RTR;
										end
										else
										begin
											// increment bit counter
											bit_counter_reg <= bit_counter_reg + 1'b1;
											state_reg <= STATE_SID;
										end
									end
								end
								else
								begin
									o_packetizer_message_bit <= message_sid[10];
									crc_enable <= 1'b1;
									// set next value of prev_bit_reg
									prev_bit_reg <= message_sid[10];
	
									if(num_of_consec_zeros_reg == 4'd3 && message_sid[10] == 1'b0)
									begin
										// stuff condition occurs
										stuff_bit_exception_reg <= 1'b1;
	
										// reset num_of_consec_zeros_reg
										num_of_consec_zeros_reg <= 4'd0;
									end
									else
									begin
										// increment num_of_consec_zeros_reg
										num_of_consec_zeros_reg <= num_of_consec_zeros_reg + 1'b1;
	
										// shift message_sid register left by 1-bit
										message_sid <= message_sid << 1'b1;
	
										// check if the current bit sent is the last bit of SID field
										if(i_packetizer_en == 0)
											state_reg <= STATE_IDLE;
										else if(bit_counter_reg == 7'd10)
										begin
											bit_counter_reg <= 7'd0;
											if(message_ide==1)
												state_reg <= STATE_SRR;
											else
												state_reg <= STATE_RTR;
										end
										else
										begin
											// increment bit counter
											bit_counter_reg <= bit_counter_reg + 1'b1;
											state_reg <= STATE_SID;
										end
									end
								end
							end
							else
							begin
								o_packetizer_message_bit <= message_sid[10];
								crc_enable <= 1'b1;
								// shift message_sid register left by 1-bit
								message_sid <= message_sid << 1'b1;
	
								// set next value of prev_bit_reg
								prev_bit_reg <= message_sid[10];
	
								// check if the current bit sent is the last bit of SID field
								if(i_packetizer_en == 0)
										state_reg <= STATE_IDLE;
								else if(bit_counter_reg == 7'd10)
								begin
									bit_counter_reg <= 7'd0;
									if(message_ide==1)
										state_reg <= STATE_SRR;
									else
										state_reg <= STATE_RTR;
								end
								else begin
									bit_counter_reg <= bit_counter_reg + 1'b1;
									state_reg <= STATE_SID;
								end
	
								// reset stuff condition detect counters
								num_of_consec_zeros_reg <= 4'd0;
								num_of_consec_ones_reg <= 4'd0;
							end
						end
					end
	
					STATE_RTR :
					begin
						if(stuff_bit_exception_reg)
						begin
							o_packetizer_message_bit <= ~message_rtr;
							crc_enable <= 1'b1;
							prev_bit_reg <= ~message_rtr;
	
							// reset stuff_bit_exception_reg
							stuff_bit_exception_reg <= 1'b0;
							if(i_packetizer_en == 0)
								state_reg <= STATE_IDLE;
							else
								state_reg <= STATE_CTRL;
						end
						else
						begin
							if(prev_bit_reg == message_rtr)
							begin
								if(message_rtr == 1'b1)
								begin
									o_packetizer_message_bit <= message_rtr;
									crc_enable <= 1'b1;
									prev_bit_reg <= message_rtr;
	
									if(num_of_consec_ones_reg == 4'd3 && message_rtr == 1'b1)
									begin
										stuff_bit_exception_reg <= 1'b1;
										num_of_consec_ones_reg <= 4'd0;
									end
									else
									begin
										num_of_consec_ones_reg <= num_of_consec_ones_reg + 1'b1;
										if(i_packetizer_en == 0)
											state_reg <= STATE_IDLE;
										else
											state_reg <= STATE_CTRL;
									end
	
								end
								else
								begin
									o_packetizer_message_bit <= message_rtr;
									crc_enable <= 1'b1;
									prev_bit_reg <= message_rtr;
	
									if(num_of_consec_zeros_reg == 4'd3 && message_rtr == 1'b0)
									begin
										stuff_bit_exception_reg <= 1'b1;
										num_of_consec_zeros_reg <= 4'd0;
									end
									else
									begin
										num_of_consec_zeros_reg <= num_of_consec_zeros_reg + 1'b1;
										if(i_packetizer_en == 0)
											state_reg <= STATE_IDLE;
										else
											state_reg <= STATE_CTRL;
									end
								end
							end
							else
							begin
								o_packetizer_message_bit <= message_rtr;
								crc_enable <= 1'b1;
								prev_bit_reg <= message_rtr;
	
								// reset stuff condition detect counters
								num_of_consec_zeros_reg <= 4'd0;
								num_of_consec_ones_reg  <= 4'd0;
								if(i_packetizer_en == 0)
									state_reg <= STATE_IDLE;
								else
									state_reg <= STATE_CTRL;
							end
						end
					end
					
					STATE_SRR :
					begin
						if(stuff_bit_exception_reg)
						begin
							o_packetizer_message_bit <= ~message_srr;
							crc_enable <= 1'b1;
							prev_bit_reg <= ~message_srr;
	
							// reset stuff_bit_exception_reg
							stuff_bit_exception_reg <= 1'b0;
							if(i_packetizer_en == 0)
								state_reg <= STATE_IDLE;
							else
								state_reg <= STATE_IDE;
						end
						else
						begin
							if(prev_bit_reg == message_srr)
							begin
								if(message_srr == 1'b1)
								begin
									o_packetizer_message_bit <= message_srr;
									crc_enable <= 1'b1;
									prev_bit_reg <= message_srr;
	
									if(num_of_consec_ones_reg == 4'd3 && message_srr == 1'b1)
									begin
										stuff_bit_exception_reg <= 1'b1;
										num_of_consec_ones_reg <= 4'd0;
									end
									else
									begin
										num_of_consec_ones_reg <= num_of_consec_ones_reg + 1'b1;
										if(i_packetizer_en == 0)
											state_reg <= STATE_IDLE;
										else
											state_reg <= STATE_IDE;
									end
	
								end
								else
								begin
									o_packetizer_message_bit <= message_srr;
									crc_enable <= 1'b1;
									prev_bit_reg <= message_srr;
	
									if(num_of_consec_zeros_reg == 4'd3 && message_srr == 1'b0)
									begin
										stuff_bit_exception_reg <= 1'b1;
										num_of_consec_zeros_reg <= 4'd0;
									end
									else
									begin
										num_of_consec_zeros_reg <= num_of_consec_zeros_reg + 1'b1;
										if(i_packetizer_en == 0)
											state_reg <= STATE_IDLE;
										else
											state_reg <= STATE_IDE;
									end
								end
							end
							else
							begin
								o_packetizer_message_bit <= message_srr;
								crc_enable <= 1'b1;
								prev_bit_reg <= message_srr;
	
								// reset stuff condition detect counters
								num_of_consec_zeros_reg <= 4'd0;
								num_of_consec_ones_reg  <= 4'd0;
								if(i_packetizer_en == 0)
									state_reg <= STATE_IDLE;
								else
									state_reg <= STATE_IDE;
							end
						end
					end
					STATE_IDE :
					begin
						if(stuff_bit_exception_reg)
						begin
							o_packetizer_message_bit <= ~message_ide;
							crc_enable <= 1'b1;
							prev_bit_reg <= ~message_ide;
	
							// reset stuff_bit_exception_reg
							stuff_bit_exception_reg <= 1'b0;
							if(i_packetizer_en == 0)
								state_reg <= STATE_IDLE;
							else
								state_reg <= STATE_EID;
						end
						else
						begin
							if(prev_bit_reg == message_ide)
							begin
								if(message_ide == 1'b1)
								begin
									o_packetizer_message_bit <= message_ide;
									crc_enable <= 1'b1;
									prev_bit_reg <= message_ide;
	
									if(num_of_consec_ones_reg == 4'd3 && message_ide == 1'b1)
									begin
										stuff_bit_exception_reg <= 1'b1;
										num_of_consec_ones_reg <= 4'd0;
									end
									else
									begin
										num_of_consec_ones_reg <= num_of_consec_ones_reg + 1'b1;
										if(i_packetizer_en == 0)
											state_reg <= STATE_IDLE;
										else
											state_reg <= STATE_EID;
									end
	
								end
								else
								begin
									o_packetizer_message_bit <= message_ide;
									crc_enable <= 1'b1;
									prev_bit_reg <= message_ide;
	
									if(num_of_consec_zeros_reg == 4'd3 && message_ide == 1'b0)
									begin
										stuff_bit_exception_reg <= 1'b1;
										num_of_consec_zeros_reg <= 4'd0;
									end
									else
									begin
										num_of_consec_zeros_reg <= num_of_consec_zeros_reg + 1'b1;
										if(i_packetizer_en == 0)
											state_reg <= STATE_IDLE;
										else
											state_reg <= STATE_EID;
									end
								end
							end
							else
							begin
								o_packetizer_message_bit <= message_ide;
								crc_enable <= 1'b1;
								prev_bit_reg <= message_ide;
	
								// reset stuff condition detect counters
								num_of_consec_zeros_reg <= 4'd0;
								num_of_consec_ones_reg  <= 4'd0;
								if(i_packetizer_en == 0)
									state_reg <= STATE_IDLE;
								else
									state_reg <= STATE_EID;
							end
						end
					end
					
					STATE_EID :
					begin
						if(stuff_bit_exception_reg)
						begin
							o_packetizer_message_bit <= ~message_eid[17];
							crc_enable <= 1'b1;
							prev_bit_reg <= ~message_eid[17];			
				
							// shift message_eid register left by 1-bit
							message_eid <= message_eid << 1'b1;
	
							// reset stuff_bit_exception_reg
							stuff_bit_exception_reg <= 1'b0;
							if(i_packetizer_en == 0)
								state_reg <= STATE_IDLE;
							else if(bit_counter_reg == 7'd17)
							begin
								bit_counter_reg <= 7'd0;
								state_reg <= STATE_RTR;
							end
							else
							begin
							// increment bit counter
								bit_counter_reg <= bit_counter_reg + 1'b1;
								state_reg <= STATE_EID;
							end
						end
						else
						begin
							// check possible stuff condition
							if(prev_bit_reg == message_eid[17])
							begin
								if(message_eid[17] == 1'b1)
								begin
									o_packetizer_message_bit <= message_eid[17];
									crc_enable <= 1'b1;
									// set next value of prev_bit_reg
									prev_bit_reg <= message_eid[17];
						
									if(num_of_consec_ones_reg == 4'd3 && message_eid[17] == 1'b1)
									begin
										// stuff condition occurs
										stuff_bit_exception_reg <= 1'b1;
										//message_sid <= message_sid << 1'b1;
										// reset num_of_consec_ones_reg
										num_of_consec_ones_reg <= 4'd0;
									end
									else
									begin
										// increment num_of_consec_ones_reg
										num_of_consec_ones_reg <= num_of_consec_ones_reg + 1'b1;
	
										// shift message_eid register left by 1-bit
										message_eid <= message_eid << 1'b1;
	
										// check if the current bit sent is the last bit of SID field
										if(i_packetizer_en == 0)
											state_reg <= STATE_IDLE;
										else if(bit_counter_reg == 7'd17)
										begin
											bit_counter_reg <= 7'd0;
											state_reg <= STATE_RTR;
										end
										else
										begin
											// increment bit counter
											bit_counter_reg <= bit_counter_reg + 1'b1;
											state_reg <= STATE_EID;
										end
									end
								end
								else
								begin
									o_packetizer_message_bit <= message_eid[17];
									crc_enable <= 1'b1;
									// set next value of prev_bit_reg
									prev_bit_reg <= message_eid[17];
	
									if(num_of_consec_zeros_reg == 4'd3 && message_eid[17] == 1'b0)
									begin
										// stuff condition occurs
										stuff_bit_exception_reg <= 1'b1;
	
										// reset num_of_consec_zeros_reg
										num_of_consec_zeros_reg <= 4'd0;
									end
									else
									begin
										// increment num_of_consec_zeros_reg
										num_of_consec_zeros_reg <= num_of_consec_zeros_reg + 1'b1;
	
										// shift message_eid register left by 1-bit
										message_eid <= message_eid << 1'b1;
	
										// check if the current bit sent is the last bit of SID field
										if(i_packetizer_en == 0)
											state_reg <= STATE_IDLE;
										else if(bit_counter_reg == 7'd17)
										begin
											bit_counter_reg <= 7'd0;
											state_reg <= STATE_RTR;
										end
										else
										begin
											// increment bit counter
											bit_counter_reg <= bit_counter_reg + 1'b1;
											state_reg <= STATE_EID;
										end
									end
								end
							end
							else
							begin
								o_packetizer_message_bit <= message_eid[17];
								crc_enable <= 1'b1;
								// shift message_eid register left by 1-bit
								message_eid <= message_eid << 1'b1;
	
								// set next value of prev_bit_reg
								prev_bit_reg <= message_eid[17];
	
								// check if the current bit sent is the last bit of SID field
								if(i_packetizer_en == 0)
										state_reg <= STATE_IDLE;
								else if(bit_counter_reg == 7'd17)
								begin
									bit_counter_reg <= 7'd0;
									state_reg <= STATE_RTR;
								end
								else begin
									bit_counter_reg <= bit_counter_reg + 1'b1;
									state_reg <= STATE_EID;
								end
	
								// reset stuff condition detect counters
								num_of_consec_zeros_reg <= 4'd0;
								num_of_consec_ones_reg <= 4'd0;
							end
						end
					end
	
					STATE_CTRL:
					begin
						if(stuff_bit_exception_reg)
						begin			
							o_packetizer_message_bit <= ~message_control[5];
							crc_enable <= 1'b1;
							// shift message control register left by 1-bit
							message_control <= message_control << 1'b1;
							
							// reset stuff_bit_exception_reg
							stuff_bit_exception_reg <= 1'b0;
							prev_bit_reg <= ~message_control[5];
							
							if(i_packetizer_en == 0)
								state_reg <= STATE_IDLE;
							else if(bit_counter_reg == 7'd5)
							begin
								bit_counter_reg <= 7'd0;
								if(message_rtr)
								begin
									state_reg <= STATE_CRC;
								end
								else
								begin
									state_reg <= STATE_DATA;
								end
							end
							else 
							begin
								// increment bit counter
								bit_counter_reg <= bit_counter_reg + 1'b1;
								state_reg <= STATE_CTRL;
								//end		
							end
						end
				
						else
						begin
							// check possible stuff condition
							if(prev_bit_reg == message_control[5])
							begin
								if(message_control[5] == 1'b1)
								begin
									o_packetizer_message_bit <= message_control[5];
									crc_enable <= 1'b1;
									// set next value of prev_bit_reg
									prev_bit_reg <= message_control[5];
	
									if(num_of_consec_ones_reg == 4'd3  && message_control[5] == 1'b1)
									begin
										// stuff condition occurs
										stuff_bit_exception_reg <= 1'b1;
										// reset num_of_consec_ones_reg
										num_of_consec_ones_reg <= 4'd0;
									end
									else
									begin
										// increment num_of_consec_ones_reg
										num_of_consec_ones_reg <= num_of_consec_ones_reg + 1'b1;
	
										// shift message_control register left by 1-bit
										message_control <= message_control << 1'b1;
	
										// check if the current bit sent is the last bit of message_control field
										if(i_packetizer_en == 0)
											state_reg <= STATE_IDLE;
										else if(bit_counter_reg == 7'd5)
										begin
											bit_counter_reg <= 7'd0;
											if(message_rtr)
											begin
												state_reg <= STATE_CRC;
											end
											else
											begin
												state_reg <= STATE_DATA;
											end
										end
										else begin
											// increment bit counter
											bit_counter_reg <= bit_counter_reg + 1'b1;
											state_reg <= STATE_CTRL;
										end
									end
								end
								else
								begin
									o_packetizer_message_bit <= message_control[5];
									crc_enable <= 1'b1;
									// set next value of prev_bit_reg
									prev_bit_reg <= message_control[5];
	
									if(num_of_consec_zeros_reg == 4'd3 && message_control[5] == 1'b0) 
									begin
										// stuff condition occurs
										stuff_bit_exception_reg <= 1'b1;
										// reset num_of_consec_zeros_reg
										num_of_consec_zeros_reg <= 4'd0;
									end
									else
									begin
										// increment num_of_consec_zeros_reg
										num_of_consec_zeros_reg <= num_of_consec_zeros_reg + 1'b1;
	
										// shift message_sid register left by 1-bit
										message_control <= message_control << 1'b1;
	
										// check if the current bit sent is the last bit of SID field
										if(i_packetizer_en == 0)	
											state_reg <= STATE_IDLE;	
										else if(bit_counter_reg == 7'd5)
										begin
											bit_counter_reg <= 7'd0;
											if(message_rtr)
											begin
												state_reg <= STATE_CRC;
											end
											else
											begin
												state_reg <= STATE_DATA;
											end
										end
										else
										begin
											// increment bit counter
											bit_counter_reg <= bit_counter_reg + 1'b1;
											state_reg <= STATE_CTRL;
										end
									end
								end
							end
							else
							begin
								o_packetizer_message_bit <= message_control[5];
								crc_enable <= 1'b1;
								// shift message_sid register left by 1-bit
								message_control <= message_control << 1'b1;
	
								// set next value of prev_bit_reg
								prev_bit_reg <= message_control[5];
	
								// check if the current bit sent is the last bit of SID field
								if(i_packetizer_en == 0)
									state_reg <= STATE_IDLE;							
								else if(bit_counter_reg == 7'd5)
								begin
									bit_counter_reg <= 7'd0;
									if(message_rtr)
									begin
										state_reg <= STATE_CRC;
									end
									else
									begin
										state_reg <= STATE_DATA;
									end
								end
								else
								begin
									bit_counter_reg <= bit_counter_reg + 1'b1;
									state_reg <= STATE_CTRL;
								end
	
								// reset stuff condition detect counters
								num_of_consec_zeros_reg <= 4'd0;
								num_of_consec_ones_reg <= 4'd0;
							end
						end
					end
	
					STATE_DATA:
					begin
						if(message_dlc == 'd0)
						begin
							//message_data <= null;
							if(i_packetizer_en == 0)
								state_reg <= STATE_IDLE;
							else
								state_reg <= STATE_CRC;
						end
	
	
						else if(message_dlc == 'd1)
						begin
							if(stuff_bit_exception_reg)
							begin
								o_packetizer_message_bit <= ~message_data[7];
								crc_enable <= 1'b1;
								// shift message_sid register left by 1-bit
								message_data <= message_data << 1'b1;
	
								// reset stuff_bit_exception_reg
								stuff_bit_exception_reg <= 1'b0;
					
								prev_bit_reg <= ~message_data[7];
	
								if(i_packetizer_en == 0)
									state_reg <= STATE_IDLE;
								else if(bit_counter_reg == 7'd7)
								begin
									bit_counter_reg <= 7'd0;
									state_reg <= STATE_CRC;
								end
								else
								begin
									// increment bit counter
									bit_counter_reg <= bit_counter_reg + 1'b1;
									state_reg <= STATE_DATA;
								end
							end
							else
							begin
								// check possible stuff condition
								if(prev_bit_reg == message_data[7])
								begin
									if(message_data[7] == 1'b1)
									begin
										o_packetizer_message_bit <= message_data[7];
										crc_enable <= 1'b1;
										// set next value of prev_bit_reg
										prev_bit_reg <= message_data[7];
	
										if(num_of_consec_ones_reg == 4'd3 && message_data[7] == 1'b1)
										begin
											// stuff condition occurs
											stuff_bit_exception_reg <= 1'b1;
	
											// reset num_of_consec_ones_reg
											num_of_consec_ones_reg <= 4'd0;
										end
										else
										begin
											// increment num_of_consec_ones_reg
											num_of_consec_ones_reg <= num_of_consec_ones_reg + 1'b1;
	
											// shift message_sid register left by 1-bit
											message_data <= message_data << 1'b1;
	
											// check if the current bit sent is the last bit of SID field
											
											if(i_packetizer_en == 0)
													state_reg <= STATE_IDLE;
											else if(bit_counter_reg == 7'd7)
											begin
												bit_counter_reg <= 7'd0;
												state_reg <= STATE_CRC;
											end
											else
											begin
												// increment bit counter
												bit_counter_reg <= bit_counter_reg + 1'b1;
												state_reg <= STATE_DATA;
											end
										end
									end
									else
									begin
										o_packetizer_message_bit <= message_data[7];
										crc_enable <= 1'b1;
										// set next value of prev_bit_reg
										prev_bit_reg <= message_data[7];
	
										if(num_of_consec_zeros_reg == 4'd3 && message_data[7] == 1'b0)
										begin
											// stuff condition occurs
											stuff_bit_exception_reg <= 1'b1;
	
											// reset num_of_consec_zeros_reg
											num_of_consec_zeros_reg <= 4'd0;
										end
										else
										begin
											// increment num_of_consec_zeros_reg
											num_of_consec_zeros_reg <= num_of_consec_zeros_reg + 1'b1;
	
											// shift message_sid register left by 1-bit
											message_data <= message_data << 1'b1;
	
											// check if the current bit sent is the last bit of SID field
											if(i_packetizer_en == 0)
													state_reg <= STATE_IDLE;
											else if(bit_counter_reg == 7'd7)
											begin
												bit_counter_reg <= 7'd0;
												state_reg <= STATE_CRC;
											end
											else
											begin
												// increment bit counter
												bit_counter_reg <= bit_counter_reg + 1'b1;
												state_reg <= STATE_DATA;
											end
										end
									end
								end
								else
								begin
									o_packetizer_message_bit <= message_data[7];
									crc_enable <= 1'b1;
									// shift message_sid register left by 1-bit
									message_data <= message_data << 1'b1;
	
									// set next value of prev_bit_reg
									prev_bit_reg <= message_data[7];
	
									// check if the current bit sent is the last bit of SID field
									
									if(i_packetizer_en == 0)
											state_reg <= STATE_IDLE;
									else if(bit_counter_reg == 7'd7)
									begin
										bit_counter_reg <= 7'd0;
										state_reg <= STATE_CRC;
									end
									else
									begin
										bit_counter_reg <= bit_counter_reg + 1'b1;
										state_reg <= STATE_DATA;
									end
									// reset stuff condition detect counters
									num_of_consec_zeros_reg <= 4'd0;
									num_of_consec_ones_reg <= 4'd0;
								end
							end            
						end
	
	
						else if(message_dlc == 'd2)
						begin
	
							if(stuff_bit_exception_reg)
							begin
								o_packetizer_message_bit <= ~message_data[15];
								crc_enable <= 1'b1;
								// shift message_sid register left by 1-bit
								message_data <= message_data << 1'b1;
	
								// reset stuff_bit_exception_reg
								stuff_bit_exception_reg <= 1'b0;
								prev_bit_reg <= ~message_data[15];
								
								if(i_packetizer_en == 0)
										state_reg <= STATE_IDLE;
								else if(bit_counter_reg == 7'd15)
								begin
									bit_counter_reg <= 7'd0;
									state_reg <= STATE_CRC;
								end
								else
								begin
									// increment bit counter
									bit_counter_reg <= bit_counter_reg + 1'b1;
									state_reg <= STATE_DATA;
								end			  
							end
							else
							begin
								// check possible stuff condition
								if(prev_bit_reg == message_data[15])
								begin
									if(message_data[15] == 1'b1)
									begin
										o_packetizer_message_bit <= message_data[15];
										crc_enable <= 1'b1;
										// set next value of prev_bit_reg
										prev_bit_reg <= message_data[15];
	
										if(num_of_consec_ones_reg == 4'd3 && message_data[15] == 1'b1)
										begin
											// stuff condition occurs
											stuff_bit_exception_reg <= 1'b1;
	
											// reset num_of_consec_ones_reg
											num_of_consec_ones_reg <= 4'd0;
										end
										else
										begin
											// increment num_of_consec_ones_reg
											num_of_consec_ones_reg <= num_of_consec_ones_reg + 1'b1;
	
											// shift message_sid register left by 1-bit
											message_data <= message_data << 1'b1;
	
											// check if the current bit sent is the last bit of SID field
											if(i_packetizer_en == 0)
													state_reg <= STATE_IDLE;										
											else if (bit_counter_reg == 7'd16)
											begin
												bit_counter_reg <= 7'd0;
												state_reg <= STATE_CRC;
											end
											else
											begin
												// increment bit counter
												bit_counter_reg <= bit_counter_reg + 1'b1;
												state_reg <= STATE_DATA;
											end
										end
									end
									else
									begin
										o_packetizer_message_bit <= message_data[15];
										crc_enable <= 1'b1;
										// set next value of prev_bit_reg
										prev_bit_reg <= message_data[15];
	
										if(num_of_consec_zeros_reg == 4'd3 && message_data[15] == 1'b0)
										begin
											// stuff condition occurs
											stuff_bit_exception_reg <= 1'b1;
	
											// reset num_of_consec_zeros_reg
											num_of_consec_zeros_reg <= 4'd0;
										end
										else
										begin
											// increment num_of_consec_zeros_reg
											num_of_consec_zeros_reg <= num_of_consec_zeros_reg + 1'b1;
	
											// shift message_sid register left by 1-bit
											message_data <= message_data << 1'b1;
	
											// check if the current bit sent is the last bit of SID field
											if(i_packetizer_en == 0)
													state_reg <= STATE_IDLE;
											else if(bit_counter_reg == 7'd15)
											begin
												bit_counter_reg <= 7'd0;
												state_reg <= STATE_CRC;
											end
											else
											begin
												// increment bit counter
												bit_counter_reg <= bit_counter_reg + 1'b1;
												state_reg <= STATE_DATA;
											end
										end
									end
								end
								else
								begin
									o_packetizer_message_bit <= message_data[15];
									crc_enable <= 1'b1;
									// shift message_sid register left by 1-bit
									message_data <= message_data << 1'b1;
	
									// set next value of prev_bit_reg
									prev_bit_reg <= message_data[15];
	
									// check if the current bit sent is the last bit of SID field
									if(i_packetizer_en == 0)
											state_reg <= STATE_IDLE;
									else if(bit_counter_reg == 7'd15)
									begin
										bit_counter_reg <= 7'd0;
										state_reg <= STATE_CRC;
									end
									else
									begin
										bit_counter_reg <= bit_counter_reg + 1'b1;
										state_reg <= STATE_DATA;
									end
	
									// reset stuff condition detect counters
									num_of_consec_zeros_reg <= 4'd0;
									num_of_consec_ones_reg <= 4'd0;
								end
							end
	
						end
	
	
						else if(message_dlc == 'd3)
						begin
	
							if(stuff_bit_exception_reg)
							begin
								o_packetizer_message_bit <= ~message_data[23];
								crc_enable <= 1'b1;
								// shift message_sid register left by 1-bit
								message_data <= message_data << 1'b1;
	
								// reset stuff_bit_exception_reg
								stuff_bit_exception_reg <= 1'b0;
					
								prev_bit_reg <= ~message_data[23];
	
								if(i_packetizer_en == 0)
										state_reg <= STATE_IDLE;
								else if(bit_counter_reg == 7'd23)
								begin
									bit_counter_reg <= 7'd0;
									state_reg <= STATE_CRC;
								end
								else
								begin
									// increment bit counter
									bit_counter_reg <= bit_counter_reg + 1'b1;
									state_reg <= STATE_DATA;
								end			  
							end
							else
							begin
								// check possible stuff condition
								if(prev_bit_reg == message_data[23])
								begin
									if(message_data[23] == 1'b1)
									begin
										o_packetizer_message_bit <= message_data[23];
										crc_enable <= 1'b1;
										// set next value of prev_bit_reg
										prev_bit_reg <= message_data[23];
	
										if(num_of_consec_ones_reg == 4'd3 && message_data[23] == 1'b1)
										begin
											// stuff condition occurs
											stuff_bit_exception_reg <= 1'b1;
	
											// reset num_of_consec_ones_reg
											num_of_consec_ones_reg <= 4'd0;
										end
										else
										begin
											// increment num_of_consec_ones_reg
											num_of_consec_ones_reg <= num_of_consec_ones_reg + 1'b1;
	
											// shift message_sid register left by 1-bit
											message_data <= message_data << 1'b1;
	
											// check if the current bit sent is the last bit of SID field
											if(i_packetizer_en == 0)
													state_reg <= STATE_IDLE;
											else if(bit_counter_reg == 7'd23)
											begin
												bit_counter_reg <= 7'd0;
												state_reg <= STATE_CRC;
											end
											else
											begin
												// increment bit counter
												bit_counter_reg <= bit_counter_reg + 1'b1;
												state_reg <= STATE_DATA;
											end
										end
									end
									else
									begin
										o_packetizer_message_bit <= message_data[23];
										crc_enable <= 1'b1;
										// set next value of prev_bit_reg
										prev_bit_reg <= message_data[23];
	
										if(num_of_consec_zeros_reg == 4'd3 && message_data[23] == 1'b0)
										begin
											// stuff condition occurs
											stuff_bit_exception_reg <= 1'b1;
	
											// reset num_of_consec_zeros_reg
											num_of_consec_zeros_reg <= 4'd0;
										end
										else
										begin
											// increment num_of_consec_zeros_reg
											num_of_consec_zeros_reg <= num_of_consec_zeros_reg + 1'b1;
	
											// shift message_sid register left by 1-bit
											message_data <= message_data << 1'b1;
	
											// check if the current bit sent is the last bit of SID field
											if(i_packetizer_en == 0)
													state_reg <= STATE_IDLE;
											else if(bit_counter_reg == 7'd23)
											begin
												bit_counter_reg <= 7'd0;
												state_reg <= STATE_CRC;
											end
											else
											begin
												// increment bit counter
												bit_counter_reg <= bit_counter_reg + 1'b1;
												state_reg <= STATE_DATA;
											end
										end
									end
								end
								else
								begin
									o_packetizer_message_bit <= message_data[23];
									crc_enable <= 1'b1;
									// shift message_sid register left by 1-bit
									message_data <= message_data << 1'b1;
	
									// set next value of prev_bit_reg
									prev_bit_reg <= message_data[23];
	
									// check if the current bit sent is the last bit of SID field
									if(i_packetizer_en == 0)
											state_reg <= STATE_IDLE;
									else if(bit_counter_reg == 7'd23)
									begin
										bit_counter_reg <= 7'd0;
										state_reg <= STATE_CRC;
									end
									else
									begin
										bit_counter_reg <= bit_counter_reg + 1'b1;
										state_reg <= STATE_DATA;
									end
	
									// reset stuff condition detect counters
									num_of_consec_zeros_reg <= 4'd0;
									num_of_consec_ones_reg <= 4'd0;
								end
							end
	
						end
	
	
						else if(message_dlc == 'd4)
						begin
	
							if(stuff_bit_exception_reg)
							begin
								o_packetizer_message_bit <= ~message_data[31];
								crc_enable <= 1'b1;
								// shift message_sid register left by 1-bit
								message_data <= message_data << 1'b1;
	
								// reset stuff_bit_exception_reg
								stuff_bit_exception_reg <= 1'b0;
					
								prev_bit_reg <= ~message_data[31];
								if(i_packetizer_en == 0)
									state_reg <= STATE_IDLE;
								else if(bit_counter_reg == 7'd31)
								begin
									bit_counter_reg <= 7'd0;
									state_reg <= STATE_CRC;
								end
								else
								begin
									// increment bit counter
									bit_counter_reg <= bit_counter_reg + 1'b1;
									state_reg <= STATE_DATA;
								end			  
							end
							else
							begin
								// check possible stuff condition
								if(prev_bit_reg == message_data[31])
								begin
									if(message_data[31] == 1'b1)
									begin
										// push next SID bit into FIFO
										o_packetizer_message_bit <= message_data[31];
										crc_enable <= 1'b1;
										// set next value of prev_bit_reg
										prev_bit_reg <= message_data[31];
	
										if(num_of_consec_ones_reg == 4'd3 && message_data[31] == 1'b1)
										begin
											// stuff condition occurs
											stuff_bit_exception_reg <= 1'b1;
	
											// reset num_of_consec_ones_reg
											num_of_consec_ones_reg <= 4'd0;
										end
										else
										begin
											// increment num_of_consec_ones_reg
											num_of_consec_ones_reg <= num_of_consec_ones_reg + 1'b1;
	
											// shift message_sid register left by 1-bit
											message_data <= message_data << 1'b1;
	
											// check if the current bit sent is the last bit of SID field
											if(i_packetizer_en == 0)
												state_reg <= STATE_IDLE;
											else if(bit_counter_reg == 7'd31)
											begin
												bit_counter_reg <= 7'd0;
												state_reg <= STATE_CRC;
											end
											else
											begin
												// increment bit counter
												bit_counter_reg <= bit_counter_reg + 1'b1;
												state_reg <= STATE_DATA;
											end
										end
									end
									else
									begin
										o_packetizer_message_bit <= message_data[31];
										crc_enable <= 1'b1;
										// set next value of prev_bit_reg
										prev_bit_reg <= message_data[31];
	
										if(num_of_consec_zeros_reg == 4'd3 && message_data[31] == 1'b0)
										begin
											// stuff condition occurs
											stuff_bit_exception_reg <= 1'b1;
	
											// reset num_of_consec_zeros_reg
											num_of_consec_zeros_reg <= 4'd0;
										end
										else
										begin
											// increment num_of_consec_zeros_reg
											num_of_consec_zeros_reg <= num_of_consec_zeros_reg + 1'b1;
	
											// shift message_sid register left by 1-bit
											message_data <= message_data << 1'b1;
	
											// check if the current bit sent is the last bit of SID field
											if(i_packetizer_en == 0)
												state_reg <= STATE_IDLE;
											else if(bit_counter_reg == 7'd31)
											begin
												bit_counter_reg <= 7'd0;
												state_reg <= STATE_CRC;
											end
											else
											begin
												// increment bit counter
												bit_counter_reg <= bit_counter_reg + 1'b1;
												state_reg <= STATE_DATA;
											end
										end
									end
								end
								else
								begin
									// push next SID bit into FIFO
								o_packetizer_message_bit <= message_data[31];
								crc_enable <= 1'b1;
									// shift message_sid register left by 1-bit
									message_data <= message_data << 1'b1;
	
									// set next value of prev_bit_reg
									prev_bit_reg <= message_data[31];
	
									// check if the current bit sent is the last bit of SID field
									if(i_packetizer_en == 0)
										state_reg <= STATE_IDLE;
									else if(bit_counter_reg == 7'd31)
									begin
										bit_counter_reg <= 7'd0;
										state_reg <= STATE_CRC;
									end
									else
									begin
										bit_counter_reg <= bit_counter_reg + 1'b1;
										state_reg <= STATE_DATA;
									end
	
									// reset stuff condition detect counters
									num_of_consec_zeros_reg <= 4'd0;
									num_of_consec_ones_reg <= 4'd0;
								end
							end
	
						end
	
	
						else if(message_dlc == 'd5)
						begin
	
							if(stuff_bit_exception_reg)
							begin
								// push stuff bit into FIFO
								o_packetizer_message_bit <= ~message_data[39];
								crc_enable <= 1'b1;
								// shift message_sid register left by 1-bit
								message_data <= message_data << 1'b1;
	
								// reset stuff_bit_exception_reg
								stuff_bit_exception_reg <= 1'b0;
								prev_bit_reg <= ~message_data[39];
	
								if(i_packetizer_en == 0)
										state_reg <= STATE_IDLE;	
								else if(bit_counter_reg == 7'd39)
								begin
									bit_counter_reg <= 7'd0;
									state_reg <= STATE_CRC;
								end
								else
								begin
									// increment bit counter
									bit_counter_reg <= bit_counter_reg + 1'b1;
									state_reg <= STATE_DATA;
								end			  
							end
							else
							begin
								// check possible stuff condition
								if(prev_bit_reg == message_data[39])
								begin
									if(message_data[39] == 1'b1)
									begin
										// push next SID bit into FIFO
										o_packetizer_message_bit <= message_data[39];
										crc_enable <= 1'b1;
										// set next value of prev_bit_reg
										prev_bit_reg <= message_data[39];
	
										if(num_of_consec_ones_reg == 4'd3 && message_data[39] == 1'b1)
										begin
											// stuff condition occurs
											stuff_bit_exception_reg <= 1'b1;
	
											// reset num_of_consec_ones_reg
											num_of_consec_ones_reg <= 4'd0;
										end
										else
										begin
											// increment num_of_consec_ones_reg
											num_of_consec_ones_reg <= num_of_consec_ones_reg + 1'b1;
	
											// shift message_sid register left by 1-bit
											message_data <= message_data << 1'b1;
	
											// check if the current bit sent is the last bit of SID field
											if(i_packetizer_en == 0)
												state_reg <= STATE_IDLE;
											else if(bit_counter_reg == 7'd39)
											begin
												bit_counter_reg <= 7'd0;
												state_reg <= STATE_CRC;
											end
											else
											begin
												// increment bit counter
												bit_counter_reg <= bit_counter_reg + 1'b1;
												state_reg <= STATE_DATA;
											end
										end
									end
									else
									begin
										o_packetizer_message_bit <= message_data[39];
										crc_enable <= 1'b1;
										// set next value of prev_bit_reg
										prev_bit_reg <= message_data[39];
	
										if(num_of_consec_zeros_reg == 4'd3 && message_data[39] == 1'b0)
										begin
											// stuff condition occurs
											stuff_bit_exception_reg <= 1'b1;
	
											// reset num_of_consec_zeros_reg
											num_of_consec_zeros_reg <= 4'd0;
										end
										else
										begin
											// increment num_of_consec_zeros_reg
											num_of_consec_zeros_reg <= num_of_consec_zeros_reg + 1'b1;
	
											// shift message_sid register left by 1-bit
											message_data <= message_data << 1'b1;
	
											// check if the current bit sent is the last bit of SID field
											if(i_packetizer_en == 0)
												state_reg <= STATE_IDLE;
											else if(bit_counter_reg == 7'd39)
											begin
												bit_counter_reg <= 7'd0;
												state_reg <= STATE_CRC;
											end
											else
											begin
												// increment bit counter
												bit_counter_reg <= bit_counter_reg + 1'b1;
												state_reg <= STATE_DATA;
											end
										end
									end
								end
								else
								begin
									// push next SID bit into FIFO
									o_packetizer_message_bit <= message_data[39];
									crc_enable <= 1'b1;
									// shift message_sid register left by 1-bit
									message_data <= message_data << 1'b1;
	
									// set next value of prev_bit_reg
									prev_bit_reg <= message_data[39];
	
									// check if the current bit sent is the last bit of SID field
									if(i_packetizer_en == 0)
										state_reg <= STATE_IDLE;
									else if(bit_counter_reg == 7'd39)
									begin
										bit_counter_reg <= 7'd0;
										state_reg <= STATE_CRC;
									end
									else
									begin
										bit_counter_reg <= bit_counter_reg + 1'b1;
										state_reg <= STATE_DATA;
									end
	
									// reset stuff condition detect counters
									num_of_consec_zeros_reg <= 4'd0;
									num_of_consec_ones_reg <= 4'd0;
								end
							end
	
						end
	
	
						else if(message_dlc == 'd6)
						begin
	
							if(stuff_bit_exception_reg)
							begin
								// push stuff bit into FIFO
								o_packetizer_message_bit <= ~message_data[47];
								crc_enable <= 1'b1;
								// shift message_sid register left by 1-bit
								message_data <= message_data << 1'b1;
	
								// reset stuff_bit_exception_reg
								stuff_bit_exception_reg <= 1'b0;
								prev_bit_reg <= ~message_data[47];
								
								if(i_packetizer_en == 0)
									state_reg <= STATE_IDLE;
								else if(bit_counter_reg == 7'd47)
								begin
									bit_counter_reg <= 7'd0;
									state_reg <= STATE_CRC;
								end
								else
								begin
									// increment bit counter
									bit_counter_reg <= bit_counter_reg + 1'b1;
									state_reg <= STATE_DATA;
								end			  
							end
							else
							begin
								// check possible stuff condition
								if(prev_bit_reg == message_data[47])
								begin
									if(message_data[47] == 1'b1)
									begin
										// push next SID bit into FIFO
										o_packetizer_message_bit <= message_data[47];
										crc_enable <= 1'b1;
										// set next value of prev_bit_reg
										prev_bit_reg <= message_data[47];
	
										if(num_of_consec_ones_reg == 4'd3 && message_data[47] == 1'b1)
										begin
											// stuff condition occurs
											stuff_bit_exception_reg <= 1'b1;
	
											// reset num_of_consec_ones_reg
											num_of_consec_ones_reg <= 4'd0;
										end
										else
										begin
											// increment num_of_consec_ones_reg
											num_of_consec_ones_reg <= num_of_consec_ones_reg + 1'b1;
	
											// shift message_sid register left by 1-bit
											message_data <= message_data << 1'b1;
	
											// check if the current bit sent is the last bit of SID field
											if(i_packetizer_en == 0)
												state_reg <= STATE_IDLE;
											else if(bit_counter_reg == 7'd47)
											begin
												bit_counter_reg <= 7'd0;
												state_reg <= STATE_CRC;
											end
											else
											begin
												// increment bit counter
												bit_counter_reg <= bit_counter_reg + 1'b1;
												state_reg <= STATE_DATA;
											end
										end
									end
									else
									begin
										o_packetizer_message_bit <= message_data[47];
										crc_enable <= 1'b1;
										// set next value of prev_bit_reg
										prev_bit_reg <= message_data[47];
	
										if(num_of_consec_zeros_reg == 4'd3 && message_data[47] == 1'b0)
										begin
											// stuff condition occurs
											stuff_bit_exception_reg <= 1'b1;
	
											// reset num_of_consec_zeros_reg
											num_of_consec_zeros_reg <= 4'd0;
										end
										else
										begin
											// increment num_of_consec_zeros_reg
											num_of_consec_zeros_reg <= num_of_consec_zeros_reg + 1'b1;
	
											// shift message_sid register left by 1-bit
											message_data <= message_data << 1'b1;
	
											// check if the current bit sent is the last bit of SID field
											if(i_packetizer_en == 0)
												state_reg <= STATE_IDLE;
											else if(bit_counter_reg == 7'd47)
											begin
												bit_counter_reg <= 7'd0;
												state_reg <= STATE_CRC;
											end
											else
											begin
												// increment bit counter
												bit_counter_reg <= bit_counter_reg + 1'b1;
												state_reg <= STATE_DATA;
											end
										end
									end
								end
								else
								begin
									// push next SID bit into FIFO
									o_packetizer_message_bit <= message_data[47];
									crc_enable <= 1'b1;
									// shift message_sid register left by 1-bit
									message_data <= message_data << 1'b1;
	
									// set next value of prev_bit_reg
									prev_bit_reg <= message_data[47];
	
									// check if the current bit sent is the last bit of SID field
									if(i_packetizer_en == 0)
										state_reg <= STATE_IDLE;
									else if(bit_counter_reg == 7'd47)
									begin
										bit_counter_reg <= 7'd0;
										state_reg <= STATE_CRC;
									end
									else
									begin
										bit_counter_reg <= bit_counter_reg + 1'b1;
										state_reg <= STATE_DATA;
									end
	
									// reset stuff condition detect counters
									num_of_consec_zeros_reg <= 4'd0;
									num_of_consec_ones_reg <= 4'd0;
								end
							end
	
						end
	
	
						else if(message_dlc == 'd7)
						begin
	
							if(stuff_bit_exception_reg)
							begin
								// push stuff bit into FIFO
								o_packetizer_message_bit <= ~message_data[55];
								crc_enable <= 1'b1;
								// shift message_sid register left by 1-bit
								message_data <= message_data << 1'b1;
	
								// reset stuff_bit_exception_reg
								stuff_bit_exception_reg <= 1'b0;
								prev_bit_reg <= ~message_data[55];
	
								if(i_packetizer_en == 0)
									state_reg <= STATE_IDLE;
								else if(bit_counter_reg == 7'd55)
								begin
									bit_counter_reg <= 7'd0;
									state_reg <= STATE_CRC;
								end
								else
								begin
									// increment bit counter
									bit_counter_reg <= bit_counter_reg + 1'b1;
									state_reg <= STATE_DATA;
								end			  
							end
							else
							begin
								// check possible stuff condition
								if(prev_bit_reg == message_data[55])
								begin
									if(message_data[55] == 1'b1)
									begin
										// push next SID bit into FIFO
										o_packetizer_message_bit <= message_data[55];
										crc_enable <= 1'b1;
										// set next value of prev_bit_reg
										prev_bit_reg <= message_data[55];
	
										if(num_of_consec_ones_reg == 4'd3 && message_data[55] == 1'b1)
										begin
											// stuff condition occurs
											stuff_bit_exception_reg <= 1'b1;
	
											// reset num_of_consec_ones_reg
											num_of_consec_ones_reg <= 4'd0;
										end
										else
										begin
											// increment num_of_consec_ones_reg
											num_of_consec_ones_reg <= num_of_consec_ones_reg + 1'b1;
	
											// shift message_sid register left by 1-bit
											message_data <= message_data << 1'b1;
	
											// check if the current bit sent is the last bit of SID field
											if(i_packetizer_en == 0)
												state_reg <= STATE_IDLE;
											else if(bit_counter_reg == 7'd55)
											begin
												bit_counter_reg <= 7'd0;
												state_reg <= STATE_CRC;
											end
											else
											begin
												// increment bit counter
												bit_counter_reg <= bit_counter_reg + 1'b1;
												state_reg <= STATE_DATA;
											end
										end
									end
									else
									begin
										o_packetizer_message_bit <= message_data[55];
										crc_enable <= 1'b1;
										// set next value of prev_bit_reg
										prev_bit_reg <= message_data[55];
	
										if(num_of_consec_zeros_reg == 4'd3 && message_data[55] == 1'b0)
										begin
											// stuff condition occurs
											stuff_bit_exception_reg <= 1'b1;
	
											// reset num_of_consec_zeros_reg
											num_of_consec_zeros_reg <= 4'd0;
										end
										else
										begin
											// increment num_of_consec_zeros_reg
											num_of_consec_zeros_reg <= num_of_consec_zeros_reg + 1'b1;
	
											// shift message_sid register left by 1-bit
											message_data <= message_data << 1'b1;
	
											// check if the current bit sent is the last bit of SID field
											if(i_packetizer_en == 0)
												state_reg <= STATE_IDLE;
											else if(bit_counter_reg == 7'd55)
											begin
												bit_counter_reg <= 7'd0;
												state_reg <= STATE_CRC;
											end
											else
											begin
												// increment bit counter
												bit_counter_reg <= bit_counter_reg + 1'b1;
												state_reg <= STATE_DATA;
											end
										end
									end
								end
								else
								begin
									// push next SID bit into FIFO
									o_packetizer_message_bit <= message_data[55];
									crc_enable <= 1'b1;
									// shift message_sid register left by 1-bit
									message_data <= message_data << 1'b1;
	
									// set next value of prev_bit_reg
									prev_bit_reg <= message_data[55];
	
									// check if the current bit sent is the last bit of SID field
									if(i_packetizer_en == 0)
										state_reg <= STATE_IDLE;
									else if(bit_counter_reg == 7'd55)
									begin
										bit_counter_reg <= 7'd0;
										state_reg <= STATE_CRC;
									end
									else
									begin
										bit_counter_reg <= bit_counter_reg + 1'b1;
										state_reg <= STATE_DATA;
									end
	
									// reset stuff condition detect counters
									num_of_consec_zeros_reg <= 4'd0;
									num_of_consec_ones_reg <= 4'd0;
								end
							end
	
						end
	
	
						else
						begin
	
							if(stuff_bit_exception_reg)
							begin
								o_packetizer_message_bit <= ~message_data[63];
								crc_enable <= 1'b1;
								// shift message_sid register left by 1-bit
								message_data <= message_data << 1'b1;
	
								// reset stuff_bit_exception_reg
								stuff_bit_exception_reg <= 1'b0;
								prev_bit_reg <= ~message_data[63];
								
								if(i_packetizer_en == 0)
										state_reg <= STATE_IDLE;
								else if(bit_counter_reg == 7'd63)
								begin
									bit_counter_reg <= 7'd0;
									state_reg <= STATE_CRC;
								end
								else
								begin
									// increment bit counter
									bit_counter_reg <= bit_counter_reg + 1'b1;
									state_reg <= STATE_DATA;
								end			  
							end
							else
							begin
								// check possible stuff condition
								if(prev_bit_reg == message_data[63])
								begin
									if(message_data[63] == 1'b1)
									begin
										o_packetizer_message_bit <= message_data[63];
										crc_enable <= 1'b1;
										// set next value of prev_bit_reg
										prev_bit_reg <= message_data[63];
	
										if(num_of_consec_ones_reg == 4'd3 && message_data[63] == 1'b1)
										begin
											// stuff condition occurs
											stuff_bit_exception_reg <= 1'b1;
	
											// reset num_of_consec_ones_reg
											num_of_consec_ones_reg <= 4'd0;
										end
										else
										begin
											// increment num_of_consec_ones_reg
											num_of_consec_ones_reg <= num_of_consec_ones_reg + 1'b1;
	
											// shift message_sid register left by 1-bit
											message_data <= message_data << 1'b1;
	
											// check if the current bit sent is the last bit of SID field
											if(i_packetizer_en == 0)
													state_reg <= STATE_IDLE;
											else if(bit_counter_reg == 7'd63)
											begin
												bit_counter_reg <= 7'd0;
												state_reg <= STATE_CRC;
											end
											else
											begin
												// increment bit counter
												bit_counter_reg <= bit_counter_reg + 1'b1;
												state_reg <= STATE_DATA;
											end
										end
									end
									else
									begin
										o_packetizer_message_bit <= message_data[63];
										crc_enable <= 1'b1;
										// set next value of prev_bit_reg
										prev_bit_reg <= message_data[63];
	
										if(num_of_consec_zeros_reg == 4'd3 && message_data[63] == 1'b0)
										begin
											// stuff condition occurs
											stuff_bit_exception_reg <= 1'b1;
	
											// reset num_of_consec_zeros_reg
											num_of_consec_zeros_reg <= 4'd0;
										end
										else
										begin
											// increment num_of_consec_zeros_reg
											num_of_consec_zeros_reg <= num_of_consec_zeros_reg + 1'b1;
	
											// shift message_sid register left by 1-bit
											message_data <= message_data << 1'b1;
	
											// check if the current bit sent is the last bit of SID field
											if(i_packetizer_en == 0)
													state_reg <= STATE_IDLE;
											else if(bit_counter_reg == 7'd63)
											begin
												bit_counter_reg <= 7'd0;
												state_reg <= STATE_CRC;
											end
											else
											begin
												// increment bit counter
												bit_counter_reg <= bit_counter_reg + 1'b1;
												state_reg <= STATE_DATA;
											end
										end
									end
								end
								else
								begin
									o_packetizer_message_bit <= message_data[63];
									crc_enable <= 1'b1;
									// shift message_sid register left by 1-bit
									message_data <= message_data << 1'b1;
	
									// set next value of prev_bit_reg
									prev_bit_reg <= message_data[63];
	
									// check if the current bit sent is the last bit of SID field
									if(i_packetizer_en == 0)
											state_reg <= STATE_IDLE;
									else if(bit_counter_reg == 7'd63)
									begin
										bit_counter_reg <= 7'd0;
										state_reg <= STATE_CRC;
									end
									else
									begin
										bit_counter_reg <= bit_counter_reg + 1'b1;
										state_reg <= STATE_DATA;
									end
	
									// reset stuff condition detect counters
									num_of_consec_zeros_reg <= 4'd0;
									num_of_consec_ones_reg <= 4'd0;
								end
							end
						end
					end
	
					STATE_CRC :
					begin
					crc_enable <= 1'b0;
						
						if(stuff_bit_exception_reg)
						begin
							o_packetizer_message_bit <= ~crc_reg[14];
							prev_bit_reg <= ~crc_reg[14];			
				
							// shift crc_reg register left by 1-bit
							crc_reg <= crc_reg << 1'b1;
	
							// reset stuff_bit_exception_reg
							stuff_bit_exception_reg <= 1'b0;
							if(i_packetizer_en == 0)
								state_reg <= STATE_IDLE;
							else if(bit_counter_reg == 7'd14)
							begin
								//o_packetizer_message_bit <= 1'b1;
								bit_counter_reg <= 7'd0;
								state_reg <= STATE_ACK;
							end
							else
							begin
							// increment bit counter
								bit_counter_reg <= bit_counter_reg + 1'b1;
								state_reg <= STATE_CRC;
							end
						end
						else
						begin
						if(bit_counter_reg == 7'd14)
						begin
							o_packetizer_message_bit <= 1'b1;	
						end
							// check possible stuff condition
							if(prev_bit_reg == crc_reg[14])
							begin
								if(crc_reg[14] == 1'b1)
								begin
									o_packetizer_message_bit <= crc_reg[14];
									// set next value of prev_bit_reg
									prev_bit_reg <= crc_reg[14];
						
									if(num_of_consec_ones_reg == 4'd3 && crc_reg[14] == 1'b1)
									begin
										// stuff condition occurs
										stuff_bit_exception_reg <= 1'b1;
										//message_sid <= message_sid << 1'b1;
										// reset num_of_consec_ones_reg
										num_of_consec_ones_reg <= 4'd0;
									end
									else
									begin
										// increment num_of_consec_ones_reg
										num_of_consec_ones_reg <= num_of_consec_ones_reg + 1'b1;
	
										// shift message_sid register left by 1-bit
										crc_reg <= crc_reg << 1'b1;
	
										// check if the current bit sent is the last bit of SID field
										if(i_packetizer_en == 0)
											state_reg <= STATE_IDLE;
										else if(bit_counter_reg == 7'd14)
										begin
											bit_counter_reg <= 7'd0;
											state_reg <= STATE_ACK;
										end
										else
										begin
											// increment bit counter
											bit_counter_reg <= bit_counter_reg + 1'b1;
											state_reg <= STATE_CRC;
										end
									end
								end
								else
								begin
									o_packetizer_message_bit <= crc_reg[14];
									// set next value of prev_bit_reg
									prev_bit_reg <= crc_reg[14];
	
									if(num_of_consec_zeros_reg == 4'd3 && crc_reg[14] == 1'b0)
									begin
										// stuff condition occurs
										stuff_bit_exception_reg <= 1'b1;
	
										// reset num_of_consec_zeros_reg
										num_of_consec_zeros_reg <= 4'd0;
									end
									else
									begin
										// increment num_of_consec_zeros_reg
										num_of_consec_zeros_reg <= num_of_consec_zeros_reg + 1'b1;
	
										// shift message_sid register left by 1-bit
										crc_reg <= crc_reg << 1'b1;
	
										// check if the current bit sent is the last bit of SID field
										if(i_packetizer_en == 0)
											state_reg <= STATE_IDLE;
										else if(bit_counter_reg == 7'd14)
										begin
											bit_counter_reg <= 7'd0;
											state_reg <= STATE_ACK;
										end
										else
										begin
											// increment bit counter
											bit_counter_reg <= bit_counter_reg + 1'b1;
											state_reg <= STATE_CRC;
										end
									end
								end
							end
							else
							begin
								o_packetizer_message_bit <= crc_reg[14];
								// shift message_sid register left by 1-bit
								crc_reg <= crc_reg << 1'b1;
	
								// set next value of prev_bit_reg
								prev_bit_reg <= crc_reg[14];
	
								// check if the current bit sent is the last bit of SID field
								if(i_packetizer_en == 0)
										state_reg <= STATE_IDLE;
								else if(bit_counter_reg == 7'd14)
								begin
									bit_counter_reg <= 7'd0;
									state_reg <= STATE_ACK;
								end
								else begin
									bit_counter_reg <= bit_counter_reg + 1'b1;
									state_reg <= STATE_CRC;
								end
	
								// reset stuff condition detect counters
								num_of_consec_zeros_reg <= 4'd0;
								num_of_consec_ones_reg <= 4'd0;
							end
						end
					end
					STATE_ACK :
					begin
						if(bit_counter_reg == 7'd0)
						begin
							o_packetizer_message_bit <= 1'b1;
							
						end
						else
						begin
							o_packetizer_message_bit <= 1'b1;
						end
						// check if the current bit sent is the last bit of SID field
						if(i_packetizer_en == 0)
								state_reg <= STATE_IDLE;
						else if(bit_counter_reg == 7'd1)
						begin
							bit_counter_reg <= 7'd0;
							state_reg <= STATE_EOF;
							o_ack_slot <= 1'b1;
						end
						else
						begin
							state_reg <= STATE_ACK;
							bit_counter_reg <= bit_counter_reg + 1'b1;
						end
					end
	
					STATE_EOF :
					begin
					o_ack_slot <= 1'b0;
						o_packetizer_message_bit <= 1'b1;
							
						if(i_packetizer_en == 0)
							state_reg <= STATE_IDLE;
						else if(bit_counter_reg == 7'd6)
						begin
							bit_counter_reg <= 7'd0;
							state_reg <= STATE_IDLE;
							packetizer_rdy_reg <= 1'b1;
						end
						else
						begin
							state_reg <= STATE_EOF;
							bit_counter_reg <= bit_counter_reg + 1'b1;
						end
					end
			
				endcase
			end
		end
  end

  assign o_packetizer_rdy = packetizer_rdy_reg;
endmodule
