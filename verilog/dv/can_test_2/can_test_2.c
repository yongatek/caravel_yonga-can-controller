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

#define reg_mprj_slave (*(volatile uint32_t*)0x30000000)

#include "YONGA_CAN_IP_regs.h"

/*
    CAN TX Transaction Test in Loopback Mode:
        - Transmitted frame format: CAN BASE FORMAT
*/

#define BAUD_RATE_CFG_REG (YONGA_CAN_IP_DEFAULT_BASEADDR + BAUD_RATE_CFG_OFFSET)
#define MSG_ID_REG (YONGA_CAN_IP_DEFAULT_BASEADDR + MSG_ID_OFFSET)
#define MSG_CFG_REG (YONGA_CAN_IP_DEFAULT_BASEADDR + MSG_CFG_OFFSET)
#define DATA_REG1_REG (YONGA_CAN_IP_DEFAULT_BASEADDR + DATA_REG1_OFFSET)
#define DATA_REG2_REG (YONGA_CAN_IP_DEFAULT_BASEADDR + DATA_REG2_OFFSET)
#define SYS_CFG_REG (YONGA_CAN_IP_DEFAULT_BASEADDR + SYS_CFG_OFFSET)
#define SYS_CTRL_STS_REG (YONGA_CAN_IP_DEFAULT_BASEADDR + SYS_CTRL_STS_OFFSET)

#define CONFIG_EN SYS_CFG_ENABLE_BIT_MASK
#define LOOPBACK_EN SYS_CFG_MODE_BIT_MASK
#define SEND SYS_CTRL_STS_SEND_BIT_MASK
#define TX_SUCCESSFUL SYS_CTRL_STS_STATUS_CODE_TX_SUCCESSFUL

#define WR_EN 0x20

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

    /* Set up the housekeeping SPI to be connected internally so    */
    /* that external pin changes don't affect it.           */

    reg_spi_enable = 1;
    reg_wb_enable = 1;
    // reg_spimaster_config = 0xa002;   // Enable, prescaler = 2,
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

    // Set configuration data
    uint32_t TSEG2 = 0x8;
    uint32_t TSEG1 = 0x10;
    uint32_t BRP = 0x2;
    uint32_t SID = 0xAB;
    uint32_t IDE = 0x1;
    uint32_t EID = 0x413;
    uint32_t DLC = 0x5;
    uint32_t DATA_BYTE_0 = 0xEE;
    uint32_t DATA_BYTE_1 = 0xEE;
    uint32_t DATA_BYTE_2 = 0xFF;
    uint32_t DATA_BYTE_3 = 0xCA;
    uint32_t DATA_BYTE_4 = 0x30;
    uint32_t DATA_BYTE_5 = 0xB0;
    uint32_t DATA_BYTE_6 = 0x0A;
    uint32_t DATA_BYTE_7 = 0xAB;

    // Enable device configuration
    device_register_write(SYS_CFG_REG, CONFIG_EN);

    // Enable loopback mode
    device_register_write(SYS_CFG_REG, (CONFIG_EN | LOOPBACK_EN));

    // Apply configuration
    device_register_write(BAUD_RATE_CFG_REG, ( \
        (TSEG2 << BAUD_RATE_CFG_TSEG2_BIT_OFFSET) | \
        (TSEG1 << BAUD_RATE_CFG_TSEG1_BIT_OFFSET) | \
        (BRP << BAUD_RATE_CFG_BRP_BIT_OFFSET) \
        ) \
    );
    device_register_write(MSG_ID_REG, ( \
        (SID << MSG_ID_SID_BIT_OFFSET) | \
        (IDE << MSG_ID_IDE_BIT_OFFSET) | \
        (EID << MSG_ID_EID_BIT_OFFSET) \
        ) \
    );
    device_register_write(MSG_CFG_REG, (DLC << MSG_CFG_DLC_BIT_OFFSET));
    device_register_write(DATA_REG1_REG, ( \
        (DATA_BYTE_0 << DATA_REG1_DATA_BYTE_0_BIT_OFFSET) | \
        (DATA_BYTE_1 << DATA_REG1_DATA_BYTE_1_BIT_OFFSET) | \
        (DATA_BYTE_2 << DATA_REG1_DATA_BYTE_2_BIT_OFFSET) | \
        (DATA_BYTE_3 << DATA_REG1_DATA_BYTE_3_BIT_OFFSET) \
        ) \
    );
    device_register_write(DATA_REG2_REG, ( \
        (DATA_BYTE_4 << DATA_REG2_DATA_BYTE_4_BIT_OFFSET) | \
        (DATA_BYTE_5 << DATA_REG2_DATA_BYTE_5_BIT_OFFSET) | \
        (DATA_BYTE_6 << DATA_REG2_DATA_BYTE_6_BIT_OFFSET) | \
        (DATA_BYTE_7 << DATA_REG2_DATA_BYTE_7_BIT_OFFSET) \
        ) \
    );

    // Disable device configuration
    device_register_write(SYS_CFG_REG, (~CONFIG_EN | LOOPBACK_EN));

    // Initiate CAN transfer
    device_register_write(SYS_CTRL_STS_REG, SEND);

    uint32_t tmp;
    while (1) {
      if (device_register_read(SYS_CTRL_STS_REG) & TX_SUCCESSFUL) break;
    }

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
