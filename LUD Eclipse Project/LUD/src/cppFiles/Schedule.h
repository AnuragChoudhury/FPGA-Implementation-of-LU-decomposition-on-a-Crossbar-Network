#ifndef _SCHEDULE_H_
#define _SCHEDULE_H_

#include "stdafx.h"
#include "Graph.h"
#include "CCS.h"
#include "Hardware.h"

#ifdef DEFINE_VARIABLES
#define EXTERN                  
#define INITIALIZER(...)        = __VA_ARGS__
#else
#define EXTERN                  extern
#define INITIALIZER(...)       
#endif

#define SELECTION_TABLE_SIZE 200
#define MAX_BRAMS 16

//The input channels of the muxes are given below. These lines are taken from verilog code with 4 quad port BRAMS, 4 MACs & 4 DIVs
/*inputLocations(0) <= mac_A_result_tdata;
inputLocations(1) <= mac_B_result_tdata;
inputLocations(2) <= mac_C_result_tdata;
inputLocations(3) <= mac_D_result_tdata;
inputLocations(4) <= div_A_result_tdata;
inputLocations(5) <= div_B_result_tdata;
inputLocations(6) <= div_C_result_tdata;
inputLocations(7) <= div_D_result_tdata;
inputLocations(8) <= bram_A_porta_dout;
inputLocations(8+1) <= bram_A_portb_dout;
inputLocations(8+2) <= bram_A_portc_dout;
inputLocations(8+3) <= bram_A_portd_dout;
inputLocations(12) <= bram_B_porta_dout;
inputLocations(12+1) <= bram_B_portb_dout;
inputLocations(12+2) <= bram_B_portc_dout;
inputLocations(12+3) <= bram_B_portd_dout;
inputLocations(16) <= bram_C_porta_dout;
inputLocations(16+1) <= bram_C_portb_dout;
inputLocations(16+2) <= bram_C_portc_dout;
inputLocations(16+3) <= bram_C_portd_dout;
inputLocations(20) <= bram_D_porta_dout;
inputLocations(20+1) <= bram_D_portb_dout;
inputLocations(20+2) <= bram_D_portc_dout;
inputLocations(20+3) <= bram_D_portd_dout;
inputLocations(24) <= (others => '0');
inputLocations(25) <= mac_A_result_tdata_1; //the '_tdata_1' signals are single cycle delayed outpu of the corresponding Arithmetic Unit
inputLocations(26) <= mac_B_result_tdata_1;
inputLocations(27) <= mac_C_result_tdata_1;
inputLocations(28) <= mac_D_result_tdata_1;
inputLocations(29) <= div_A_result_tdata_1;
inputLocations(30) <= div_B_result_tdata_1;
inputLocations(31) <= div_C_result_tdata_1;
inputLocations(32) <= div_D_result_tdata_1;*/

struct BRAM_Operation
{
    string node_name = "No_Name"; //Modified
    int op = BRAM_NOTHING;             // read/ write/ NO_OP. 0 = read, 1 = write
    int BRAMIndex; //If there are 4 BRAMs the BRAMIndex will be 0 or 1 or 2 or 3
    int portIndex; //Indicates the port number of that BRAM used to read or write the Node 
    int addr;
    int dinLoc;         // The input channel of the mux connected to BRAM Input
    int nodeId;         // node variable id
    Node *nodePtr;
};

struct AU_Operation
{
    string node_name = "No_Name"; //Modified
    string op = "NO_OP";
    int AUIndex;
    Node * nodePtr;
    vector<int> inputIds; //The Ids of the children node
    vector<int> inputLocs; //The input channels of the mux to which output of children are connected.
    int assignClock, retireClock;
    int BRAMIndex;
    int BRAMAddress;
    int outputId; //the id of the node for which arithmetic operation is being performed
};





// EXTERN struct BRAM_Operation NO_BRAM_OP INITIALIZER({
//     BRAM_NOTHING
// });


// EXTERN struct AU_Operation NO_AU_OP INITIALIZER({
//     "NO_OP"
// });


struct Schedule
{
    vector<vector<AU_Operation>> AUSchedule;
    vector<vector<BRAM_Operation>> memSchedule;
    void print();
};

void assignPriority(Graph &lGraph);
void assignScatteredAddresses(Graph &lGraph, CCS & A, CCS & L, CCS & U, HardwareConfig & hwConfig);

void scheduleNoReg_exp(Graph & lGraph, HardwareConfig & hwConfig, Schedule & schedule);

void printReadableSchedule(const struct Schedule sch);

void convertScheduleToInstructionStream(const struct HardwareConfig hwConfig, const struct Schedule sch,vector<string> &instruction_list);

#endif

