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

// The yonga_can_top module includes the register access logic and
// top-level logic of CAN peripheral

`default_nettype none

module yonga_can_top #(
    parameter BITS = 32
)(
    input wire clk,
    input wire rst,
    output	   ready,
    input wire valid,

    output reg [BITS-1:0] rdata,
    input wire [BITS-1:0] wdata,
    input wire [3:0] wstrb,
    
    input wire device_reg_wr_en,
    input wire [4:0] device_addr,
    input wire [BITS-1:0] device_reg_wr_data,
    output reg [BITS-1:0] device_reg_rd_data,

    output wire can_tx,
    //output wire done, // Added for simulation in order to perform wait(done) operation.
    //output wire [2:0] o_status, // Assigned to o_sts_code of controller. Allows user to monitor if arbitration is lost, transmission is failed or succeed. 
    input wire can_rx,
    
    output reg [BITS-1:0] count
    //output wire ack_slot // Added for simulation
);
//    reg ready;
//    reg [BITS-1:0] device_reg_rd_data;
//    reg [BITS-1:0] count;
//    reg [BITS-1:0] rdata;

    reg [BITS-1:0] BAUD_RATE_CFG_REG;
    reg [BITS-1:0] MSG_ID_REG;
    reg [BITS-1:0] MSG_CFG_REG;
    reg [BITS-1:0] DATA_REG1_REG;
    reg [BITS-1:0] DATA_REG2_REG;
    reg [BITS-1:0] SYS_CFG_REG;
    reg [BITS-1:0] SYS_CTRL_STS_REG;
    wire [2:0] sts_code;
    wire done_controller;
    // CPU controls the peripheral via pseudo memory-mapped registers 
    always @(posedge clk) begin
        if (rst) begin
            BAUD_RATE_CFG_REG <= 32'h0;
            MSG_ID_REG <= 32'h0;
            MSG_CFG_REG <= 32'h0;
            DATA_REG1_REG <= 32'h0;
            DATA_REG2_REG <= 32'h0;
            SYS_CFG_REG <= 32'h0;
            SYS_CTRL_STS_REG <= 32'h0;

            count <= 0;
            ready <= 0;
            rdata <= 32'h0;
        end
        else begin
            ready <= 1'b0;
            SYS_CTRL_STS_REG[0] <= 1'b0; // SEND bit is self-clearing
            if (valid && !ready) begin
                ready <= 1'b1;
                rdata <= 32'h0;
                if(wdata[0] && device_addr[4:0] == 5'h0) begin
                    device_reg_rd_data <= BAUD_RATE_CFG_REG;
                    if (SYS_CFG_REG[1] && device_reg_wr_en && wstrb[0]) BAUD_RATE_CFG_REG[7:0]   <= device_reg_wr_data[7:0];
                    if (SYS_CFG_REG[1] && device_reg_wr_en && wstrb[1]) BAUD_RATE_CFG_REG[15:8]  <= device_reg_wr_data[15:8];
                    if (SYS_CFG_REG[1] && device_reg_wr_en && wstrb[2]) BAUD_RATE_CFG_REG[23:16] <= device_reg_wr_data[23:16];
                    if (SYS_CFG_REG[1] && device_reg_wr_en && wstrb[3]) BAUD_RATE_CFG_REG[31:24] <= device_reg_wr_data[31:24];
                end
                else if(wdata[0] && device_addr[4:0] == 5'h4) begin
                    device_reg_rd_data <= MSG_ID_REG;
                    if (SYS_CFG_REG[1] && device_reg_wr_en && wstrb[0]) MSG_ID_REG[7:0]   <= device_reg_wr_data[7:0];
                    if (SYS_CFG_REG[1] && device_reg_wr_en && wstrb[1]) MSG_ID_REG[15:8]  <= device_reg_wr_data[15:8];
                    if (SYS_CFG_REG[1] && device_reg_wr_en && wstrb[2]) MSG_ID_REG[23:16] <= device_reg_wr_data[23:16];
                    if (SYS_CFG_REG[1] && device_reg_wr_en && wstrb[3]) MSG_ID_REG[31:24] <= device_reg_wr_data[31:24];
                end
                else if(wdata[0] && device_addr[4:0] == 5'h8) begin
                    device_reg_rd_data <= MSG_CFG_REG;
                    if (SYS_CFG_REG[1] && device_reg_wr_en && wstrb[0]) MSG_CFG_REG[7:0]   <= device_reg_wr_data[7:0];
                    if (SYS_CFG_REG[1] && device_reg_wr_en && wstrb[1]) MSG_CFG_REG[15:8]  <= device_reg_wr_data[15:8];
                    if (SYS_CFG_REG[1] && device_reg_wr_en && wstrb[2]) MSG_CFG_REG[23:16] <= device_reg_wr_data[23:16];
                    if (SYS_CFG_REG[1] && device_reg_wr_en && wstrb[3]) MSG_CFG_REG[31:24] <= device_reg_wr_data[31:24];
                end
                else if(wdata[0] && device_addr[4:0] == 5'hC) begin
                    device_reg_rd_data <= DATA_REG1_REG;
                    if (SYS_CFG_REG[1] && device_reg_wr_en && wstrb[0]) DATA_REG1_REG[7:0]   <= device_reg_wr_data[7:0];
                    if (SYS_CFG_REG[1] && device_reg_wr_en && wstrb[1]) DATA_REG1_REG[15:8]  <= device_reg_wr_data[15:8];
                    if (SYS_CFG_REG[1] && device_reg_wr_en && wstrb[2]) DATA_REG1_REG[23:16] <= device_reg_wr_data[23:16];
                    if (SYS_CFG_REG[1] && device_reg_wr_en && wstrb[3]) DATA_REG1_REG[31:24] <= device_reg_wr_data[31:24];
                end
                else if(wdata[0] && device_addr[4:0] == 5'h10) begin
                    device_reg_rd_data <= DATA_REG2_REG;
                    if (SYS_CFG_REG[1] && device_reg_wr_en && wstrb[0]) DATA_REG2_REG[7:0]   <= device_reg_wr_data[7:0];
                    if (SYS_CFG_REG[1] && device_reg_wr_en && wstrb[1]) DATA_REG2_REG[15:8]  <= device_reg_wr_data[15:8];
                    if (SYS_CFG_REG[1] && device_reg_wr_en && wstrb[2]) DATA_REG2_REG[23:16] <= device_reg_wr_data[23:16];
                    if (SYS_CFG_REG[1] && device_reg_wr_en && wstrb[3]) DATA_REG2_REG[31:24] <= device_reg_wr_data[31:24];
                end
                else if(wdata[0] && device_addr[4:0] == 5'h14) begin
                    device_reg_rd_data <= SYS_CFG_REG;
                    if (device_reg_wr_en && wstrb[0]) SYS_CFG_REG[7:0]   <= device_reg_wr_data[7:0];
                    if (device_reg_wr_en && wstrb[1]) SYS_CFG_REG[15:8]  <= device_reg_wr_data[15:8];
                    if (device_reg_wr_en && wstrb[2]) SYS_CFG_REG[23:16] <= device_reg_wr_data[23:16];
                    if (device_reg_wr_en && wstrb[3]) SYS_CFG_REG[31:24] <= device_reg_wr_data[31:24];
                end
                else if(wdata[0] && device_addr[4:0] == 5'h18) begin
                    device_reg_rd_data <= SYS_CTRL_STS_REG;
                    if (device_reg_wr_en && wstrb[0]) SYS_CTRL_STS_REG[7:0]   <= device_reg_wr_data[7:0];
                    if (device_reg_wr_en && wstrb[1]) SYS_CTRL_STS_REG[15:8]  <= device_reg_wr_data[15:8];
                    if (device_reg_wr_en && wstrb[2]) SYS_CTRL_STS_REG[23:16] <= device_reg_wr_data[23:16];
                    if (device_reg_wr_en && wstrb[3]) SYS_CTRL_STS_REG[31:24] <= device_reg_wr_data[31:24];
                end
            end
            if (sts_code != 3'b0) begin
                SYS_CTRL_STS_REG[3:1] <= sts_code;
            end
        end
    end

    wire ack_slot_flag;

    wire pulse_gen_en, pulse_gen_synced, pulse_gen_drive_pulse, pulse_gen_sample_pulse;
    wire packetizer_en, packetizer_rdy, packetizer_message_bit;

    wire fake_rx;
    assign fake_rx = (ack_slot_flag == 1'b1) ? ~can_tx : can_tx;

    // instantiate yonga_can_pulse_gen
    yonga_can_pulse_gen inst_yonga_can_pulse_gen(
        .i_pulse_gen_clk(clk),
        .i_pulse_gen_rst(rst),

        .i_pulse_gen_config_en(pulse_gen_en),

        .i_pulse_gen_prescaler_val(BAUD_RATE_CFG_REG[26:18]),
        .i_pulse_gen_phase_seg1_time_quanta_val(BAUD_RATE_CFG_REG[17:9]),
        .i_pulse_gen_phase_seg2_time_quanta_val(BAUD_RATE_CFG_REG[8:0]),

        .o_pulse_gen_synced(pulse_gen_synced),

        .o_pulse_gen_drive_pulse(pulse_gen_drive_pulse),
        .o_pulse_gen_sample_pulse(pulse_gen_sample_pulse)
    );

    // instantiate yonga_can_controller
    yonga_can_controller inst_yonga_can_controller(
        .i_controller_clk(clk),
        .i_controller_rst(rst),

        .i_pulse_gen_synced(pulse_gen_synced),
        .i_packetizer_rdy(packetizer_rdy),
        .i_ack_slot(ack_slot_flag),
        
        .o_packetizer_en(packetizer_en),
        .o_pulse_gen_en(pulse_gen_en),
        
        .i_packetizer_message_bit(packetizer_message_bit),

        .i_message_bit(can_rx),
        .o_message_bit(can_tx),

        .i_drive_pulse(pulse_gen_drive_pulse),
        .i_sample_pulse(pulse_gen_sample_pulse),

        .i_config_enable(SYS_CFG_REG[1]),
        .i_sys_ctrl_sts_send(SYS_CTRL_STS_REG[0])
		//.done_tx(done_controller),
        //.o_sts_code(sts_code)

    );

    // instantiate yonga_can_controller
    yonga_can_packetizer inst_yonga_can_packetizer(
        .i_packetizer_clk(clk),
        .i_packetizer_rst(rst),
//        .i_done_controller(done_controller),
        .i_packetizer_en(packetizer_en),
        .i_drive_pulse(pulse_gen_drive_pulse),

        .i_packetizer_message_sid(MSG_ID_REG[29:19]),
        .i_packetizer_message_ide(MSG_ID_REG[18]),
        .i_packetizer_message_r0(1'b0),
		.i_packetizer_message_r1(1'b0),
		.i_packetizer_message_srr(1'b1),
        .i_packetizer_message_eid(MSG_ID_REG[17:0]),

        .i_packetizer_message_rtr(MSG_CFG_REG[4]),
        .i_packetizer_message_dlc(MSG_CFG_REG[3:0]),

        .i_packetizer_message_data_byte_0(DATA_REG1_REG[7:0]),
        .i_packetizer_message_data_byte_1(DATA_REG1_REG[15:8]),
        .i_packetizer_message_data_byte_2(DATA_REG1_REG[23:16]),
        .i_packetizer_message_data_byte_3(DATA_REG1_REG[31:24]),
        .i_packetizer_message_data_byte_4(DATA_REG2_REG[7:0]),
        .i_packetizer_message_data_byte_5(DATA_REG2_REG[15:8]),
        .i_packetizer_message_data_byte_6(DATA_REG2_REG[23:16]),
        .i_packetizer_message_data_byte_7(DATA_REG2_REG[31:24]),

        .o_packetizer_rdy(packetizer_rdy),
        .i_packetizer_req(/* NOT USED */),
        .o_packetizer_message_bit(packetizer_message_bit),
        .i_packetizer_message_bit(/* NOT USED */),
        .o_ack_slot(ack_slot_flag)

    );

//assign ack_slot = ack_slot_flag;
//assign done = done_controller;
//assign o_status = sts_code;
 
endmodule
`default_nettype wire