#define DEFINE_VARIABLES
#include "stdafx.h"
#include "CCS.h"
#include "Graph.h"
#include "sparseLU.h"
#include "Schedule.h"
#include "Hardware.h"
#include "float_to_int.h"
#include "double_to_longint.h"
#include <typeinfo>
#include <string>

#include "math.h"

void development(struct HardwareConfig &simpleHardware);
void test(struct HardwareConfig &simpleHardware, string testName = "rajat11", string postfix = "");
void printToFileForVerification(CCS A,CCS L, CCS U, HardwareConfig hw);
void printDataForSVFile(CCS A,vector<string> instruction_list);
void print_A_ToFileForFPGADynamicLoading(CCS A,HardwareConfig hw);
void print_INST_ToFileForFPGADynamicLoading(vector<string> instruction_list);


int main(int argc, char* argv[])
{
#ifdef PRINT_DEBUG_MSG
        debugFile.open("debugMessage.txt");
#else
        ofstream debugFile("Output.log");
#endif

        g_nzThreshold = 1.0e-7;
        g_errThreshold = 1.0e-3;

        /* ⚠ ⚠ ⚠ ⚠ ⚠ ⚠ ⚠ ⚠
         * IMPORTANT NOTICE : Arithmetic units must follow the order : MAC units and then Divider units
         */
        struct HardwareConfig simpleHardware =
        {       //Minimum 4 ports are necessary for scheduler to work. The 4 ports can be distributed in any manner. i.e. single quad port BRAM or 2 Dual Port BRAM or 4 Single port BRAM
                {
                        /*&Xilinx_DualPort_BRAM,
                        &Xilinx_DualPort_BRAM,
                        &Xilinx_DualPort_BRAM,
                        &Xilinx_DualPort_BRAM,
                        &Xilinx_DualPort_BRAM,
                        &Xilinx_DualPort_BRAM,
                        &Xilinx_DualPort_BRAM,
                        &Xilinx_DualPort_BRAM*/
                        
                        &Xilinx_QuadPort_BRAM,
                        &Xilinx_QuadPort_BRAM,
                        &Xilinx_QuadPort_BRAM,
                        &Xilinx_QuadPort_BRAM
                        
                        /*&Xilinx_SinglePort_BRAM,
                        &Xilinx_SinglePort_BRAM,
                        &Xilinx_SinglePort_BRAM,
                        &Xilinx_SinglePort_BRAM
                        &Xilinx_SinglePort_BRAM,
                        &Xilinx_SinglePort_BRAM,
                        &Xilinx_SinglePort_BRAM,
                        &Xilinx_SinglePort_BRAM,
                        &Xilinx_SinglePort_BRAM,
                        &Xilinx_SinglePort_BRAM,
                        &Xilinx_SinglePort_BRAM,
                        &Xilinx_SinglePort_BRAM,
                        &Xilinx_SinglePort_BRAM,
                        &Xilinx_SinglePort_BRAM,
                        &Xilinx_SinglePort_BRAM,
                        &Xilinx_SinglePort_BRAM*/
                },
                {
                        &Xilinx_Floating_MAC_Unit,
                        &Xilinx_Floating_MAC_Unit,
                        &Xilinx_Floating_MAC_Unit,
                        &Xilinx_Floating_MAC_Unit,
                        
                        &Xilinx_Floating_Divide_Unit,
                        &Xilinx_Floating_Divide_Unit,
                        &Xilinx_Floating_Divide_Unit,
                        &Xilinx_Floating_Divide_Unit
                },
                (int)ceil(log2(simpleHardware.BRAMs[0]->size)), //BRAMAddressWidth
                (int)ceil(log2(simpleHardware.BRAMs.size()*simpleHardware.BRAMs[0]->ports + simpleHardware.AUs.size() + 1)), //AUMuxSelWidth
                (int)ceil(log2(simpleHardware.BRAMs.size()*simpleHardware.BRAMs[0]->ports + simpleHardware.AUs.size())), //BRAMMuxSelWidth
                4 //numMACUnits
        };


        cout << "Checking if processor is available...";
        if(system(NULL)) puts("ok");
        else exit(EXIT_FAILURE);

        if(argc == 1)
        {
                cout << endl << "🏷 Using default 5X5 matrix" << endl;
                development(simpleHardware);
        }
        else
        {
                test(simpleHardware, argv[1]);
        }

        debugFile.close();

        cout << "Exiting Main\n\n" << endl;
}

void development(struct HardwareConfig &simpleHardware)
{
        string dotFileName = "exeTree";

        vector<int> colPtr = { 0, 3, 5, 7, 9, 11 };
        vector<int> rowInd = { 0, 2, 3, 1, 3, 0, 4, 1, 3, 0, 4 };
        vector<f_type> val = { 5.0, 2.0, 1.0, 4.0, -3.0, -5.0, -2.0, -4.0, -1.0, 6.0, 3.0 };

        CCS A(colPtr, rowInd, val, 5, "A");

        CCS L(A.numRows, A.numCols, "L");
        CCS U(A.numRows, A.numCols, "U");

        Graph LUmat;
        //Checks if any of the diagonal elements of U is 0.
        //The non zero locations in U and L matrix is also identified. But they will be filled with 0 as for now(diagonal elements are 1).
        LUGetOperationList(A, L, U, LUmat); //File sparseLU.cpp

        //Initializing BRAMAddr and BRAMInd to some garbage value.(-1 in this case)
        A.resizeMemMap();
        L.resizeMemMap();
        U.resizeMemMap();

        LUmat.removeUselessNodes(); //remove nodes of type 'mac_sub' which are not performing any mac operation. To be more presize, nodes with op = 'pass'
        LUmat.findLeavesAndRoots();
        //Assign levels and Ids to each node. Each node will have a unique Id but multiple nodes can have same level. 
        LUmat.assignLevelsAndIds();

        //The priorities are being assigned from bottom up.
        //For div node, the priority is the sum of the priority of parent nodes + delay of div node
        //For mac node, the priority is the sum of priority of parent nodes + an additional factor which depends on the delay of MAC node and length of MAC operation
        assignPriority(LUmat);// Defined in file schedule.cpp
        
        //Executes the graph and computes the 'val' parameter of each node(except nodes of type "rd" as they are already filled while foumulating the graph in the function LUGetOperationList(sub function createRdNode))
        LUmat.executeGraphUsingLevels(dotFileName);

        //The L and U values calculated are stored in the corresponding matrices. BRAM addresses of A, L, U are still not assigned
        assignGraphValuesToMats(LUmat, L, U); //Defined in the file sparseLU.cpp
        
        //Prints the graph
        LUmat.printToFile(debugFile, true);

        //BRAM addressed of A, L, U are assigned.
        assignScatteredAddresses(LUmat, A, L, U, simpleHardware);//defined in function schedule.cpp
        
        A.print(true);
        L.print(true);
        U.print(true);
        
        //Print the arrays for verification purpose(This is my own function)
        printToFileForVerification(A,L,U, simpleHardware);

        //Prints the matrices and bram address
        //A.print(true);
        //L.print(true);
        //U.print(true);

#ifdef MAKE_GRAPH
        convertDotToPng(dotFileName);
#endif
        
        Schedule schedule;
        //This scheduler is designed to handle only nodes of type "mac_sub", "/", "const", "wr", "rd".
        //"rd" nodes are special nodes because they mark those nodes which are already available in memory before the scheduling starts(i.e. it's only used for A_x_y named nodes)
        scheduleNoReg_exp(LUmat, simpleHardware, schedule);

        printReadableSchedule(schedule);
        
        vector<string> instruction_list; //This variable will be used to generate a header file for xilinx sdk which will load the instruction stream into BRAM using c code
        convertScheduleToInstructionStream(simpleHardware, schedule,instruction_list);
        
        //arrays that would be used in system verilog file for verification
        printDataForSVFile(A,instruction_list);
        
        //Prints the C code to load the File in FPGA. For now, the below two functions are valid only when using 32 bit float.
        //Also the axi addresses of the BRAMS have been hardcoded for one specific project.
        //Hence to make this function dynamic, a lot of changes have to be done.....but it shouldn't be that tough.
        //The toughest part would be to write a function that converts long int to double(both long int and double should have same representation in bits) to make it work with 64 bit double.
        print_A_ToFileForFPGADynamicLoading(A,simpleHardware);
        print_INST_ToFileForFPGADynamicLoading(instruction_list);

        cout << "\n";
        cout << "***************************************************************************" << "\n";
        cout << "Total Cycles(or Instructions) = " << instruction_list.size() << "\n";
        cout << "Width of each Instruction in Instruction BRAM = "<<instruction_list[0].size()<<"\n";
        cout << "Instruction BRAM Address width = " << (int)ceil(log2(instBRAMSize)) << "\n";
        cout << "Data BRAM Address width = " << (int)ceil(log2(simpleHardware.BRAMs[0]->size)) << "\n";
        cout << "Arithmetic Unit(AU) Mux select pins width = " << simpleHardware.AUMuxSelWidth << "\n";
        cout << "BRAM Mux select pins width = " << simpleHardware.BRAMMuxSelWidth << "\n";
        cout << "***************************************************************************" << "\n\n";

}



void test(struct HardwareConfig &simpleHardware, string testName,  string postfix)
{
        string dotFileName = "exeTree";
        // test matrix name


        CCS A("../test/exported/" + testName + "/" + testName +"_amd_ALU", "A");
        CCS L(A.numRows, A.numCols, "L");
        CCS U(A.numRows, A.numCols, "U");

        cout << "Cols: " << A.numCols << " Rows: " << A.numCols << endl;

        Graph LUmat;
        debugFile << "Main: Init completed" << endl;
        LUGetOperationList(A, L, U, LUmat);
        A.resizeMemMap();
        L.resizeMemMap();
        U.resizeMemMap();
        LUmat.removeUselessNodes();
        LUmat.findLeavesAndRoots();
        LUmat.assignLevelsAndIds();
        assignPriority(LUmat);
        LUmat.executeGraphUsingLevels(dotFileName);
        assignGraphValuesToMats(LUmat, L, U);

        CCS Uref("../test/exported/" + testName + "/" + testName + "_amd_U", "Uref");
        CCS Lref("../test/exported/" + testName + "/" + testName + +"_amd_L", "Lref");

        //Lref.resizeMemMap();
        //Lref.print(true);

        CCS Ucpy = U;
        CCS Lcpy = L;

        //cout << "Ignore the comparison result. If results are not matching, its may be due to precision\n";
        cout << "Comparing U Matrix: " << ((Ucpy == Uref) ? "1 ✅" : "0 ❌") << endl;
        cout << "Comparing L Matrix: " << ((Lcpy == Lref) ? "1 ✅" : "0 ❌") << endl;
        
        
        //Prints the graph. Use this function before "assignScatteredAddresses" because "wr" type nodes might be added
        //by the function "assignScatteredAddresses". So, debugging the graph might be harder.
        LUmat.printToFile(debugFile, true);

        assignScatteredAddresses(LUmat, A, L, U, simpleHardware);
        
        A.print(true);
        L.print(true);
        U.print(true);
        
        Schedule schedule;
        //This scheduler is designed to handle only nodes of type "mac_sub", "/", "const", "wr", "rd".
        //2 "wr" nodes should not be connected back to back(there is no need to connect 2 "wr" nodes back to back)
        //"rd" nodes are special nodes because they mark those nodes which are already available in memory before the scheduling starts(i.e. it's only used for A_x_y named nodes)
        scheduleNoReg_exp(LUmat, simpleHardware, schedule);

        printReadableSchedule(schedule);

        vector<string> instruction_list; //This variable will be used to generate a header file for xilinx sdk which will load the instruction stream into BRAM using c code
        convertScheduleToInstructionStream(simpleHardware, schedule,instruction_list);
        
        //Print the arrays for verification purpose(This is my own function)
        printToFileForVerification(A,L,U, simpleHardware);
        
        //arrays that would be used in system verilog file for verification
        printDataForSVFile(A,instruction_list);

        //Prints the C code to load the File in FPGA
        print_A_ToFileForFPGADynamicLoading(A,simpleHardware);
        print_INST_ToFileForFPGADynamicLoading(instruction_list);
        
        cout << "\n";
        cout << "***************************************************************************" << "\n";
        cout << "Total Cycles(or Instructions) = " << instruction_list.size() << "\n";
        cout << "Width of each Instruction in Instruction BRAM = "<<instruction_list[0].size()<<"\n";
        cout << "Instruction BRAM Address width = " << (int)ceil(log2(instBRAMSize)) << "\n";
        cout << "Data BRAM Address width = " << (int)ceil(log2(simpleHardware.BRAMs[0]->size)) << "\n";
        cout << "Arithmetic Unit(AU) Mux select pins width = " << simpleHardware.AUMuxSelWidth << "\n";
        cout << "BRAM Mux select pins width = " << simpleHardware.BRAMMuxSelWidth << "\n";
        cout << "***************************************************************************" << "\n\n";

        ofstream resultFile("../test/" + testName + postfix + "_log.csv");
        resultFile << "Schedule for " << testName << endl;
        resultFile << "clock, Scheduled Flops" << endl;
        for(int i = 0; i < schedule.AUSchedule.size(); i++)
        {
                resultFile << to_string(i) + ", " + to_string(schedule.AUSchedule[i].size()) << endl;
        }
        resultFile.close();

        /* ⚠ ⚠ ⚠ ⚠ ⚠ ⚠ ⚠ ⚠
         * Takes tooooooooooo much time. Don't ever uncomment
         */
        // #ifdef MAKE_GRAPH
        // convertDotToPng(dotFileName);
        // #endif
}


void printToFileForVerification(CCS A,CCS L, CCS U, HardwareConfig hw){
        int i,j;
        int rowind,colind;
        ofstream myfile;
        int inf_nan_count = 0;
        myfile.open ("Verification_ALU.txt");

        //myfile << "f_type A["<<hw.BRAMs.size()<<"]["<<hw.BRAMAddressWidth<<"]"<<";\n";
        f_type testVar;
        if(strcmp(typeid(testVar).name(),"f") == 0) {
                myfile << "float L["<<hw.BRAMs.size()<<"]["<<pow(2,hw.BRAMAddressWidth)<<"]"<<";\n";
                myfile << "float U["<<hw.BRAMs.size()<<"]["<<pow(2,hw.BRAMAddressWidth)<<"]"<<";\n";
        }
        else if(strcmp(typeid(testVar).name(),"d") == 0) {
                myfile << "double L["<<hw.BRAMs.size()<<"]["<<pow(2,hw.BRAMAddressWidth)<<"]"<<";\n";
                myfile << "double U["<<hw.BRAMs.size()<<"]["<<pow(2,hw.BRAMAddressWidth)<<"]"<<";\n";
        }
        else{
                myfile << "invalidType L["<<hw.BRAMs.size()<<"]["<<pow(2,hw.BRAMAddressWidth)<<"]"<<";\n";
                myfile << "invalidType U["<<hw.BRAMs.size()<<"]["<<pow(2,hw.BRAMAddressWidth)<<"]"<<";\n";
        }
        myfile << "int row_ind["<<hw.BRAMs.size()<<"]["<<pow(2,hw.BRAMAddressWidth)<<"]"<<";\n";
        myfile << "int col_ind["<<hw.BRAMs.size()<<"]["<<pow(2,hw.BRAMAddressWidth)<<"]"<<";\n";

        myfile <<"for(int i=0;i<"<<hw.BRAMs.size()<<";i++){\n";
        myfile <<"for(int j=0;j<"<<pow(2,hw.BRAMAddressWidth)<<";j++){\n";
        myfile <<"L[i][j] = -11110000; "<<"U[i][j] = -11110000; \n";
        myfile <<"row_ind[i][j] = -1; "<<"col_ind[i][j] = -1; \n";
        myfile <<"}\n";
        myfile <<"}\n";

        /*for(i=0;i<A.colPtr.size()-1;i++){
            for(j = A.colPtr[i]; j < A.colPtr[i+1]; j++){
                rowind = A.BRAMInd[j];
                colind = A.BRAMAddr[j];
                myfile << "A["<<rowind<<"]["<<colind<<"] = "<<A.val[j]<<";\n";
            }
           }*/
        if(strcmp(typeid(testVar).name(),"f") == 0) {
            myfile.precision(8);
        }
        else if(strcmp(typeid(testVar).name(),"d") == 0){
            myfile.precision(17);
        }
        
        for(i=0; i<L.colPtr.size()-1; i++) {
                for(j = L.colPtr[i]; j < L.colPtr[i+1]; j++) {
                        rowind = L.BRAMInd[j]; //not the actual row
                        colind = L.BRAMAddr[j]; //not the actual column
                        if(rowind != -2) { //It indicated the diagonal element containing value 1
                                if(!isinf(L.val[j]) && !isnan(L.val[j])){//The number should be valid
                                    myfile << "L["<<rowind<<"]["<<colind<<"] = "<<L.val[j]<<";   ";
                                    myfile << "row_ind["<<rowind<<"]["<<colind<<"] = "<<L.rowInd[j]<<";   "; //L.rowInd[j] is actual row
                                    myfile << "col_ind["<<rowind<<"]["<<colind<<"] = "<<i<<";   "; //i is the actual column
                                    myfile << "// L("<<L.rowInd[j]<<","<<i<<")\n";
                                }
                                else{
                                    inf_nan_count = inf_nan_count + 1;
                                }
                        }
                }
        }

        for(i=0; i<U.colPtr.size()-1; i++) {
                for(j = U.colPtr[i]; j < U.colPtr[i+1]; j++) {
                        rowind = U.BRAMInd[j];
                        colind = U.BRAMAddr[j];
                        if(!isinf(U.val[j]) && !isnan(U.val[j])){//The number should be valid
                            myfile << "U["<<rowind<<"]["<<colind<<"] = "<<U.val[j]<<";   ";
                            myfile << "row_ind["<<rowind<<"]["<<colind<<"] = "<<U.rowInd[j]<<";   ";
                            myfile << "col_ind["<<rowind<<"]["<<colind<<"] = "<<i<<";   ";
                            myfile << "// U("<<U.rowInd[j]<<","<<i<<")\n";
                        }
                        else{
                            inf_nan_count = inf_nan_count + 1;
                        }
                }
        }
        myfile.close();
        cout << "\n" << endl;
        cout << "****************************************************************************************"<<endl;
        if(inf_nan_count !=0){
            cout << "Infinite or Not a Number values exist because of limitation of 32-bit float." << "\n";
            cout << "To get rid of them switch to 64-bit double." << "\n"; 
            cout << "This can be done in the file stdafx.h by changing the value of f_type to double." << "\n\n";
        }
        cout << "                                     inf/nan = " << inf_nan_count << endl;
        cout << "****************************************************************************************"<<endl;
}

void printDataForSVFile(CCS A,vector<string> instruction_list){
int i,j,k;
f_type testVar;
//Global variables to be used in system verilog files for test bench purposes. Hence it will be printed to a separate file
ofstream myfile_sv;
myfile_sv.open ("systemVerilog_A_INST.h");
myfile_sv << "//Constant array to load the A matrix\n";
myfile_sv << "localparam integer A_size = " << dec << A.val.size() << ";\n";

if(strcmp(typeid(testVar).name(),"f") == 0) {
    myfile_sv << "localparam integer A[0:" << dec << A.val.size()-1 << "] = '{";
    for(i=0; i<A.val.size()-1; i++) {
        myfile_sv << "32'h" <<hex <<float_to_int(A.val[i])<<", ";
    }
    myfile_sv << "32'h" << hex <<float_to_int(A.val[A.val.size()-1]) << "};\n";
}
else if(strcmp(typeid(testVar).name(),"d") == 0) {
    myfile_sv << "localparam longint A[0:" << dec << A.val.size()-1 << "] = '{";
    for(i=0; i<A.val.size()-1; i++) {
        myfile_sv << "64'h" << hex << double_to_longint(A.val[i])<<", ";
    }
    myfile_sv << "64'h" << hex << double_to_longint(A.val[A.val.size()-1]) << "};\n";
}

myfile_sv << "localparam integer A_BRAMInd[0:" << dec << A.BRAMInd.size()-1 <<"] = '{";
for(i=0; i<A.BRAMInd.size()-1; i++) {
myfile_sv << A.BRAMInd[i] <<", ";
}
myfile_sv << A.BRAMInd[A.BRAMInd.size()-1] << "};\n";

myfile_sv << "localparam integer A_BRAMAddr[0:" << dec << A.BRAMAddr.size()-1 <<"] = '{";
for(i=0; i<A.BRAMAddr.size()-1; i++) {
myfile_sv << A.BRAMAddr[i] <<", ";
}
myfile_sv << A.BRAMAddr[A.BRAMAddr.size()-1] << "};\n\n";

//Instruction variable**********************************************************************************************
int DATA_BUS_SIZE;
if(strcmp(typeid(testVar).name(),"f") == 0) {
    DATA_BUS_SIZE = 32;
}
else if(strcmp(typeid(testVar).name(),"d") == 0){
    DATA_BUS_SIZE = 64;
}
//calculating the number of 32/64 bit registers required for transfering a single instruction
        string s_tmp = instruction_list[0];
        string sub_str;
        int insWidth = s_tmp.length();
        int reg_count = ceil(insWidth/(float)DATA_BUS_SIZE);

//Variable to store the instruction once splitted into multiple instruction of 32 bit size
        if(strcmp(typeid(testVar).name(),"f") == 0) {
            int **final_instructions;
            int integer_sub_inst;
            final_instructions = (int **)malloc(instruction_list.size()*sizeof(int *));
            for(i=0; i<instruction_list.size(); i++) {
                final_instructions[i] = (int *)malloc(reg_count*sizeof(int));
            }
            
            //Splitting the instructions
            for(i = 0; i<instruction_list.size(); i++) {

                //Zeropadding the instruction so that its length is multiple of 32
                string inst(reg_count*DATA_BUS_SIZE,'0');
                inst.replace(reg_count*DATA_BUS_SIZE-insWidth,insWidth,instruction_list[i]);

                //Dividing a long instruction into multiple instruction of size 32 bits
                int sub_str_end_index = reg_count*DATA_BUS_SIZE;
                for(j=0; j<reg_count; j++) {
                        sub_str = inst.substr(sub_str_end_index-DATA_BUS_SIZE,DATA_BUS_SIZE);
                        sub_str_end_index = sub_str_end_index - DATA_BUS_SIZE;

                        //converting the string into binary
                        integer_sub_inst = 0;

                        for(k=DATA_BUS_SIZE-1; k>=0; k--) {
                                if(sub_str.at(k) == '1')
                                        integer_sub_inst = integer_sub_inst + (1<<((DATA_BUS_SIZE-1)-k));
                        }

                        final_instructions[i][j] = integer_sub_inst;
                }
            }
            
            //Global variables for system verilog file
            //myfile_sv.open ("systemVerilog_A_INST.h",ios_base::app|ios_base::out);
            myfile_sv << "//Constant array to load the instruction BRAM\n";
            myfile_sv << "localparam integer total_instructions = " << dec << instruction_list.size() << ";\n";
            myfile_sv << "localparam integer sub_instructions = " << dec << reg_count << ";\n";
            myfile_sv << "localparam integer Inst[0:" << dec << instruction_list.size()-1 << "][0:" << dec << reg_count-1 << "] = '{";
            for(i = 0; i < instruction_list.size(); i++) {
                myfile_sv << "{";
                for(j = 0; j < reg_count; j++) {
                if(j == reg_count -1)
                    myfile_sv << "32'h" << hex << final_instructions[i][j];
                else
                    myfile_sv << "32'h" << hex << final_instructions[i][j] << ", ";
                }
                if(i == instruction_list.size()-1)
                    myfile_sv << "}";
                else
                    myfile_sv << "},";
                }
            myfile_sv << "};\n\n";
        }
        else if(strcmp(typeid(testVar).name(),"d") == 0){
            long int **final_instructions;
            long int integer_sub_inst;
            final_instructions = (long int **)malloc(instruction_list.size()*sizeof(long int *));
            for(i=0; i<instruction_list.size(); i++) {
                final_instructions[i] = (long int *)malloc(reg_count*sizeof(long int));
            }
            
            //Splitting the instructions
            for(i = 0; i<instruction_list.size(); i++) {

                //Zeropadding the instruction so that its length is multiple of 32
                string inst(reg_count*DATA_BUS_SIZE,'0');
                inst.replace(reg_count*DATA_BUS_SIZE-insWidth,insWidth,instruction_list[i]);

                //Dividing a long instruction into multiple instruction of size 32 bits
                int sub_str_end_index = reg_count*DATA_BUS_SIZE;
                for(j=0; j<reg_count; j++) {
                        sub_str = inst.substr(sub_str_end_index-DATA_BUS_SIZE,DATA_BUS_SIZE);
                        sub_str_end_index = sub_str_end_index - DATA_BUS_SIZE;

                        //converting the string into binary
                        integer_sub_inst = 0;

                        for(k=DATA_BUS_SIZE-1; k>=0; k--) {
                                if(sub_str.at(k) == '1')
                                        integer_sub_inst = integer_sub_inst + ((long int)1<<((DATA_BUS_SIZE-1)-k));
                        }

                        final_instructions[i][j] = integer_sub_inst;
                }
            }
            
            //Global variables for system verilog file
            //myfile_sv.open ("systemVerilog_A_INST.h",ios_base::app|ios_base::out);
            myfile_sv << "//Constant array to load the instruction BRAM\n";
            myfile_sv << "localparam integer total_instructions = " << dec << instruction_list.size() << ";\n";
            myfile_sv << "localparam integer sub_instructions = " << dec << reg_count << ";\n";
            myfile_sv << "localparam longint Inst[0:" << dec << instruction_list.size()-1 << "][0:" << dec << reg_count-1 << "] = '{";
            for(i = 0; i < instruction_list.size(); i++) {
                myfile_sv << "{";
                for(j = 0; j < reg_count; j++) {
                if(j == reg_count -1)
                    myfile_sv << "64'h" << hex << final_instructions[i][j];
                else
                    myfile_sv << "64'h" << hex << final_instructions[i][j] << ", ";
                }
                if(i == instruction_list.size()-1)
                    myfile_sv << "}";
                else
                    myfile_sv << "},";
                }
            myfile_sv << "};\n\n";
        }

myfile_sv.close();
}

void print_A_ToFileForFPGADynamicLoading(CCS A,HardwareConfig hw){
        int i,j;
        ofstream myfile;

        myfile.open ("FPGALoad_A.h");

        //Global variables
        myfile << "//#include \"int_to_float.h\" //Already included in the main file in xilinx sdk\n";
        myfile << "//#include \"float_to_int.h\" //Already included in the main file in xilinx sdk\n\n";
        myfile << "//Large arrays in FPGA should be declared global to prevent later issues\n";
        myfile << "int A_size = " << A.val.size() << ";\n";
        f_type testVar;
        if(strcmp(typeid(testVar).name(),"f") == 0) {
                myfile << "float A[" << A.val.size() << "] = {";
        }
        else if(strcmp(typeid(testVar).name(),"d") == 0) {
                myfile << "double A[" << A.val.size() << "] = {";
        }
        else{
                myfile << "invalidType A[" << A.val.size() << "] = {";
        }
        for(i=0; i<A.val.size()-1; i++) {
                myfile.precision(10);
                myfile << A.val[i] <<", ";
        }
        myfile << A.val[A.val.size()-1] << "};\n\n\n";

        myfile << "int A_BRAMInd_size = " << A.BRAMInd.size() << ";\n";
        myfile << "int A_BRAMInd[" << A.BRAMInd.size() <<"] = {";
        for(i=0; i<A.BRAMInd.size()-1; i++) {
                myfile << A.BRAMInd[i] <<", ";
        }
        myfile << A.BRAMInd[A.BRAMInd.size()-1] << "};\n\n\n";

        myfile << "int A_BRAMAddr_size = " << A.BRAMAddr.size() << ";\n";
        myfile << "int A_BRAMAddr[" << A.BRAMAddr.size() <<"] = {";
        for(i=0; i<A.BRAMAddr.size()-1; i++) {
                myfile << A.BRAMAddr[i] <<", ";
        }
        myfile << A.BRAMAddr[A.BRAMAddr.size()-1] << "};\n\n\n";

//Delay function
        myfile << "void delay_FPGALoad_A(){\n";
        myfile << "int count = 100;\n";
        myfile << "for(int i=0;i<count;){\n";
        myfile << "i = i + 1;\n";
        myfile << "}\n";
        myfile << "}\n\n\n";
           
//Function to initialize/clear data BRAMs
myfile << "//Function to initialize/clear data BRAMs\n";
myfile << "void clearDataBRAM(){\n";
myfile << "int i,j;\n";
myfile << "//Making enable and write_enable 0 for all the BRAMS\n";
myfile << "for(i=0;i<"<<hw.BRAMs.size()<<";i++){\n";
myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*(16+i), 0); //Making enable 0\n";
myfile << "delay_FPGALoad_A();\n";
myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*(20+i), 0); //Making write enable 0\n";
myfile << "delay_FPGALoad_A();\n";
myfile << "}\n";
myfile << "for(i=0;i<"<<hw.BRAMs.size()<<";i++){\n";
myfile << "for(j=0;j<"<<hw.BRAMs[0]->size<<";j++){\n";
myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*(4+i), j); //Writing address,(4+i) is the offset\n";
myfile << "delay_FPGALoad_A();\n";
myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*(8+i), 0); //Writing data in din\n";
myfile << "delay_FPGALoad_A();\n";
myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*(16+i), 1); //Making enable 1\n";
myfile << "delay_FPGALoad_A();\n";
myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*(20+i), 1); //Making write enable 1\n";
myfile << "delay_FPGALoad_A();\n";
myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*(16+i), 0); //Making enable 0\n";
myfile << "delay_FPGALoad_A();\n";
myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*(20+i), 0); //Making write enable 0\n";
myfile << "delay_FPGALoad_A();\n";
myfile << "}\n";
myfile << "}\n";
myfile << "}\n\n\n";


//Function to verify if the data BRAMs is properly cleared
myfile << "//Function to verify if the data BRAMs is properly cleared\n";
myfile << "void verifyClearDataBRAM(){\n";
myfile << "int i,j;\n";
myfile << "int val,error_count;\n";
myfile << "error_count = 0;\n";
myfile << "//Making enable and write_enable 0 for all the BRAMS\n";
myfile << "for(i=0;i<"<<hw.BRAMs.size()<<";i++){\n";
myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*(16+i), 0); //Making enable 0\n";
myfile << "delay_FPGALoad_A();\n";
myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*(20+i), 0); //Making write enable 0\n";
myfile << "delay_FPGALoad_A();\n";
myfile << "}\n";
myfile << "for(i=0;i<"<<hw.BRAMs.size()<<";i++){\n";
myfile << "for(j=0;j<"<<hw.BRAMs[0]->size<<";j++){\n";
myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*(4+i), j); //Writing address,(4+i) is the offset\n";
myfile << "delay_FPGALoad_A();\n";
myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*(16+i), 1); //Making enable 1\n";
myfile << "delay_FPGALoad_A();\n";
myfile << "val = -1;\n";
myfile << "val = Xil_In32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*(12+i)); //Reading from BRAM\n";
myfile << "delay_FPGALoad_A();\n";
myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*(16+i), 0); //Making enable 0\n";
myfile << "delay_FPGALoad_A();\n";
myfile << "if(val != 0){\n";
myfile << "error_count = error_count + 1;\n";
myfile << "}\n";
myfile << "}\n";
myfile << "}\n";
myfile << "printf(\"Initialization errors in Data BRAMs = %d\\n\",error_count);\n";
myfile << "}\n\n\n";


//Function to write data into BRAM
        myfile << "//Function to write data into BRAM\n";
        myfile << "void FPGALoadA(){\n";

        myfile << "int i;\n";
        myfile << "int val_int;\n";

        myfile << "//The base address of the LUD accelerator may needed to be changed. The base address assumed is 'XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR'\n";

        myfile << "//Making enable and write_enable 0 for all the BRAMS\n";
        myfile << "for(i=0;i<"<<hw.BRAMs.size()<<";i++){\n";
        myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*(16+i), 0); //Making enable 0\n";
        myfile << "delay_FPGALoad_A();\n";
        myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*(20+i), 0); //Making write enable 0\n";
        myfile << "delay_FPGALoad_A();\n";
        myfile << "}\n";

        myfile << "//Writing A into BRAM\n";
        myfile << "for(i=0;i<A_size;i++){\n";
        myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*(4+A_BRAMInd[i]), A_BRAMAddr[i]); //Writing address,(4+A_BRAMInd[i]) is the offset\n";
        myfile << "delay_FPGALoad_A();\n";
        myfile << "val_int = float_to_int(A[i]);\n";
        myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*(8+A_BRAMInd[i]), val_int); //Writing data in din\n";
        myfile << "delay_FPGALoad_A();\n";
        myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*(16+A_BRAMInd[i]), 1); //Making enable 1\n";
        myfile << "delay_FPGALoad_A();\n";
        myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*(20+A_BRAMInd[i]), 1); //Making write enable 1\n";
        myfile << "delay_FPGALoad_A();\n";
        myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*(16+A_BRAMInd[i]), 0); //Making enable 0\n";
        myfile << "delay_FPGALoad_A();\n";
        myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*(20+A_BRAMInd[i]), 0); //Making write enable 0\n";
        myfile << "delay_FPGALoad_A();\n";
        myfile << "}\n";
        myfile << "}\n\n\n";

        myfile << "//Function to verify if A matrix is properly loaded into BRAMs\n";
        myfile << "void verify_A_FPGALoad(){\n";
        myfile << "int val_int, i;\n";

        if(strcmp(typeid(testVar).name(),"f") == 0) {
                myfile << "float val;\n";
                myfile << "float diff;\n";
        }
        else if(strcmp(typeid(testVar).name(),"d") == 0) {
                myfile << "double val;\n";
                myfile << "double diff;\n";
        }
        else{
                myfile << "invalidType val;\n";
        }

        myfile << "//Making enable and write_enable 0 for all the BRAMS\n";
        myfile << "for(i=0;i<"<<hw.BRAMs.size()<<";i++){\n";
        myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*(16+i), 0); //Making enable 0\n";
        myfile << "delay_FPGALoad_A();\n";
        myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*(20+i), 0); //Making write enable 0\n";
        myfile << "delay_FPGALoad_A();\n";
        myfile << "}\n";

        myfile << "//Reading A from BRAM\n";
        myfile << "for(i=0;i<A_size;i++){\n";
        myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*(4+A_BRAMInd[i]), A_BRAMAddr[i]); //Writing address,(4+A_BRAMInd[i]) is the offset\n";
        myfile << "delay_FPGALoad_A();\n";
        myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*(16+A_BRAMInd[i]), 1); //Making enable 1\n";
        myfile << "delay_FPGALoad_A();\n";
        myfile << "val_int = Xil_In32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*(12+A_BRAMInd[i])); //Reading from BRAM\n";
        myfile << "delay_FPGALoad_A();\n";
        myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*(16+A_BRAMInd[i]), 0); //Making enable 0\n";
        myfile << "delay_FPGALoad_A();\n";

        myfile << "val = int_to_float(val_int);\n";
        myfile << "diff = val - A[i];\n";
        myfile << "if(diff < -0.000001 || diff > 0.000001){\n";
        myfile << "printf(\"Error in verification, index = %d, correct value = %f, BRAM value = %f\\n\",i,A[i],val);\n";
        myfile << "}\n";
        myfile << "}\n";

        myfile << "}\n";

        myfile.close();
}


void print_INST_ToFileForFPGADynamicLoading(vector<string> instruction_list){
        int i,j,k;
//calculating the number of 32 bit registers required for transfering a single instruction
        string s_tmp = instruction_list[0];
        string sub_str;
        int insWidth = s_tmp.length();
        int reg_count = ceil(insWidth/32.0);
        int integer_sub_inst;

//Variable to store the instruction once splitted into multiple instruction of 32 bit size
        int **final_instructions;
        final_instructions = (int **)malloc(instruction_list.size()*sizeof(int *));
        for(i=0; i<instruction_list.size(); i++) {
                final_instructions[i] = (int *)malloc(reg_count*sizeof(int));
        }

//Splitting the instructions
        for(i = 0; i<instruction_list.size(); i++) {

//Zeropadding the instruction so that its length is multiple of 32
                string inst(reg_count*32,'0');
                inst.replace(reg_count*32-insWidth,insWidth,instruction_list[i]);

//Dividing a long instruction into multiple instruction of size 32 bits
                int sub_str_end_index = reg_count*32;
                for(j=0; j<reg_count; j++) {
                        sub_str = inst.substr(sub_str_end_index-32,32);
                        sub_str_end_index = sub_str_end_index - 32;

//converting the string into binary
                        integer_sub_inst = 0;

                        for(k=31; k>=0; k--) {
                                if(sub_str.at(k) == '1')
                                        integer_sub_inst = integer_sub_inst + (1<<(31-k));
                        }

                        final_instructions[i][j] = integer_sub_inst;
                }
        }

//The actual code that will go into xilinx sdk
        ofstream myfile;
        myfile.open ("FPGALoad_INST.h");

//Global variables
        myfile << "int Inst[" <<instruction_list.size() << "][" << reg_count << "] = {";
        for(i = 0; i < instruction_list.size(); i++) {
                myfile << "{";
                for(j = 0; j < reg_count; j++) {
                        if(j == reg_count -1)
                                myfile << final_instructions[i][j];
                        else
                                myfile << final_instructions[i][j] << ", ";
                }
                if(i == instruction_list.size()-1)
                        myfile << "}";
                else
                        myfile << "},";
        }
        myfile << "};\n";
        myfile << "int total_instructions = " << instruction_list.size() << ";\n";
        myfile << "int sub_instructions = " << reg_count << ";\n\n\n";
        
        
//Delay function
        myfile << "void delay_FPGALoad_INST(){\n";
        myfile << "int count = 100;\n";
        myfile << "for(int i=0;i<count;){\n";
        myfile << "i = i + 1;\n";
        myfile << "}\n";
        myfile << "}\n\n\n";
        
//Function to initialize/clear the Inst BRAM
myfile << "//Function to initialize/clear the Inst BRAM\n";
myfile << "void clearINSTBram(){\n";
myfile << "int i,j;\n";

myfile << "//Making enable and write_enable 0 for Instruction BRAMS\n";
myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*25, 0); //Making enable 0\n";
myfile << "delay_FPGALoad_INST();\n";
myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*26, 0); //Making write enable 0\n";
myfile << "delay_FPGALoad_INST();\n";

myfile << "//Writing 0 into BRAM\n";
myfile << "for(i=0;i<" <<instBRAMSize<<";i++){\n";
myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*24, i); //Writing address\n";
myfile << "delay_FPGALoad_INST();\n";
        
myfile << "for(j=0;j<sub_instructions;j++){\n";       
myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*(27+j), 0); //Writing data in din\n";
myfile << "delay_FPGALoad_INST();\n";
myfile << "}\n";
        
myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*25, 1); //Making enable 1\n";
myfile << "delay_FPGALoad_INST();\n";
myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*26, 1); //Making write enable 1\n";
myfile << "delay_FPGALoad_INST();\n";
myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*25, 0); //Making enable 0\n";
myfile << "delay_FPGALoad_INST();\n";
myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*26, 0); //Making write enable 0\n";
myfile << "delay_FPGALoad_INST();\n";
myfile << "}\n";

myfile << "}\n\n\n";

//Function to verify if the data BRAMs is properly cleared
myfile << "//Function to verify if the data BRAMs is properly cleared\n";
myfile << "void verifyClearINSTBram(){\n";
myfile << "int i,j;\n";
myfile << "int val,error_count;\n";
myfile << "error_count = 0;\n";

myfile << "//Making enable and write enable zero for Instruction BRAM\n";
myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*25, 0); //Making enable 0\n";
myfile << "delay_FPGALoad_INST();\n";
myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*26, 0); //Making write enable 0\n";
myfile << "delay_FPGALoad_INST();\n";

myfile << "//Reading Instructions from BRAM\n";
myfile << "for(i=0;i<"<<instBRAMSize<<";i++){\n";
myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*24, i); //Writing address,i is the offset\n";
myfile << "delay_FPGALoad_INST();\n";
myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*25, 1); //Making enable 1\n";
myfile << "delay_FPGALoad_INST();\n";
        
myfile << "for(j=0;j<sub_instructions;j++){\n";
myfile << "val = Xil_In32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*(39+j)); //Reading from BRAM\n";
myfile << "delay_FPGALoad_INST();\n";
myfile << "if(val != 0){\n";
myfile << "error_count = error_count + 1;\n";
myfile << "}\n";
myfile << "}\n";
        
myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*25, 0); //Making enable 0\n";
myfile << "delay_FPGALoad_INST();\n";
myfile << "}\n";
        
myfile << "printf(\"Initialization errors in INST BRAMs = %d\\n\",error_count);\n";

myfile << "}\n\n\n";
        
//Function to write data into Instruction BRAM
        myfile << "//Function to write data into BRAM\n";
        myfile << "void FPGALoadINST(){\n";

        myfile << "int i,j;\n";

        myfile << "//The base address of the LUD accelerator may needed to be changed. The base address assumed is 'XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR'\n";

        myfile << "//Making enable and write_enable 0 for Instruction BRAMS\n";
        myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*25, 0); //Making enable 0\n";
        myfile << "delay_FPGALoad_INST();\n";
        myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*26, 0); //Making write enable 0\n";
        myfile << "delay_FPGALoad_INST();\n";

        myfile << "//Writing Instructions into BRAM\n";
        myfile << "for(i=0;i<total_instructions;i++){\n";
        myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*24, i); //Writing address,i is the offset\n";
        myfile << "delay_FPGALoad_INST();\n";
        
        myfile << "for(j=0;j<sub_instructions;j++){\n";       
        myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*(27+j), Inst[i][j]); //Writing data in din\n";
        myfile << "delay_FPGALoad_INST();\n";
        
        myfile << "}\n";
        
        myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*25, 1); //Making enable 1\n";
        myfile << "delay_FPGALoad_INST();\n";
        myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*26, 1); //Making write enable 1\n";
        myfile << "delay_FPGALoad_INST();\n";
        myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*25, 0); //Making enable 0\n";
        myfile << "delay_FPGALoad_INST();\n";
        myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*26, 0); //Making write enable 0\n";
        myfile << "delay_FPGALoad_INST();\n";
        
        myfile << "}\n";
        
        myfile << "}\n\n\n";
        
//Function to verify data written in instruction memory
        myfile << "//Function to verify if Instructions is properly loaded into BRAMs\n";
        myfile << "void verify_INST_FPGALoad(){\n";
        myfile << "int i,j,val_int;\n";
        myfile << "//Making enable and write enable zero for Instruction BRAM\n";
        myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*25, 0); //Making enable 0\n";
        myfile << "delay_FPGALoad_INST();\n";
        myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*26, 0); //Making write enable 0\n";
        myfile << "delay_FPGALoad_INST();\n";
        
        myfile << "//Reading Instructions from BRAM\n";
        myfile << "for(i=0;i<total_instructions;i++){\n";
        myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*24, i); //Writing address,i is the offset\n";
        myfile << "delay_FPGALoad_INST();\n";
        myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*25, 1); //Making enable 1\n";
        myfile << "delay_FPGALoad_INST();\n";
        
        myfile << "for(j=0;j<sub_instructions;j++){\n";
        myfile << "val_int = Xil_In32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*(39+j)); //Reading from BRAM\n";
        myfile << "delay_FPGALoad_INST();\n";
        myfile << "if(val_int != Inst[i][j]){\n";
        myfile << "printf(\"Error in verification, i = %d, j = %d, Correct value = %d, BRAM value = %d\\n\",i,j,Inst[i][j],val_int);\n";
        myfile << "}\n";
        myfile << "}\n";
        
        myfile << "Xil_Out32(XPAR_MYIP_LUDECOMPOSITION_0_BASEADDR + 4*25, 0); //Making enable 0\n";
        myfile << "delay_FPGALoad_INST();\n";
        
        myfile << "}\n";
        
        myfile << "}\n\n\n";

        myfile.close();

}
