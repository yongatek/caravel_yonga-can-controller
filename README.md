# Caravel User Project

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![UPRJ_CI](https://github.com/efabless/caravel_project_example/actions/workflows/user_project_ci.yml/badge.svg)](https://github.com/efabless/caravel_project_example/actions/workflows/user_project_ci.yml) [![Caravel Build](https://github.com/efabless/caravel_project_example/actions/workflows/caravel_build.yml/badge.svg)](https://github.com/efabless/caravel_project_example/actions/workflows/caravel_build.yml)

# YONGA-CAN Controller

Overview
========

YONGA-CAN Controller is a partial implementation of CAN 2.0B standard. Currently supported functionalities are:

- Transmit DATA FRAME in standard format

Running Simulation
========

### TX Test

* This test is meant to verify that we can send a DATA FRAME in standard format.

To run RTL simulation, 

```bash
cd $UPRJ_ROOT
make verify-can_test1-rtl
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
