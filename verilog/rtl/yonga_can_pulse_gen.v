`timescale 1ns / 1ps
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

// The yonga_can_pulse_gen module generates appropriate bit synchronization signals
// with respect to a particular bit rate

`define NUM_OF_QUANTUM_BITS 9

module yonga_can_pulse_gen(
    input wire i_pulse_gen_clk,
    input wire i_pulse_gen_rst,

    input wire i_pulse_gen_config_en,

    input wire [`NUM_OF_QUANTUM_BITS-1:0] i_pulse_gen_prescaler_val,
    input wire [`NUM_OF_QUANTUM_BITS-1:0] i_pulse_gen_phase_seg1_time_quanta_val,
    input wire [`NUM_OF_QUANTUM_BITS-1:0] i_pulse_gen_phase_seg2_time_quanta_val,

    output wire o_pulse_gen_synced,

    output wire o_pulse_gen_drive_pulse,
    output wire o_pulse_gen_sample_pulse
 );

    // typedef enum {STATE_RESET, STATE_SYNC_SEG, STATE_PROP_SEG, STATE_PHASE_SEG1, STATE_PHASE_SEG2} state_t;
    parameter STATE_RESET = 0, STATE_SYNC_SEG = 1, STATE_PROP_SEG = 2, STATE_PHASE_SEG1 = 3, STATE_PHASE_SEG2 = 4;

    // state register
    // reg [NUM_OF_STATE_BITS-1:0] state_reg;
    reg [3:0] state_reg;

    // timing registers
    reg [`NUM_OF_QUANTUM_BITS-1:0] nom_time_qtm_reg;
    reg [`NUM_OF_QUANTUM_BITS-1:0] qtm_counter_reg;
    reg [`NUM_OF_QUANTUM_BITS-1:0] phase_seg1_counter_reg;
    reg [`NUM_OF_QUANTUM_BITS-1:0] phase_seg2_counter_reg;

    // status registers
    reg sync_reg;
    reg drive_pulse_reg;
    reg sample_pulse_reg;

    always@(posedge i_pulse_gen_clk) begin
        if(i_pulse_gen_rst == 1'b1) begin
            nom_time_qtm_reg <= {`NUM_OF_QUANTUM_BITS{1'b0}};
            qtm_counter_reg <= {`NUM_OF_QUANTUM_BITS{1'b0}};
            phase_seg1_counter_reg <= {`NUM_OF_QUANTUM_BITS{1'b0}};
            phase_seg2_counter_reg <= {`NUM_OF_QUANTUM_BITS{1'b0}};
            sync_reg <= 1'b0;
            drive_pulse_reg <= 1'b0;
            sample_pulse_reg <= 1'b0;
            state_reg <= STATE_RESET;
        end
        else begin
            case(state_reg)
                STATE_RESET: begin
                    if(i_pulse_gen_config_en) begin
                        nom_time_qtm_reg <= i_pulse_gen_prescaler_val; // assume that MINIMUM TIME QUANTUM equals 1
                        state_reg <= STATE_SYNC_SEG;
                    end
                end
                STATE_SYNC_SEG: begin
                    qtm_counter_reg <= qtm_counter_reg + 1'b1;
                    if(qtm_counter_reg == nom_time_qtm_reg) begin
                        qtm_counter_reg <= {`NUM_OF_QUANTUM_BITS{1'b0}};
                        drive_pulse_reg <= 1'b1;
                        state_reg <= STATE_PHASE_SEG1;
                    end
                end
                // STATE_PROP_SEG: begin
                // end
                STATE_PHASE_SEG1: begin
                    drive_pulse_reg <= 1'b0;
                    qtm_counter_reg <= qtm_counter_reg + 1'b1;
                    if(qtm_counter_reg == nom_time_qtm_reg) begin
                        qtm_counter_reg <= {`NUM_OF_QUANTUM_BITS{1'b0}};
                        phase_seg1_counter_reg <= phase_seg1_counter_reg + 1'b1;
                        if(phase_seg1_counter_reg == i_pulse_gen_phase_seg1_time_quanta_val) begin
                            phase_seg1_counter_reg <= {`NUM_OF_QUANTUM_BITS{1'b0}};
                            sample_pulse_reg <= 1'b1;
                            state_reg <= STATE_PHASE_SEG2;
                        end
                    end
                end
                STATE_PHASE_SEG2: begin
                    sample_pulse_reg <= 1'b0;
                    qtm_counter_reg <= qtm_counter_reg + 1'b1;
                    if(qtm_counter_reg == nom_time_qtm_reg) begin
                        qtm_counter_reg <= {`NUM_OF_QUANTUM_BITS{1'b0}};
                        phase_seg2_counter_reg <= phase_seg2_counter_reg + 1'b1;
                        if(phase_seg2_counter_reg == i_pulse_gen_phase_seg2_time_quanta_val) begin
                            phase_seg2_counter_reg <= {`NUM_OF_QUANTUM_BITS{1'b0}};
                            sync_reg <= 1'b1;
                            state_reg <= STATE_SYNC_SEG;
                        end
                    end
                end
            endcase
        end
    end

    assign o_pulse_gen_synced = sync_reg;
    assign o_pulse_gen_drive_pulse = drive_pulse_reg;
    assign o_pulse_gen_sample_pulse = sample_pulse_reg;

endmodule
