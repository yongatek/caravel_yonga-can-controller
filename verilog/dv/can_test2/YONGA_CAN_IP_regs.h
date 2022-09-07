// -----------------------------------------------------------------------------
// 'YONGA_CAN_IP' Register Definitions
// Revision: 68
// -----------------------------------------------------------------------------
// Generated on 2022-09-07 at 10:18 (UTC) by airhdl version 2022.08.2-618538036
// -----------------------------------------------------------------------------
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
// -----------------------------------------------------------------------------

#ifndef YONGA_CAN_IP_REGS_H
#define YONGA_CAN_IP_REGS_H

/* Revision number of the 'YONGA_CAN_IP' register map */
#define YONGA_CAN_IP_REVISION 68

/* Default base address of the 'YONGA_CAN_IP' register map */
#define YONGA_CAN_IP_DEFAULT_BASEADDR 0xA0000000

/* Size of the 'YONGA_CAN_IP' register map, in bytes */
#define YONGA_CAN_IP_RANGE_BYTES 28

/* Register 'BAUD_RATE_CFG' */
#define BAUD_RATE_CFG_OFFSET 0x00000000 /* address offset of the 'BAUD_RATE_CFG' register */

/* Field  'BAUD_RATE_CFG.TSEG2' */
#define BAUD_RATE_CFG_TSEG2_BIT_OFFSET 0 /* bit offset of the 'TSEG2' field */
#define BAUD_RATE_CFG_TSEG2_BIT_WIDTH 9 /* bit width of the 'TSEG2' field */
#define BAUD_RATE_CFG_TSEG2_BIT_MASK 0x000001FF /* bit mask of the 'TSEG2' field */
#define BAUD_RATE_CFG_TSEG2_RESET 0x0 /* reset value of the 'TSEG2' field */

/* Field  'BAUD_RATE_CFG.TSEG1' */
#define BAUD_RATE_CFG_TSEG1_BIT_OFFSET 9 /* bit offset of the 'TSEG1' field */
#define BAUD_RATE_CFG_TSEG1_BIT_WIDTH 9 /* bit width of the 'TSEG1' field */
#define BAUD_RATE_CFG_TSEG1_BIT_MASK 0x0003FE00 /* bit mask of the 'TSEG1' field */
#define BAUD_RATE_CFG_TSEG1_RESET 0x0 /* reset value of the 'TSEG1' field */

/* Field  'BAUD_RATE_CFG.BRP' */
#define BAUD_RATE_CFG_BRP_BIT_OFFSET 18 /* bit offset of the 'BRP' field */
#define BAUD_RATE_CFG_BRP_BIT_WIDTH 9 /* bit width of the 'BRP' field */
#define BAUD_RATE_CFG_BRP_BIT_MASK 0x07FC0000 /* bit mask of the 'BRP' field */
#define BAUD_RATE_CFG_BRP_RESET 0x0 /* reset value of the 'BRP' field */

/* Field  'BAUD_RATE_CFG.SJW' */
#define BAUD_RATE_CFG_SJW_BIT_OFFSET 27 /* bit offset of the 'SJW' field */
#define BAUD_RATE_CFG_SJW_BIT_WIDTH 5 /* bit width of the 'SJW' field */
#define BAUD_RATE_CFG_SJW_BIT_MASK 0xF8000000 /* bit mask of the 'SJW' field */
#define BAUD_RATE_CFG_SJW_RESET 0x0 /* reset value of the 'SJW' field */

/* Register 'MSG_ID' */
#define MSG_ID_OFFSET 0x00000004 /* address offset of the 'MSG_ID' register */

/* Field  'MSG_ID.EID' */
#define MSG_ID_EID_BIT_OFFSET 0 /* bit offset of the 'EID' field */
#define MSG_ID_EID_BIT_WIDTH 18 /* bit width of the 'EID' field */
#define MSG_ID_EID_BIT_MASK 0x0003FFFF /* bit mask of the 'EID' field */
#define MSG_ID_EID_RESET 0x0 /* reset value of the 'EID' field */

/* Field  'MSG_ID.IDE' */
#define MSG_ID_IDE_BIT_OFFSET 18 /* bit offset of the 'IDE' field */
#define MSG_ID_IDE_BIT_WIDTH 1 /* bit width of the 'IDE' field */
#define MSG_ID_IDE_BIT_MASK 0x00040000 /* bit mask of the 'IDE' field */
#define MSG_ID_IDE_RESET 0x0 /* reset value of the 'IDE' field */

/* Field  'MSG_ID.SID' */
#define MSG_ID_SID_BIT_OFFSET 19 /* bit offset of the 'SID' field */
#define MSG_ID_SID_BIT_WIDTH 11 /* bit width of the 'SID' field */
#define MSG_ID_SID_BIT_MASK 0x3FF80000 /* bit mask of the 'SID' field */
#define MSG_ID_SID_RESET 0x0 /* reset value of the 'SID' field */

/* Register 'MSG_CFG' */
#define MSG_CFG_OFFSET 0x00000008 /* address offset of the 'MSG_CFG' register */

/* Field  'MSG_CFG.DLC' */
#define MSG_CFG_DLC_BIT_OFFSET 0 /* bit offset of the 'DLC' field */
#define MSG_CFG_DLC_BIT_WIDTH 4 /* bit width of the 'DLC' field */
#define MSG_CFG_DLC_BIT_MASK 0x0000000F /* bit mask of the 'DLC' field */
#define MSG_CFG_DLC_RESET 0x0 /* reset value of the 'DLC' field */

/* Field  'MSG_CFG.RTR' */
#define MSG_CFG_RTR_BIT_OFFSET 4 /* bit offset of the 'RTR' field */
#define MSG_CFG_RTR_BIT_WIDTH 1 /* bit width of the 'RTR' field */
#define MSG_CFG_RTR_BIT_MASK 0x00000010 /* bit mask of the 'RTR' field */
#define MSG_CFG_RTR_RESET 0x0 /* reset value of the 'RTR' field */

/* Register 'DATA_REG1' */
#define DATA_REG1_OFFSET 0x0000000C /* address offset of the 'DATA_REG1' register */

/* Field  'DATA_REG1.DATA_BYTE_0' */
#define DATA_REG1_DATA_BYTE_0_BIT_OFFSET 0 /* bit offset of the 'DATA_BYTE_0' field */
#define DATA_REG1_DATA_BYTE_0_BIT_WIDTH 8 /* bit width of the 'DATA_BYTE_0' field */
#define DATA_REG1_DATA_BYTE_0_BIT_MASK 0x000000FF /* bit mask of the 'DATA_BYTE_0' field */
#define DATA_REG1_DATA_BYTE_0_RESET 0x0 /* reset value of the 'DATA_BYTE_0' field */

/* Field  'DATA_REG1.DATA_BYTE_1' */
#define DATA_REG1_DATA_BYTE_1_BIT_OFFSET 8 /* bit offset of the 'DATA_BYTE_1' field */
#define DATA_REG1_DATA_BYTE_1_BIT_WIDTH 8 /* bit width of the 'DATA_BYTE_1' field */
#define DATA_REG1_DATA_BYTE_1_BIT_MASK 0x0000FF00 /* bit mask of the 'DATA_BYTE_1' field */
#define DATA_REG1_DATA_BYTE_1_RESET 0x0 /* reset value of the 'DATA_BYTE_1' field */

/* Field  'DATA_REG1.DATA_BYTE_2' */
#define DATA_REG1_DATA_BYTE_2_BIT_OFFSET 16 /* bit offset of the 'DATA_BYTE_2' field */
#define DATA_REG1_DATA_BYTE_2_BIT_WIDTH 8 /* bit width of the 'DATA_BYTE_2' field */
#define DATA_REG1_DATA_BYTE_2_BIT_MASK 0x00FF0000 /* bit mask of the 'DATA_BYTE_2' field */
#define DATA_REG1_DATA_BYTE_2_RESET 0x0 /* reset value of the 'DATA_BYTE_2' field */

/* Field  'DATA_REG1.DATA_BYTE_3' */
#define DATA_REG1_DATA_BYTE_3_BIT_OFFSET 24 /* bit offset of the 'DATA_BYTE_3' field */
#define DATA_REG1_DATA_BYTE_3_BIT_WIDTH 8 /* bit width of the 'DATA_BYTE_3' field */
#define DATA_REG1_DATA_BYTE_3_BIT_MASK 0xFF000000 /* bit mask of the 'DATA_BYTE_3' field */
#define DATA_REG1_DATA_BYTE_3_RESET 0x0 /* reset value of the 'DATA_BYTE_3' field */

/* Register 'DATA_REG2' */
#define DATA_REG2_OFFSET 0x00000010 /* address offset of the 'DATA_REG2' register */

/* Field  'DATA_REG2.DATA_BYTE_4' */
#define DATA_REG2_DATA_BYTE_4_BIT_OFFSET 0 /* bit offset of the 'DATA_BYTE_4' field */
#define DATA_REG2_DATA_BYTE_4_BIT_WIDTH 8 /* bit width of the 'DATA_BYTE_4' field */
#define DATA_REG2_DATA_BYTE_4_BIT_MASK 0x000000FF /* bit mask of the 'DATA_BYTE_4' field */
#define DATA_REG2_DATA_BYTE_4_RESET 0x0 /* reset value of the 'DATA_BYTE_4' field */

/* Field  'DATA_REG2.DATA_BYTE_5' */
#define DATA_REG2_DATA_BYTE_5_BIT_OFFSET 8 /* bit offset of the 'DATA_BYTE_5' field */
#define DATA_REG2_DATA_BYTE_5_BIT_WIDTH 8 /* bit width of the 'DATA_BYTE_5' field */
#define DATA_REG2_DATA_BYTE_5_BIT_MASK 0x0000FF00 /* bit mask of the 'DATA_BYTE_5' field */
#define DATA_REG2_DATA_BYTE_5_RESET 0x0 /* reset value of the 'DATA_BYTE_5' field */

/* Field  'DATA_REG2.DATA_BYTE_6' */
#define DATA_REG2_DATA_BYTE_6_BIT_OFFSET 16 /* bit offset of the 'DATA_BYTE_6' field */
#define DATA_REG2_DATA_BYTE_6_BIT_WIDTH 8 /* bit width of the 'DATA_BYTE_6' field */
#define DATA_REG2_DATA_BYTE_6_BIT_MASK 0x00FF0000 /* bit mask of the 'DATA_BYTE_6' field */
#define DATA_REG2_DATA_BYTE_6_RESET 0x0 /* reset value of the 'DATA_BYTE_6' field */

/* Field  'DATA_REG2.DATA_BYTE_7' */
#define DATA_REG2_DATA_BYTE_7_BIT_OFFSET 24 /* bit offset of the 'DATA_BYTE_7' field */
#define DATA_REG2_DATA_BYTE_7_BIT_WIDTH 8 /* bit width of the 'DATA_BYTE_7' field */
#define DATA_REG2_DATA_BYTE_7_BIT_MASK 0xFF000000 /* bit mask of the 'DATA_BYTE_7' field */
#define DATA_REG2_DATA_BYTE_7_RESET 0x0 /* reset value of the 'DATA_BYTE_7' field */

/* Register 'SYS_CFG' */
#define SYS_CFG_OFFSET 0x00000014 /* address offset of the 'SYS_CFG' register */

/* Field  'SYS_CFG.MODE' */
#define SYS_CFG_MODE_BIT_OFFSET 0 /* bit offset of the 'MODE' field */
#define SYS_CFG_MODE_BIT_WIDTH 1 /* bit width of the 'MODE' field */
#define SYS_CFG_MODE_BIT_MASK 0x00000001 /* bit mask of the 'MODE' field */
#define SYS_CFG_MODE_RESET 0x0 /* reset value of the 'MODE' field */

/* Enumerated values for field 'SYS_CFG.MODE' */
#define SYS_CFG_MODE_BUS_MODE 0
#define SYS_CFG_MODE_LOOPBACK_MODE 1

/* Field  'SYS_CFG.ENABLE' */
#define SYS_CFG_ENABLE_BIT_OFFSET 1 /* bit offset of the 'ENABLE' field */
#define SYS_CFG_ENABLE_BIT_WIDTH 1 /* bit width of the 'ENABLE' field */
#define SYS_CFG_ENABLE_BIT_MASK 0x00000002 /* bit mask of the 'ENABLE' field */
#define SYS_CFG_ENABLE_RESET 0x0 /* reset value of the 'ENABLE' field */

/* Register 'SYS_CTRL_STS' */
#define SYS_CTRL_STS_OFFSET 0x00000018 /* address offset of the 'SYS_CTRL_STS' register */

/* Field  'SYS_CTRL_STS.SEND' */
#define SYS_CTRL_STS_SEND_BIT_OFFSET 0 /* bit offset of the 'SEND' field */
#define SYS_CTRL_STS_SEND_BIT_WIDTH 1 /* bit width of the 'SEND' field */
#define SYS_CTRL_STS_SEND_BIT_MASK 0x00000001 /* bit mask of the 'SEND' field */
#define SYS_CTRL_STS_SEND_RESET 0x0 /* reset value of the 'SEND' field */

/* Field  'SYS_CTRL_STS.STATUS_CODE' */
#define SYS_CTRL_STS_STATUS_CODE_BIT_OFFSET 1 /* bit offset of the 'STATUS_CODE' field */
#define SYS_CTRL_STS_STATUS_CODE_BIT_WIDTH 3 /* bit width of the 'STATUS_CODE' field */
#define SYS_CTRL_STS_STATUS_CODE_BIT_MASK 0x0000000E /* bit mask of the 'STATUS_CODE' field */
#define SYS_CTRL_STS_STATUS_CODE_RESET 0x0 /* reset value of the 'STATUS_CODE' field */

/* Enumerated values for field 'SYS_CTRL_STS.STATUS_CODE' */
#define SYS_CTRL_STS_STATUS_CODE_TX_FAILED 3
#define SYS_CTRL_STS_STATUS_CODE_TX_SUCCESSFUL 1
#define SYS_CTRL_STS_STATUS_CODE_ARBITRATION_LOST 2

#endif  /* YONGA_CAN_IP_REGS_H */
