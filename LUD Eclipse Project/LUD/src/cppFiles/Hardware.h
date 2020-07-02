#ifndef _HARDWARE_H_
#define _HARDWARE_H_

#include "stdafx.h"

#ifdef DEFINE_VARIABLES
#define EXTERN                  
#define INITIALIZER(...)        = __VA_ARGS__
#else
#define EXTERN                  extern
#define INITIALIZER(...)       
#endif

#define instBRAMSize 4096

/*
* Read Latency : valid output will be available at the corresponding port in the 
                    n-th cycle. e.g. read latency = 1 -> output will be available
                    in the next cycle
* Write latency: Output will be written to the corresponding memory cell by the 
                    end of the n-th cycle. e.g. write latency = 0 -> data will 
                    be written in that cycle itself
* Write First  : 
*/

struct BRAM
{
    int size;
    int ports;
    int readLatency;
    int writeLatency;
    bool WRITE_FIRST;
};

EXTERN struct BRAM Xilinx_QuadPort_BRAM INITIALIZER({2048, 4, opDelay["rd"],opDelay["wr"], true});
EXTERN struct BRAM Xilinx_DualPort_BRAM INITIALIZER({1024, 2, opDelay["rd"]/2, opDelay["wr"]/2, true});
EXTERN struct BRAM Xilinx_SinglePort_BRAM INITIALIZER({4096, 1, opDelay["rd"]/2, opDelay["wr"]/2, true});

struct ArithmeticUnit
{
    string operation;
    bool pipelined;
    int pipeLatency;
};

// struct ArithmeticUnit Xilinx_Floating_MAC_Unit();
EXTERN struct ArithmeticUnit Xilinx_Floating_MAC_Unit INITIALIZER({
    "mac_sub",
    true,
    opDelay["mac_sub"]
});

EXTERN struct ArithmeticUnit Xilinx_Floating_Divide_Unit INITIALIZER({
    "/",
    true,
    opDelay["/"]
});

EXTERN struct ArithmeticUnit Xilinx_Floating_Add_Unit INITIALIZER({
    "+",
    true,
    opDelay["+"]
});

EXTERN struct ArithmeticUnit Xilinx_Floating_Sub_Unit INITIALIZER({
    "-",
    true,
    opDelay["-"]
});

EXTERN struct ArithmeticUnit Xilinx_Floating_Mul_Unit INITIALIZER({
    "*",
    true,
    opDelay["*"]
});

/* ⚠ ⚠ ⚠ ⚠ ⚠ ⚠ ⚠ ⚠
* IMPORTANT NOTICE : 
* 1: Arithmetic units must follow the order : MAC units and then Divider units
* 2: All BRAMs must have same number of ports
*/

struct HardwareConfig
{
    vector<BRAM *> BRAMs;
    vector<ArithmeticUnit *> AUs;
    int BRAMAddressWidth;
    int AUMuxSelWidth;
    int BRAMMuxSelWidth;
    int numMACUnits;
};

#endif
