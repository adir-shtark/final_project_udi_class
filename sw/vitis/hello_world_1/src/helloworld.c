/******************************************************************************
* Copyright (C) 2023 Advanced Micro Devices, Inc. All Rights Reserved.
* SPDX-License-Identifier: MIT
******************************************************************************/
/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include "xparameters.h"
#include "xil_io.h"

// Direct register offsets for AXI GPIO
#define GPIO_DATA_OFFSET  0x0000
#define GPIO_TRI_OFFSET   0x0004

// Custom lightweight delay loop to avoid bringing in sleep.h timer libraries
static void delay_cycles(volatile unsigned int cycles) {
    while (cycles--) {
        __asm__("nop");
    }
}

int main(void) {
    // Configure Channel 1 as output: write 0x0000 to Tri-state register
    Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR + GPIO_TRI_OFFSET, 0x00000000);

    while (1) {
        // Output step = 1
        Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR + GPIO_DATA_OFFSET, 1);
        delay_cycles(50);

        // Output step = 4
        Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR + GPIO_DATA_OFFSET, 0xFF);
        delay_cycles(50);
    }

    return 0;
}