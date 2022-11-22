# Caravel User Project

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![UPRJ_CI](https://github.com/efabless/caravel_project_example/actions/workflows/user_project_ci.yml/badge.svg)](https://github.com/efabless/caravel_project_example/actions/workflows/user_project_ci.yml) [![Caravel Build](https://github.com/efabless/caravel_project_example/actions/workflows/caravel_build.yml/badge.svg)](https://github.com/efabless/caravel_project_example/actions/workflows/caravel_build.yml)

# YONGA-CAN Controller

YONGA-CAN Controller is a partial implementation of CAN 2.0B standard. Currently supported functionalities are:

- Transmit DATA FRAME in standard format

## Register Map

| Offset | Name | Description | Type |
| --- | --- | --- | --- |
| `0x0` | BAUD_RATE_CFG | Baud Rate Configuration Register | REG |
| `0x4` | MSG_ID | Message ID Register | REG |
| `0x8` | MSG_CFG | Message Type and Length Register | REG |
| `0xC` | DATA_REG1 | Data Register 1 | REG |
| `0x10` | DATA_REG2 | Data Register 2 | REG |
| `0x14` | SYS_CFG | IP Config Register | REG |
| `0x18` | SYS_CTRL_STS | IP Control and Status Register | REG |

## Registers

| Offset | Name | Description | Type | Access | Attributes | Reset | 
| ---    | --- | --- | --- | --- | --- | --- |
| `0x0` | BAUD_RATE_CFG |Baud Rate Configuration Register | REG | R/W |  | `0x0` |
|        |  [8:0] TSEG2 | Time Quanta Count for Phase Buffer Segment 2 |  |  |  | `0x0` |
|        |  [17:9] TSEG1 | Time Quanta Count for Propagation Time Segment and Phase Buffer Segment 1 |  |  |  | `0x0` |
|        |  [26:18] BRP | Baud Rate Prescaler |  |  |  | `0x0` |
|        |  [31:27] SJW | Syncronization Jump Width |  |  |  | `0x0` |
| `0x4` | MSG_ID |Message ID Register | REG | R/W |  | `0x0` |
|        |  [17:0] EID | Message EID |  |  |  | `0x0` |
|        |  [18] IDE | Message ID Extension Flag |  |  |  | `0x0` |
|        |  [29:19] SID | Message SID |  |  |  | `0x0` |
| `0x8` | MSG_CFG |Message Type and Length Register | REG | R/W |  | `0x0` |
|        |  [3:0] DLC | Data Length Code |  |  |  | `0x0` |
|        |  [4] RTR | Remote Transmit Request Flag |  |  |  | `0x0` |
| `0xC` | DATA_REG1 |Data Register 1 | REG | R/W |  | `0x0` |
|        |  [7:0] DATA_BYTE_0 | Data Byte 0 |  |  |  | `0x0` |
|        |  [15:8] DATA_BYTE_1 | Data Byte 1 |  |  |  | `0x0` |
|        |  [23:16] DATA_BYTE_2 | Data Byte 2 |  |  |  | `0x0` |
|        |  [31:24] DATA_BYTE_3 | Data Byte 3 |  |  |  | `0x0` |
| `0x10` | DATA_REG2 |Data Register 2 | REG | R/W |  | `0x0` |
|        |  [7:0] DATA_BYTE_4 | Data Byte 4 |  |  |  | `0x0` |
|        |  [15:8] DATA_BYTE_5 | Data Byte 5 |  |  |  | `0x0` |
|        |  [23:16] DATA_BYTE_6 | Data Byte 6 |  |  |  | `0x0` |
|        |  [31:24] DATA_BYTE_7 | Data Byte 7 |  |  |  | `0x0` |
| `0x14` | SYS_CFG |IP Config Register | REG | R/W |  | `0x0` |
|        |  [0] MODE | IP Mode Select |  |  |  | `0x0` |
|        |  | BUS_MODE = 0, LOOPBACK_MODE = 1 |  |  |  |  |
|        |  [1] ENABLE | IP Enable Flag |  |  |  | `0x0` |
| `0x18` | SYS_CTRL_STS |IP Control and Status Register | REG | R/W |  | `0x0` |
|        |  [0] SEND | Send Message |  |  | self-clearing | `0x0` |
|        |  [3:1] STATUS_CODE | Operation Status Code |  |  |  | `0x0` |
|        |  | TX_SUCCESSFUL = 1, ARBITRATION_LOST = 2, TX_FAILED = 4 |  |  |  |  |

_Generated on 2022-09-06 at 12:53 (UTC) by airhdl version 2022.08.2-618538036_

Running Simulation
========

### TX Test

* This test is meant to verify that we can send a DATA FRAME in standard format.

To run RTL simulation, 

```bash
cd $UPRJ_ROOT
make verify-can_test_1-rtl
```

Hardening the User Project Macro using OpenLANE
========

```bash
cd $UPRJ_ROOT

# Run openlane to harden user_proj_example
make user_proj_example

# Run openlane to harden user_project_wrapper
make user_project_wrapper
```

List of Contributors
=================================

*In alphabetical order:*

- Hanim Ay
- Okan Yagiz
