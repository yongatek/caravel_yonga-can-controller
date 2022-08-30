/*
 * SPDX-FileCopyrightText: 2020 Efabless Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * SPDX-License-Identifier: Apache-2.0
 */

// This include is relative to $CARAVEL_PATH (see Makefile)
#include <defs.h>
#include <stub.c>

/*
	CAN TX Transaction Test:
		- TBD
*/

#define WR_EN 0x20
#define BAUD_RATE_CFG_REG 0x0
#define MSG_ID_REG 0x4
#define MSG_CFG_REG 0x8
#define DATA_REG1_REG 0xC
#define DATA_REG2_REG 0x10
#define SYS_CFG_REG 0x14
#define SYS_CTRL_STS_REG 0x18

void device_register_write(uint32_t, uint32_t);

uint32_t device_register_read(uint32_t);

void main()
{

	/* 
	IO Control Registers
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 3-bits | 1-bit | 1-bit | 1-bit  | 1-bit  | 1-bit | 1-bit   | 1-bit   | 1-bit | 1-bit | 1-bit   |
	Output: 0000_0110_0000_1110  (0x1808) = GPIO_MODE_USER_STD_OUTPUT
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 110    | 0     | 0     | 0      | 0      | 0     | 0       | 1       | 0     | 0     | 0       |
	
	 
	Input: 0000_0001_0000_1111 (0x0402) = GPIO_MODE_USER_STD_INPUT_NOPULL
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 001    | 0     | 0     | 0      | 0      | 0     | 0       | 0       | 0     | 1     | 0       |
	*/

	/* Set up the housekeeping SPI to be connected internally so	*/
	/* that external pin changes don't affect it.			*/

    reg_spi_enable = 1;
    reg_wb_enable = 1;
	// reg_spimaster_config = 0xa002;	// Enable, prescaler = 2,
                                        // connect to housekeeping SPI

	// Connect the housekeeping SPI to the SPI master
	// so that the CSB line is not left floating.  This allows
	// all of the GPIO pins to be used for user functions.

    reg_mprj_io_31 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_30 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_29 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_28 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_27 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_26 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_25 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_24 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_23 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_22 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_21 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_20 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_19 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_18 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_17 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_16 = GPIO_MODE_MGMT_STD_OUTPUT;

     /* Apply configuration */
    reg_mprj_xfer = 1;
    while (reg_mprj_xfer == 1);

    // Configure LA probes [63:0] as outputs from the cpu
    // Configure LA probes [127:64] as inputs to the cpu
    // the output enable is active low, the input enable is active high
    reg_la0_oenb = reg_la0_iena = 0xFFFFFFFF;    // [31:0]
    reg_la1_oenb = reg_la1_iena = 0xFFFFFFFF;    // [63:32]
    reg_la2_oenb = reg_la2_iena = 0x00000000;    // [95:64]
    reg_la3_oenb = reg_la3_iena = 0x00000000;    // [127:96]

    // Flag start of the test
	reg_mprj_datal = 0xAB600000;

    // Enable device configuration
    device_register_write(SYS_CFG_REG, 0x00000002);

    // Apply configuration
    device_register_write(BAUD_RATE_CFG_REG, 0x00102008);
    device_register_write(MSG_ID_REG, 0x05580000);
    device_register_write(MSG_CFG_REG, 0x5);
    device_register_write(DATA_REG1_REG, 0xCAFFEEEE);
    device_register_write(DATA_REG2_REG, 0xAB0AB030);

    // Disable device configuration
    device_register_write(SYS_CFG_REG, 0x00000000);

    // Initiate CAN transfer
    device_register_write(SYS_CTRL_STS_REG, 0x00000001);

    // uint32_t tmp;
    // tmp = device_register_read(SYS_CTRL_STS_REG);
    // device_register_write(MSG_CFG_REG, tmp+1);

}

void device_register_write(uint32_t device_addr, uint32_t val){

    reg_la0_data = WR_EN | device_addr;
    reg_la1_data = val;

    // send access request to the peripheral
    reg_mprj_slave = 0x1;

}

uint32_t device_register_read(uint32_t device_addr){

    reg_la0_data = device_addr;

    // send access request to the peripheral
    reg_mprj_slave = 0x1;

    return reg_la2_data_in;

}
