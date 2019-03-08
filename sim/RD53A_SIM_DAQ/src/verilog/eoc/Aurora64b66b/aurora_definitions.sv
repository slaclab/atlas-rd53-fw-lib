`timescale 1ns/1ps

// Aurora BTF

`define IDLE_BLOCK 8'h78
`define CC_BLOCK 8'h78
`define NR_BLOCK 8'h78
`define CB_BLOCK 8'h78
`define NFC_BLOCK 8'haa
`define UFC_BLOCK 8'h2d
`define UK0_BLOCK 8'hd2
`define UK1_BLOCK 8'h99
`define UK2_BLOCK 8'h55
`define UK3_BLOCK 8'hb4
`define UK4_BLOCK 8'hcc
`define UK5_BLOCK 8'h66
`define UK6_BLOCK 8'h33
`define UK7_BLOCK 8'h4b
`define UK8_BLOCK 8'h87
`define SEP7_BLOCK 8'he1
`define SEP_BLOCK 8'h1e

// Aurora priorities

`define NPRIORITIES 8

`define CLOCK_COMPENSATION  0
`define NOT_READY           1
`define CHANNEL_BONDING     2
`define NATIVE_FLOW_CONTROL 3
`define USER_FLOW_CONTROL   4
`define USER_KBLOCKS        5
`define USER_DATA           6
`define IDLE                7

// Other

`define FULL_DATA 4'h8
`define DISABLE_DATA 4'hF