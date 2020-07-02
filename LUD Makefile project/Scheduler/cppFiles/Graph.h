#ifndef _GRAPH_H_
#define _GRAPH_H_

#include "stdafx.h"
#include "CCS.h"

// Shared variable map of delays for each operation
// These are typical values (Most Expected) for particular operation
EXTERN map<string, int> opDelay INITIALIZER({{"+", 12}, {"-", 12}, {"*",9}, {"/", 31}, {"rd", 2}, 
    {"wr", 2}, {"mac_add", 20}, {"mac_sub",20}, {"const", 0}, {"pass", 0}});


/*
* Name: Node
* Provides:
*   a. name     Name of the node
*   b. op       Operation
*   c. val      Value
*   d. children Pointers to the children nodes
*   e. parents  Pointers to the parents nodes
*   f. delay    Delay of the operation in terms of clock cycles
*   g. priority Priority of the node in scheduling
*   i. matIndex Node output's location in matrix in terms of row and column
*   j. ccsIndex Node output's location index in CCS format
*   k. matName  Node output's matrix name
*   l. done     Flag to indicate the computation is done and available in memory
*   m. ready    Ready status of the node for scheduling and execution
    n. dirty    Value present in memory is correct
    o. mulCount Count of remaining MAC operation
    p. store : Used by the function 'removeUselessNodes' to decide whether additional information has to be pushed into the vector 'musthaveSameMemLoc'.
* Methods:
*   a. Node()
*         Constructor to assign default values
*/

//matPointer & memMapIndex
//Suppose the Node corresponds to L(513,511). Then name = L_513_511, matPointer points to L(of type CCS), memMapIndex is the index of rowInd of L where L(513,511) is stored.
//memMapIndex is important because BRAMAddr and BRAMInd are stored in L,U,A(of type CCS). While scheduling we need these address in struct AU_Operation. With memMapIndex we can directly fetch the address from BRAMAddr(matPointer->BRAMAddr[memMapIndex]) and BRAM index from BRAMInd(matPointer->BRAMInd[memMapIndex])
struct Node
{
    f_type val;
    vector<Node *> children, parents;
    string op, name;
    int delay, priority, level, memMapIndex;
    int nodeId = nodeIdNULL;
    string matName;
    CCS* matPointer;
    
    bool store = false;
    int totalMACCount = 0;
    
    //My extra variables
    //These 2 variables will be used exclusively by 'wr' nodes.
    int wrBRAMId = -1;
    int wrBRAMAddr = -1;
    
    bool readyBit = false; //Its used to indicate whether the final value of the node is saved in memory.
    //This variable is used exclusively for MAC nodes. A single mac node may be performing a long operation consisting of 2 or more mac operation like (A-BC-DE). Inorder to track which all opearations have been done, this variable is used.
    //Size of 'nodeEvalStatus' is equal to no. of mac operations performed by the node(ex. A-BC-DE-FG will have size 3)
    //Default value of each element is 0.
    //status value 0 indicates not evaluated,status value 1 indicates evaluated, 2 indicates evaluating.
    vector<int> nodeEvalStatus; 
    //Sometimes if the mac operation is too long, the intermediate results need to be saved in memory. This variable tells if the intermediate result is updated in memory to the latest evaluation. 
    //If the value is 0, it indicates that the latest result is present at the output of some Arithmetic or is being currently written in the BRAM instead of being present in BRAM.
    //The value of 1 indicates that the latest intermediate result is stored in BRAM. For mac nodes if latestIntermediateResultAvailable = 1 and readyBit = false, it means mac operations are still remaining in that node.
    //While a mac node is being evaluated, 'latestIntermediateResultAvailable' is reset to 0. 
    //This variable is also used to prevent unnecessary entry of those nodes in the 'schedulable' list which are currently being executed.
    int latestIntermediateResultAvailable = -1;
    Node()
    {
        this->val = 0;
        this->level = levelNULL;
        this->priority = priorityNULL;
    }
};

/*
* Name: Graph
* Provides:
*   a. nodes    : List of all the nodes in the graph pair(name, Node)
*   b. roots    : List of the pointers to root nodes
*   c. leaves   : List of the pointers to leaf nodes
*   d. musthaveSameMemLoc : while removing useless nodes from the graph(function-removeUselessNodes), if 'store' parameter of the node is true, then 'matPointer' & 'memMapIndex' of the useless node and its single child node will be stored in this variable as a tuple(Useless nodes will always have only a single child node).
* Methods:
*   a. clearGraph()
*       removes all the nodes in the graph
*   b. insertNode()
*       insert name, node pair in the graph
*   c. printToFile()
*       print the graph in to a file [dot file too if MAKE_GRAPH is defined]
*   d. executeGraph()
*       find values of all the nodes in the graph
*   e. findLeavesAndRoots()
*       Find leaves and roots of the graph
*   f. removeUselessNodes()
*       remove useless nodes in the graph 
*       (Uselessness is defined in function removeType)
*/

class Graph
{
    public:
    // data
    unordered_map<string, Node> nodes;
    vector<vector<Node *>> levels;
    vector<Node *> roots, leaves;
    int maxLevel = 0;
    vector<std::tuple<CCS *, int, CCS *, int>> musthaveSameMemLoc;
    // methods
    void clearGraph();
    Node* insertNode(Node & node);
    void printToFile(ofstream & outFile, bool leavesAndRoots = false);
    void findLeavesAndRoots();
    void removeUselessNodes();
    void assignLevelsAndIds();
    void executeGraphUsingLevels(string const dotFileName = "exeTree");
};


// Calls graphViz to generate PNG from dot file
void convertDotToPng(string dotFileName);

#endif