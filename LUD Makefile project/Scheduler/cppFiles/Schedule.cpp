#include "Schedule.h"

inline bool isMACType(Node * node)
{
    return node->op == "mac_sub" || node->op == "mac_add";
}

inline string vecToString(const vector<int> vec)
{
    string s = "";
    for(auto n : vec)
    {
        s += to_string(n) + ' ';
    }
    return(s);
}


// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// Assign priority
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------

void assignPriority(Graph & lGraph)
{
    for(int level = lGraph.maxLevel; level > 0; level --)
    {
        for(auto currNode : lGraph.levels[level])
        {
            for(auto parent : currNode->parents){
                currNode->priority += parent->priority; //initial priority is 0. Its assigned in struct Node definition in the file Graph.h
            }
            if(isMACType(currNode)){
                currNode->priority += opDelay[currNode->op] * ((int)currNode->children.size()/2);
                }
            else
                currNode->priority += opDelay[currNode->op];
        }
    }

    for(auto currNode : lGraph.levels[0])
    {
        currNode->priority += 10000000;
    }
}


bool checkBRAMContentionDivNode(vector<Node *> children,HardwareConfig & hwConfig, vector<int> &possibleBRAMIds){
    int BRAMCount = hwConfig.BRAMs.size();
    int portCount = hwConfig.BRAMs[0]->ports;

    vector<int> BRAMUtilization;

    for(int i=0;i<BRAMCount;i++){
        BRAMUtilization.push_back(0);
    }

    for(int i=0;i<children.size();i++){
    	int BRAMId;
    	if(children[i]->op == "wr"){
    		BRAMId = children[i]->wrBRAMId;
    	}
    	else{
    		BRAMId = children[i]->matPointer->BRAMInd[children[i]->memMapIndex];
    	}
        BRAMUtilization[BRAMId] = BRAMUtilization[BRAMId] + 1;
    }

    //checking if for any BRAM we are using more ports than what we have
    bool usingMorePorts = false;
    for(int i=0;i<BRAMCount;i++){
        if(BRAMUtilization[i]>portCount){
            usingMorePorts = true;
            break;
        }
    }

    //Getting a list of other possible Nodes to store the child
    if(usingMorePorts == true){
        for(int i=0;i<BRAMCount;i++){
            if(BRAMUtilization[i] < portCount){
                possibleBRAMIds.push_back(i);
            }
        }
    }

    return usingMorePorts;
}

bool checkWrNodeMatch(Node *wrNode, vector<int> possibleBRAMIds){
    for(int i=0;i<possibleBRAMIds.size();i++){
        if(wrNode->wrBRAMId == possibleBRAMIds[i]){
            return true;
        }
    }

    return false;
}

int checkIfWrAlreadyExists(Node *someNode,vector<int> possibleBRAMIds){
    for(int i=0;i<someNode->parents.size();i++){
        if(someNode->parents[i]->op == "wr"){
            if(checkWrNodeMatch(someNode->parents[i],possibleBRAMIds) == true){
                return i;
            }
        }
    }

    return -1;
}

int getAppropriateBRAMId(vector<int> possibleBRAMIds, vector<int> numAssigned){
    int minIndex = 0;
    for(int i=1;i<possibleBRAMIds.size();i++){
        if(numAssigned[possibleBRAMIds[i]]<numAssigned[possibleBRAMIds[minIndex]]){
            minIndex = i;
        }
    }
    return possibleBRAMIds[minIndex];
}

Node *genreateWrNode(int BRAMId, int BRAMAddr,Node *childNode, Node *parentNode,Graph &lGraph){
    Node tmpNode,*nodePtrSub;
    tmpNode.name = "wr_" + to_string(BRAMId) + "_" + childNode->name;
    nodePtrSub = lGraph.insertNode(tmpNode);

    nodePtrSub->op = "wr";

    nodePtrSub->delay = opDelay["wr"];
    nodePtrSub->priority = childNode->priority;

    //Find the max nodeId present in lGraph
    int maxNodeId = -1;
    for(auto x:lGraph.nodes){
        if(x.second.nodeId>maxNodeId){
            maxNodeId = x.second.nodeId;
        }
    }

    nodePtrSub->nodeId = maxNodeId+1;
    nodePtrSub->wrBRAMId = BRAMId;
    nodePtrSub->wrBRAMAddr = BRAMAddr;
    nodePtrSub->children.push_back(childNode);
    nodePtrSub->parents.push_back(parentNode);

    return nodePtrSub;
}

bool addWrNodeDiv(Node *n1,vector<int> possibleBRAMIds, vector<int> &numAssigned,HardwareConfig & hwConfig,Graph &lGraph){
    bool wrFound = false;
    //Since it's a div node, 'wr' node with a possible BRAMId can be placed after either of the two children nodes
    for(int i=0;i<n1->children.size();i++){
        //Check if a 'wr' node with a BRAMId among possibleBRAMIds already exists as a parent to that children. If yes return the index number. Otherwise return -1
        int wrIndex = checkIfWrAlreadyExists(n1->children[i],possibleBRAMIds);

        if(wrIndex != -1){
            //Attach the 'wr' node
            Node *tmpWrNode = n1->children[i]->parents[wrIndex];
            tmpWrNode->parents.push_back(n1);
            //Remove n1 as a parent node from n1->children[i]
            bool tmpFound = false;
            for(int j=0;j<n1->children[i]->parents.size();j++){
                if(n1->children[i]->parents[j]->nodeId == n1->nodeId){
                    n1->children[i]->parents.erase(n1->children[i]->parents.begin()+j);
                    tmpFound = true;
                    break;
                }
            }
            if(tmpFound == false){
                cout << "Error2 in function 'addWrNodeDiv' in file 'Schedule.cpp'" << endl;
            }
            n1->children[i] = tmpWrNode;

            wrFound = true;
            break;
        }
    }

    if(wrFound == false){
        //Create a wr node and attach it to the 1st children. Choose a BRAMId among the 'possibleBRAMIds' which have least utilization
        int tmpBRAMId = getAppropriateBRAMId(possibleBRAMIds,numAssigned);
        if(numAssigned[tmpBRAMId] >= hwConfig.BRAMs[0]->size){
            cout << "Error1 in function 'addWrNodeDiv' in file 'Schedule.cpp'" << endl;
        }

        //Generate a 'wr' node
        //This function generates a 'wr' node and adds it to th the graph
        Node *newWrNode = genreateWrNode(tmpBRAMId,numAssigned[tmpBRAMId],n1->children[0],n1,lGraph);
        numAssigned[tmpBRAMId] = numAssigned[tmpBRAMId] + 1;

        //Remove n1 as a parent node from n1->children[0]
        bool tmpFound = false;
        for(int j=0;j<n1->children[0]->parents.size();j++){
            if(n1->children[0]->parents[j]->nodeId == n1->nodeId){
                n1->children[0]->parents.erase(n1->children[0]->parents.begin()+j);
                tmpFound = true;
                break;
            }
        }
        if(tmpFound == false){
            cout << "Error3 in function 'addWrNodeDiv' in file 'Schedule.cpp'" << endl;
        }
        n1->children[0]->parents.push_back(newWrNode);
        n1->children[0] = newWrNode;

        return true; //Extra node added
    }
    else{
        return false; //Extra node not added
    }
}

int getReplacementPosMACNode(vector<Node *> children,vector<int> wrNodeAttachHistory,int i){
	bool loc[2] = {false,false};
	int nodeAddPosition;
	for(int j=1;j<=2;j++){
		if(children[j]->op == "wr"){
			if(children[j]->wrBRAMId == i){
				nodeAddPosition = j-1;
	            loc[j-1] = true;
	        }
	    }
	    else{
	    	if(children[j]->matPointer->BRAMInd[children[j]->memMapIndex] == i){
	    		nodeAddPosition = j-1;
	            loc[j-1] = true;
	        }
	    }
	}
	//Checking if 'nodeAddPosition' can be 2, i.e. the write node can be added after either of the two children
	//'nodeAddPosition' can be 2 only when wrNodeAttachHistory = 0 for both the index
	if(wrNodeAttachHistory[0] == 0 && wrNodeAttachHistory[1] == 0 && loc[0] == true && loc[1] == true){
		nodeAddPosition = 2;
	}
	return nodeAddPosition;
}

bool checkBRAMContentionMacNode(vector<Node *> children,HardwareConfig & hwConfig, vector<int> &possibleBRAMIds,int &nodeAddPosition,vector<int> wrNodeAttachHistory){
    int BRAMCount = hwConfig.BRAMs.size();
    int portCount = hwConfig.BRAMs[0]->ports;

    vector<int> BRAMUtilization_set1;
    vector<int> BRAMUtilization_set2;

    for(int i=0;i<BRAMCount;i++){
        BRAMUtilization_set1.push_back(0);
        BRAMUtilization_set2.push_back(0);
    }

    //1st set
    for(int i=0;i<children.size()-1;i++){
    	int BRAMId;
        if(children[i]->op == "const"){
            continue;
        }
        if(children[i]->op == "wr"){
        	BRAMId = children[i]->wrBRAMId;
        }
        else{
        	BRAMId = children[i]->matPointer->BRAMInd[children[i]->memMapIndex];
        }
        BRAMUtilization_set1[BRAMId] = BRAMUtilization_set1[BRAMId] + 1;
    }

    //2nd set
    for(int i=1;i<children.size();i++){
    	int BRAMId;
    	if(children[i]->op == "wr"){
    		BRAMId = children[i]->wrBRAMId;
    	}
    	else{
    		BRAMId = children[i]->matPointer->BRAMInd[children[i]->memMapIndex];
    	}
        BRAMUtilization_set2[BRAMId] = BRAMUtilization_set2[BRAMId] + 1;
    }

    bool usingMorePorts = false;
    //checking if for any BRAM we are using more ports than what we have(set 1)
    for(int i=0;i<BRAMCount;i++){
    	if(BRAMUtilization_set1[i]>portCount){
    		usingMorePorts = true;
            //calculating node add position
            nodeAddPosition = getReplacementPosMACNode(children,wrNodeAttachHistory,i);
            break;
        }
    }

    //Getting a list of other possible Nodes to store the child
    if(usingMorePorts == true){
    	for(int i=0;i<BRAMCount;i++){
    		if(BRAMUtilization_set1[i] < portCount && BRAMUtilization_set2[i] < portCount){
    			possibleBRAMIds.push_back(i);
            }
        }
    }

    //checking if for any BRAM we are using more ports than what we have(set 2)
    if(usingMorePorts == false){
        for(int i=0;i<BRAMCount;i++){
            if(BRAMUtilization_set2[i]>portCount){
                usingMorePorts = true;
                //calculating nodeAddPosition
                nodeAddPosition = getReplacementPosMACNode(children,wrNodeAttachHistory,i);
                break;
            }
        }

        //Getting a list of other possible Nodes to store the child
        if(usingMorePorts == true){
            for(int i=0;i<BRAMCount;i++){
                if(BRAMUtilization_set1[i] < portCount && BRAMUtilization_set2[i] < portCount){
                    possibleBRAMIds.push_back(i);
                }
            }
        }

    }

    return usingMorePorts;
}

bool addWrNodeMac(Node *n1,vector<int> possibleBRAMIds, vector<int> &numAssigned,HardwareConfig & hwConfig,Graph &lGraph,int childNo,int nodeAddPosition,vector<int> &wrNodeAttachHistory){
    bool wrFound = false;
    //Since it's a mac node, we need to check 'nodeAddPosition' to know where the 'wr' has to be added
    if(nodeAddPosition == 2){
        for(int i=childNo;i<childNo+2;i++){
            //Check if a 'wr' node with a BRAMId among possibleBRAMIds already exists as a parent to that children. If yes return the index number. Otherwise return -1
            int wrIndex = checkIfWrAlreadyExists(n1->children[i],possibleBRAMIds);

            if(wrIndex != -1){
                //Attach the 'wr' node
                Node *tmpWrNode = n1->children[i]->parents[wrIndex];
                tmpWrNode->parents.push_back(n1);
                //Remove n1 as a parent node from n1->children[i]
                bool tmpFound = false;
                for(int j=0;j<n1->children[i]->parents.size();j++){
                    if(n1->children[i]->parents[j]->nodeId == n1->nodeId){
                        n1->children[i]->parents.erase(n1->children[i]->parents.begin()+j);
                        tmpFound = true;
                        break;
                    }
                }
                if(tmpFound == false){
                    cout << "Error2 in function 'addWrNodeMac' in file 'Schedule.cpp'" << endl;
                }
                n1->children[i] = tmpWrNode;

                wrFound = true;
                wrNodeAttachHistory[i-childNo] = 1;
                break;
            }
        }

        if(wrFound == false){
            //Create a wr node and attach it to the 1st children. Choose a BRAMId among the 'possibleBRAMIds' which have least utilization
            int tmpBRAMId = getAppropriateBRAMId(possibleBRAMIds,numAssigned);
            if(numAssigned[tmpBRAMId] >= hwConfig.BRAMs[0]->size){
                cout << "Error1 in function 'addWrNodeMac' in file 'Schedule.cpp'" << endl;
            }

            //Generate a 'wr' node
            //This function also adds the 'wr' node to the graph
            Node *newWrNode = genreateWrNode(tmpBRAMId,numAssigned[tmpBRAMId],n1->children[childNo+0],n1,lGraph);
            numAssigned[tmpBRAMId] = numAssigned[tmpBRAMId] + 1;

            //Remove n1 as a parent node from n1->children[0]
            bool tmpFound = false;
            for(int j=0;j<n1->children[childNo+0]->parents.size();j++){
                if(n1->children[childNo+0]->parents[j]->nodeId == n1->nodeId){
                    n1->children[childNo+0]->parents.erase(n1->children[childNo+0]->parents.begin()+j);
                    tmpFound = true;
                    break;
                }
            }
            if(tmpFound == false){
                cout << "Error3 in function 'addWrNodeMac' in file 'Schedule.cpp'" << endl;
            }
            n1->children[childNo+0]->parents.push_back(newWrNode);
            n1->children[childNo+0] = newWrNode;

            wrNodeAttachHistory[0] = 1;
            return true; //Extra node added
        }
        else{
            return false; //Extra node not added
        }
    }
    else{
        //Check if a 'wr' node with a BRAMId among possibleBRAMIds already exists as a parent to that children. If yes return the index number. Otherwise return -1
        int wrIndex = checkIfWrAlreadyExists(n1->children[childNo+nodeAddPosition],possibleBRAMIds);

        if(wrIndex != -1){
            //Attach the 'wr' node
            Node *tmpWrNode = n1->children[childNo+nodeAddPosition]->parents[wrIndex];
            tmpWrNode->parents.push_back(n1);
            //Remove n1 as a parent node from n1->children[i]
            bool tmpFound = false;
            for(int j=0;j<n1->children[childNo+nodeAddPosition]->parents.size();j++){
                if(n1->children[childNo+nodeAddPosition]->parents[j]->nodeId == n1->nodeId){
                    n1->children[childNo+nodeAddPosition]->parents.erase(n1->children[childNo+nodeAddPosition]->parents.begin()+j);
                    tmpFound = true;
                    break;
                }
            }
            if(tmpFound == false){
                cout << "Error3 in function 'addWrNodeMac' in file 'Schedule.cpp'" << endl;
            }
            n1->children[childNo+nodeAddPosition] = tmpWrNode;

            wrFound = true;
            wrNodeAttachHistory[nodeAddPosition] = 1;
        }

        if(wrFound == false){
            //Create a wr node and attach it to the 1st children. Choose a BRAMId among the 'possibleBRAMIds' which have least utilization
            int tmpBRAMId = getAppropriateBRAMId(possibleBRAMIds,numAssigned);
            if(numAssigned[tmpBRAMId] >= hwConfig.BRAMs[0]->size){
                //Increase the BRAM size if this error occurs
                cout << "Error4 in function 'addWrNodeMac' in file 'Schedule.cpp'" << endl;
            }

            //Generate a 'wr' node
            //This function also adds the 'wr' node to the graph
            Node *newWrNode = genreateWrNode(tmpBRAMId,numAssigned[tmpBRAMId],n1->children[childNo+nodeAddPosition],n1,lGraph);
            numAssigned[tmpBRAMId] = numAssigned[tmpBRAMId] + 1;

            //Remove n1 as a parent node from n1->children[childNo+nodeAddPosition]
            bool tmpFound = false;
            for(int j=0;j<n1->children[childNo+nodeAddPosition]->parents.size();j++){
                if(n1->children[childNo+nodeAddPosition]->parents[j]->nodeId == n1->nodeId){
                    n1->children[childNo+nodeAddPosition]->parents.erase(n1->children[childNo+nodeAddPosition]->parents.begin()+j);
                    tmpFound = true;
                    break;
                }
            }
            if(tmpFound == false){
                cout << "Error5 in function 'addWrNodeMac' in file 'Schedule.cpp'" << endl;
            }
            n1->children[childNo+nodeAddPosition]->parents.push_back(newWrNode);
            n1->children[childNo+nodeAddPosition] = newWrNode;

            wrNodeAttachHistory[nodeAddPosition] = 1;
            return true; //Extra node added
        }
        else{
            return false; //Extra node not added
        }
    }
}

void addwrNodes(Graph &lGraph, HardwareConfig & hwConfig, vector<int> &numAssigned){
    Node *n1;
    int wrNodeCountDiv = 0;
    int wrNodeCountMac = 0;
    for(auto x : lGraph.nodes){
        n1 = &lGraph.nodes[x.first];
        if(n1->children.size() != 0){//Indicating non leaf node
            if(n1->op == "/"){
                //Gathering the children node required for the operation
                vector<Node *> tmpChildren;
                tmpChildren.push_back(n1->children[0]);
                tmpChildren.push_back(n1->children[1]);
                //Next we have to check if all the operands of div node can be fetched from memory simultaneously
                vector<int> possibleBRAMIds; //If there is contention, this varaible will store what else BRAM id can be used to store the operand
                if(checkBRAMContentionDivNode(tmpChildren,hwConfig,possibleBRAMIds) == true){
                    //Contention detected. Add 'wr' node if necessary.
                    //A 'wr' node will be added only if the child node doesn't have a 'wr' node with that particular BRAMId
                    bool isExtraNodeAdded = addWrNodeDiv(n1,possibleBRAMIds,numAssigned,hwConfig,lGraph);
                    if(isExtraNodeAdded == true){
                        wrNodeCountDiv++;
                    }
                }
            }
            else if(n1->op == "mac_sub"){
                //For mac_sub nodes each node is equivalent to total no. of mac operations in that node
                //For each mac operation, we need to check if extra 'wr' nodes have to be added twice(unlike div nodes)
                //For mac operation like A-BC-DE-FG, 'wr' node will never be added to A
                for(int i=1;i<n1->children.size();i+=2){
                    //This vector keeps a track of between which child node and n1, has the 'wr' node been attached
                    vector<int> wrNodeAttachHistory(2,0);
                    for(int j=0;j<2;j++){
                    	//Gathering the children node required for the operation
                    	vector<Node *> tmpChildren;
                    	tmpChildren.push_back(n1->children[0]);
                    	tmpChildren.push_back(n1->children[i]);
                    	tmpChildren.push_back(n1->children[i+1]);
                    	tmpChildren.push_back(n1);
                        //Next we have to check if all the operands of mac node can be fetched from memory simultaneously
                        vector<int> possibleBRAMIds; //If there is contention, this varaible will store what else BRAM id can be used to store the operand
                        //This variable tells whether the 'wr' node with any of the possibleBRAMIds can be attached to child 0 or child 1 or either of the childs.
                        //0 = child 0 only, 1 = child 1 only, 2 = either child 1 or 2
                        int nodeAddPosition;
                        //wrNodeAttachHistory has to be passed so that we don't attach 'wr' node between the same child node and n1 more than once
                        if(checkBRAMContentionMacNode(tmpChildren,hwConfig,possibleBRAMIds,nodeAddPosition,wrNodeAttachHistory) == true){
                            bool isExtraNodeAdded = addWrNodeMac(n1,possibleBRAMIds,numAssigned,hwConfig,lGraph,i,nodeAddPosition,wrNodeAttachHistory);
                            if(isExtraNodeAdded == true){
                                wrNodeCountMac++;
                            }
                        }
                    }
                }
            }
        }
    }

    cout << "\n" << endl;
    cout << "*****************************************************" << "\n";
    cout << "wr Nodes added before Div operands = " << wrNodeCountDiv << endl;
    cout << "wr Nodes added before Mac operands = " << wrNodeCountMac << endl;
    cout << "Totla wr nodes added = " << wrNodeCountDiv + wrNodeCountMac << endl;
    cout << "*****************************************************" << "\n";
}


void assignScatteredAddresses(Graph &lGraph, CCS & A, CCS & L, CCS & U, HardwareConfig & hwConfig)
{
    int requiredMemoryDepth, availableMemoryDepth = 0, currBRAM = 0;
    int i, j, k;
    vector<int> BRAMDepths(hwConfig.BRAMs.size());
    vector<int> numAssigned(hwConfig.BRAMs.size(), 0);//This variable is used to keep a track of how much of the BRAMs have been assigned
    vector<int>::iterator entryIndex;
    int tmp_row,tmp_col;

    CS csL, csA;

    // nnz(L) + nnz(U) - diagonal entries of L; Lxx = 1 known
    requiredMemoryDepth = L.rowInd.size() + U.rowInd.size() - L.numCols; //The diagonal elements of L are always 1. Hence they need not be stored.
    for(i = 0; i < BRAMDepths.size(); i++) //BRAMDepths.size() = 4 as 4 BRAMS have been used
    {
        BRAMDepths[i] = hwConfig.BRAMs[i]->size; //Filling vaule of 2048(whatever is the max depth)
        availableMemoryDepth += BRAMDepths[i];
    }

    if(availableMemoryDepth < requiredMemoryDepth)
    {
        cout << "🚧 LIMIT : Insufficient memory space" << endl <<
            "Requires at least " << requiredMemoryDepth << " memory units" << endl;
        exit(1);
    }



    for(i = 0; i < L.numCols; i++)
    {

       A.getSparseColumn(i, csA);

       // scatter U elements
       // ------------------
        U.getSparseColumn(i, csL);

        for(j = 0; j < csL.index.size(); j++)
        {
            // find free memory location
            while( numAssigned[currBRAM] >= BRAMDepths[currBRAM])
                currBRAM = (currBRAM == hwConfig.BRAMs.size() - 1) ? 0 : currBRAM + 1;

            // Assign L element
            U.BRAMInd[csL.pointer[j]] = currBRAM;
            U.BRAMAddr[csL.pointer[j]] = numAssigned[currBRAM] ++;
            currBRAM = (currBRAM == hwConfig.BRAMs.size() - 1) ? 0 : currBRAM + 1;

            //The task accompanied by next few lines is that, Axy will have the same location in memory as Uxy
            //This applies for elements of A on and above the diagonal
            // assign A element if exists
            entryIndex = std::lower_bound(csA.index.begin(), csA.index.end(), csL.index[j]);
            if(entryIndex != csA.index.end())
            {
                // element exits and assign memory location
                k = std::distance(csA.index.begin(), entryIndex);
                A.BRAMInd[csA.pointer[k]] = U.BRAMInd[csL.pointer[j]];
                A.BRAMAddr[csA.pointer[k]] = U.BRAMAddr[csL.pointer[j]];
            }
        }

        // scatter L elements
        // ------------------
        L.getSparseColumn(i, csL);

        for(j = 1; j < csL.index.size() ; j++) // dont assign memory for Lxx(diagonal elements)
        {
            // find free memory location
            while( numAssigned[currBRAM] >= BRAMDepths[currBRAM])//If the current BRAM has reached its limit, proceed to the next one.
                currBRAM = (currBRAM == hwConfig.BRAMs.size() -1 ) ? 0 : currBRAM + 1;

            // Assign L element
            L.BRAMInd[csL.pointer[j]] = currBRAM;//
            L.BRAMAddr[csL.pointer[j]] = numAssigned[currBRAM] ++;
            currBRAM = (currBRAM == hwConfig.BRAMs.size() - 1) ? 0 : currBRAM + 1;

            //The task accompanied by next few lines is that, Axy will have the same location in memory as Lxy
            //This applies for elements of A below the diagonal
            // assign A element if exists
            entryIndex = std::lower_bound(csA.index.begin(), csA.index.end(), csL.index[j]);
            if(entryIndex != csA.index.end())
            {
                // element exits and assign memory location
                k = std::distance(csA.index.begin(), entryIndex);
                A.BRAMInd[csA.pointer[k]] = L.BRAMInd[csL.pointer[j]];
                A.BRAMAddr[csA.pointer[k]] = L.BRAMAddr[csL.pointer[j]];
            }
        }

        //These are diagonal elements of L wich are always 1 and hence need not be stored in memory.
        L.BRAMInd[csL.pointer[0]] = BRAMIndConst; //BRAMIndConst is declared in stdafx.h
        L.BRAMAddr[csL.pointer[0]] = BRAMAddrConst1; //BRAMAddrConst1 is declared in stdafx.h

    }


    //The next function will add 'wr' nodes between two arithmetic unit nodes. 'wr' nodes will be added only when it's found that it's not possible to fetch all the operands in for a particular operation at the same time. This happens due to lack of available ports.
    //In our case, we may have to add 'wr' nodes only if we use single port or dual port BRAMs. This is because a div node requires max 2 simultaneous operand fetch and mac node requires max 3 simultaneous operand fetch.
    addwrNodes(lGraph,hwConfig,numAssigned);
}


// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// Print Schedular Window
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------


void printAUWindow(const vector<vector<AU_Operation>> AUData, const int startIndex)
{
    int i, j;
    i = startIndex;
    do
    {
        debugFile << "--------------------------------------------------------------------------------------" << endl;
        debugFile << "0️⃣ Line " << i << " Window Size " << AUData.size() << endl;
        // print AU index
        debugFile << endl << setw(10) << "AU Index" << " | ";
        for(j = 0; j < AUData[i].size(); j++)
        {
            debugFile << setw(15) << AUData[i][j].AUIndex <<" | ";
        }

        //Print node name
        debugFile << endl << setw(10) << "Node Name" << " | ";
        for(j = 0; j < AUData[i].size(); j++)
        {
            debugFile << setw(15) << AUData[i][j].node_name<< " | ";
        }

        // Print OP and Node ID
        debugFile << endl << setw(10) << "OP : Id" << " | ";
        for(j = 0; j < AUData[i].size(); j++)
        {
            debugFile << setw(15) << AUData[i][j].op + " : " + to_string(AUData[i][j].outputId) << " | ";
        }
        // Input Ids
        debugFile << endl << setw(10) << "In Id" << " | ";
        for(j = 0; j < AUData[i].size(); j++)
        {
            debugFile << setw(15) << vecToString(AUData[i][j].inputIds) << " | ";
        }
        // Input Loc
        debugFile << endl << setw(10) << "In Loc" << " | ";
        for(j = 0; j < AUData[i].size(); j++)
        {
            debugFile << setw(15) << vecToString(AUData[i][j].inputLocs) << " | ";
        }
        // Input Loc
        debugFile << endl << setw(10) << "BRAM Index" << " | ";
        for(j = 0; j < AUData[i].size(); j++)
        {
            debugFile << setw(15) << AUData[i][j].BRAMIndex << " | ";
        }
        // Retire Clock
        debugFile << endl << setw(10) << "Retire At" << " | ";
        for(j = 0; j < AUData[i].size(); j++)
        {
            debugFile << setw(15) << AUData[i][j].retireClock << " | ";
        }
        debugFile << endl;
        // update line index
        i++;
        i = (i == AUData.size()) ? 0 : i ;
    }while(i != startIndex);
    debugFile << endl;
}

void printMemWindow(const vector<vector<BRAM_Operation>> memData, const int startIndex)
{
        int i, j;
    i = startIndex;
    do
    {
        debugFile << "--------------------------------------------------------------------------------------" << endl;
        debugFile << "0️⃣ Line " << i << endl;
        // print BRAM index
        debugFile << endl << setw(10) << "BRAM Index" << " | ";
        for(j = 0; j < memData[i].size(); j++)
        {
            debugFile << setw(15) << memData[i][j].BRAMIndex << " | ";
        }

        //Print node name
        debugFile << endl << setw(10) << "Node Name" << " | ";
        for(j = 0; j < memData[i].size(); j++)
        {
            debugFile << setw(15) << memData[i][j].node_name<< " | ";
        }

        //Printing read or write or NO_OP clearly
        debugFile << endl << setw(10) << "Read/Write" << " | ";
        for(j = 0; j < memData[i].size(); j++)
        {
            string temp_s;
            if(memData[i][j].op == 0)
               temp_s = "Read";
            else if(memData[i][j].op == 1)
               temp_s = "Write";
            else
               temp_s = "NO_OP";
            debugFile << setw(15) << temp_s<< " | ";
        }

        // Print OP and Node ID
        debugFile << endl << setw(10) << "OP : Id" << " | ";
        for(j = 0; j < memData[i].size(); j++)
        {
            debugFile << setw(15) << to_string(memData[i][j].op) + " : " + to_string(memData[i][j].nodeId) << " | ";
        }
        // Port Index
        debugFile << endl << setw(10) << "Port Id" << " | ";
        for(j = 0; j < memData[i].size(); j++)
        {
            debugFile << setw(15) << memData[i][j].portIndex << " | ";
        }
        // Addresses
        debugFile << endl << setw(10) << "Addr" << " | ";
        for(j = 0; j < memData[i].size(); j++)
        {
            debugFile << setw(15) << memData[i][j].addr << " | ";
        }
        // Din Loc
        debugFile << endl << setw(10) << "Din Loc" << " | ";
        for(j = 0; j < memData[i].size(); j++)
        {
            debugFile << setw(15) << memData[i][j].dinLoc << " | ";
        }
        debugFile << endl;
        // update line index
        i++;
        i = (i == memData.size()) ? 0 : i ;
    }while(i != startIndex);
    debugFile << endl;
}


void printReadableSchedule(const struct Schedule sch)
{
    debugFile << "----------------------------------------------------------" << endl;
    debugFile << "🤯 🤯 🤯 🤯 🤯 🤯 Arithmetic Unit Schedule 🤯 🤯 🤯 🤯 🤯 🤯" << endl;
    debugFile << "----------------------------------------------------------" << endl;
    printAUWindow(sch.AUSchedule, 0);

    debugFile << "----------------------------------------------------------" << endl;
    debugFile << "🤯 🤯 🤯 🤯 🤯 🤯 Memory Unit Schedule 🤯 🤯 🤯 🤯 🤯 🤯" << endl;
    debugFile << "----------------------------------------------------------" << endl;
    printMemWindow(sch.memSchedule, 0);

}

void convertScheduleToInstructionStream(const struct HardwareConfig hwConfig, const struct Schedule sch, vector<string> &instruction_list)
{
    ofstream insFile;

    //4 MAC units, each MAC unit has 3 muxes and each MUX has 5 select pins
    //cout<<"File schedule.cpp, function convertScheduleToInstructionStream\n";
    int macSelInsWidth = hwConfig.AUMuxSelWidth * 3 * hwConfig.numMACUnits;
    //cout<<"hwConfig.AUMuxSelWidth = "<< hwConfig.AUMuxSelWidth<<", hwConfig.numMACUnits = "<<hwConfig.numMACUnits<<"\n";
    //cout << "macSelInsWidth = "<<macSelInsWidth<<"\n\n\n";

    //4 DIV units, each DIV unit has 2 muxes and each MUX has 5 select pins
    int divSelInsWidth = hwConfig.AUMuxSelWidth * 2 * (hwConfig.AUs.size() - hwConfig.numMACUnits);
    //cout<<"hwConfig.AUMuxSelWidth = "<< hwConfig.AUMuxSelWidth<<", (hwConfig.AUs.size() - hwConfig.numMACUnits) = "<<hwConfig.AUs.size() - hwConfig.numMACUnits<<"\n";
    //cout << "divSelInsWidth = "<<divSelInsWidth<<"\n\n\n";

    //There are 4 BRAMS, each BRAM has 4 ports, each port has a mux with 4 select pins
    int bramSelInslWidth = hwConfig.BRAMMuxSelWidth * hwConfig.BRAMs[0]->ports * hwConfig.BRAMs.size();
    //cout<<"hwConfig.BRAMMuxSelWidth = "<< hwConfig.BRAMMuxSelWidth<<", hwConfig.BRAMs[0]->ports = "<<hwConfig.BRAMs[0]->ports<<", hwConfig.BRAMs.size() = "<<hwConfig.BRAMs.size()<<"\n";
    //cout << "bramSelInslWidth = "<<bramSelInslWidth<<"\n\n\n";

    //There are 4 BRAMS, each BRAM has 4 ports, each port has a mux with 4 select pins
    //+1 is for write enable bit.
    int bramAddrInsWidth = (hwConfig.BRAMAddressWidth + 1) * hwConfig.BRAMs[0]->ports * hwConfig.BRAMs.size();
    //cout<<"(hwConfig.BRAMAddressWidth + 1) = "<< (hwConfig.BRAMAddressWidth + 1)<<", hwConfig.BRAMs[0]->ports = "<<hwConfig.BRAMs[0]->ports<<", hwConfig.BRAMs.size() = "<<hwConfig.BRAMs.size()<<"\n";
    //cout << "bramAddrInsWidth = "<<bramAddrInsWidth<<"\n\n\n";


    //The additional +1 is for complete signal. The last bit of each instruction is control bit. It will become 1 in the last instruction.
    int insWidth = macSelInsWidth + divSelInsWidth + bramSelInslWidth + bramAddrInsWidth + 1;

    string currIns(insWidth,'0');

    int cycle  = 0;
    int startLoc, endLoc, portLoc, offset;
    int numBRAMPorts = hwConfig.BRAMs[0]->ports;
    int macInLoc;

    //cout<<"sch.AUSchedule.size() = "<<sch.AUSchedule.size()<<"\n";
    //cout<<"sch.memSchedule.size() = "<<sch.memSchedule.size()<<"\n";
    for(cycle = 0; cycle < sch.AUSchedule.size(); cycle++)
    {
        currIns.assign(insWidth, '0');

        //First writing the select pins of the BRAMS in 'currIns'
        offset = bramAddrInsWidth + macSelInsWidth + divSelInsWidth;
        for(auto memOp : sch.memSchedule[cycle])
        {
            portLoc = memOp.BRAMIndex * numBRAMPorts + memOp.portIndex;
            startLoc = portLoc * (hwConfig.BRAMAddressWidth + 1);
            endLoc = startLoc + hwConfig.BRAMAddressWidth - 1;
            currIns.replace(startLoc, hwConfig.BRAMAddressWidth, bitset<ADDR_BITSET_WIDTH>(memOp.addr).to_string().substr(ADDR_BITSET_WIDTH - hwConfig.BRAMAddressWidth));
            currIns[endLoc + 1] = (memOp.op == 1) ? '1' : '0' ;
            // write operation -> assign read location
            if(memOp.op == BRAM_WRITE)
            {
                // debugFile << "location: " << memOp.dinLoc << " conv: " << bitset<SEL_BITSET_WIDTH>(memOp.dinLoc).to_string().substr(SEL_BITSET_WIDTH - hwConfig.BRAMMuxSelWidth) << endl;
                startLoc = offset + (memOp.BRAMIndex * numBRAMPorts + memOp.portIndex) * hwConfig.BRAMMuxSelWidth;
                // debugFile << "start location: " << startLoc << " offset: " << offset << endl;
                currIns.replace(startLoc, hwConfig.BRAMMuxSelWidth, bitset<SEL_BITSET_WIDTH>(memOp.dinLoc).to_string().substr(SEL_BITSET_WIDTH - hwConfig.BRAMMuxSelWidth));
            }
        }

        for( auto auOp : sch.AUSchedule[cycle])
        {
            offset = bramAddrInsWidth;
            if(auOp.AUIndex >= hwConfig.numMACUnits)
            {
                startLoc = offset + macSelInsWidth + (auOp.AUIndex - hwConfig.numMACUnits) * 2 * hwConfig.AUMuxSelWidth;
                for(auto inputLoc : auOp.inputLocs)
                {
                    currIns.replace(startLoc, hwConfig.AUMuxSelWidth, bitset<SEL_BITSET_WIDTH>(inputLoc).to_string().substr(SEL_BITSET_WIDTH - hwConfig.AUMuxSelWidth));
                    startLoc += hwConfig.AUMuxSelWidth;
                }
            }
            else
            {
                startLoc = offset + auOp.AUIndex * 3 * hwConfig.AUMuxSelWidth;
                macInLoc = auOp.inputLocs[1];
                currIns.replace(startLoc, hwConfig.AUMuxSelWidth, bitset<SEL_BITSET_WIDTH>(macInLoc).to_string().substr(SEL_BITSET_WIDTH - hwConfig.AUMuxSelWidth));
                startLoc += hwConfig.AUMuxSelWidth;
                macInLoc = auOp.inputLocs[2];
                currIns.replace(startLoc, hwConfig.AUMuxSelWidth, bitset<SEL_BITSET_WIDTH>(macInLoc).to_string().substr(SEL_BITSET_WIDTH - hwConfig.AUMuxSelWidth));
                startLoc += hwConfig.AUMuxSelWidth;
                macInLoc = auOp.inputLocs[0];
                currIns.replace(startLoc, hwConfig.AUMuxSelWidth, bitset<SEL_BITSET_WIDTH>(macInLoc).to_string().substr(SEL_BITSET_WIDTH - hwConfig.AUMuxSelWidth));
            }

        }

        currIns[insWidth - 1] = '0';
        instruction_list.push_back(currIns);

        #ifdef PRINT_DEBUG_1
        debugFile << "Instruction Cycle " << cycle << endl << currIns << endl;
        #endif
    }

    //The last instruction indicating completion
    currIns.assign(insWidth, '0');
    currIns[insWidth - 1] = '1';
    instruction_list.push_back(currIns);

}

/*********************************************************************************************************************************************************************/
int current_cycle = -1; //Making the cycle counter globlal

//This function checks if the scheduling is complete by checking the readyBit status of the required nodes.
bool schedulingStatusCheck(Graph & lGraph){
    Node tmpNode;
    bool completed = true;
    int count = 0;

    for(auto x : lGraph.nodes){
        tmpNode = x.second;
        if(tmpNode.readyBit == false && tmpNode.name.substr(0,8) != "mac_subL"){
            count++;
            completed = false;
        }
    }
    //cout << "Nodes remaining  = " << count << ", cycle = "<< current_cycle << endl;
    return completed;
}

//This function is used to get the latencies of the operations
vector<int> getAULatency(vector<string> operations,HardwareConfig & hwConfig){
    int latenciesFound = 0;
    vector<int> latencies;

    //filling the 'latencies' vector with garbage i.e. -1
    for(int i=0;i<operations.size();i++){
        latencies.push_back(-1);
    }

    for(int i=0;i<operations.size();i++){
        for(int j=0;j<hwConfig.AUs.size();j++){
            if(operations[i] == hwConfig.AUs[j]->operation){
                latencies[i] = hwConfig.AUs[j]->pipeLatency;
                break;
            }
        }
    }

    return latencies;
}

//This function decreases the integer stored inn all the vectors by 1
void decreaseCyclesLeft(vector<int> &execution_list_cycles_left, vector<int> &mem_read_list_cycles_left, vector<int> &mem_write_list_cycles_left,vector<int> &schedulable_list_cycles_left){
    for(int i=0; i < execution_list_cycles_left.size(); i++){
        execution_list_cycles_left[i] = execution_list_cycles_left[i] - 1;
    }
    for(int i=0; i < mem_read_list_cycles_left.size(); i++){
        mem_read_list_cycles_left[i] = mem_read_list_cycles_left[i] - 1;
    }
    for(int i=0; i < mem_write_list_cycles_left.size(); i++){
        mem_write_list_cycles_left[i] = mem_write_list_cycles_left[i] - 1;
    }
    for(int i=0; i < schedulable_list_cycles_left.size();i++){
        if(schedulable_list_cycles_left[i] != -1){
            schedulable_list_cycles_left[i] = schedulable_list_cycles_left[i] - 1;
        }
        else if(schedulable_list_cycles_left[i] == 0){
            //cout << "Error in function 'decreaseCyclesLeft' in the file 'Schedule.cpp'" << endl;
        }
    }
}

void update_readyBit_ready_list(vector<Node *> &mem_write_list,vector<int> &mem_write_list_cycles_left,vector<int> &BRAM_Ids_mem_write,vector<Node *> &ready_list){

     for(int i=0;i<mem_write_list.size();i++){
         if(mem_write_list_cycles_left[i] == 0){
             //In the nodes with op='mac_sub', first update 'latestIntermediateResultAvailable' to 1
             //Then check if all elements of 'nodeEvalStatus' = 1. If yes, then update the 'readyBit' of that mac node to  1
             if(mem_write_list[i]->op == "mac_sub"){
                 mem_write_list[i]->latestIntermediateResultAvailable = 1;

                 mem_write_list[i]->readyBit = true;//initially setting to true
                 for(int j=0; j<mem_write_list[i]->nodeEvalStatus.size(); j++){
                     if(mem_write_list[i]->nodeEvalStatus[j] == 0){//on detecting even a single 0 set readyBit to false
                         mem_write_list[i]->readyBit = false;
                         break;
                     }
                 }
             }
             else{
                 mem_write_list[i]->latestIntermediateResultAvailable = 1;
                 mem_write_list[i]->readyBit = true;
             }


             //Pusing the node into ready_list if it has no parent i.e. it's not  a root node
             //Note that if it's a mac node and incomplete, then still it would be pushed to ready_list irrespective of whether it has parents or not
             if(mem_write_list[i]->readyBit == true){
                 if(mem_write_list[i]->parents.size()!=0){
                    ready_list.push_back(mem_write_list[i]);
                }
             }
             else{//For incomplete mac nodes
                 ready_list.push_back(mem_write_list[i]);
             }

         }
     }

     //Removing those nodes from 'mem_write_list' which have completed write operation
     for(int i=0;i<mem_write_list.size();i++){
         if(mem_write_list_cycles_left[i] == 0){
             mem_write_list.erase(mem_write_list.begin()+i);
             mem_write_list_cycles_left.erase(mem_write_list_cycles_left.begin()+i);
             BRAM_Ids_mem_write.erase(BRAM_Ids_mem_write.begin()+i);
             i--;//This is important, as everytime an element from a vector is removed, its size reduces by 1
         }
     }

}

bool checkIfNodeInList(vector<Node *> &someList, int node_id){
    for(int i=0; i<someList.size();i++){
        if(someList[i]->nodeId == node_id){
            return true;
        }
    }
    return false;
}

//used exclusively while checking if a node is there in mem_read_list
bool checkIfNodeInList_withLatency(vector<Node *> someList,vector<int> someList_cycles_left,int node_id,int latency){
    for(int i=0; i<someList.size();i++){
        if(someList[i]->nodeId == node_id && someList_cycles_left[i] == latency){
            return true;
        }
    }
    return false;
}

int findNodeIndex(vector<Node *> some_list,int node_id){
    int index = -1;
    for(int i=0;i<some_list.size();i++){
        if(some_list[i]->nodeId == node_id){
            index = i;
            break;
        }
    }
    return index;
}

//This function inserts a node to a list such that priority of nodes in the list are in ascending order
//This function also returns the position at which the node is inserted
int listPriorityInsert(vector<Node *> &someList, Node *someNode){
    int i;
    for(i=0;i<someList.size();i++){
        if(someList[i]->priority > someNode->priority){
            break;
        }
    }

    someList.insert(someList.begin()+i,someNode);
    return i;
}

//This function will check if execution of node in live_list is complete. Especially used for "mac_sub" nodes, as a single "mac_sub" node has many mac operations
//Before calling this function we need to make sure that this node is actually a part of live_list.
bool checkIfExecutionComplete_live_list(Node *some_node){
    if(some_node->op == "mac_sub"){
        for(int i=0;i<some_node->nodeEvalStatus.size();i++){
            if(some_node->nodeEvalStatus[i] == 0){
                return false;
            }
        }
        return true;
    }
    else{
        return true;
    }

}

void update_schedule_list(vector<Node *> &schedulable_list,vector<int> &schedulable_list_cycles_left, vector<Node *> &ready_list){
    Node *tmpParent;
    int insert_index;

    for(int i=0;i<ready_list.size();i++){
        if(ready_list[i]->readyBit == true){
            //Iterate through all the parents linked to that node
            for(int j=0;j<ready_list[i]->parents.size();j++){
                tmpParent = ready_list[i]->parents[j];

                //First check if tmpParent is already in schedulable_list
                if(checkIfNodeInList(schedulable_list,tmpParent->nodeId) == true){
                    continue; //skip to next iteration of the for loop
                }

                //Then check if tmpParent is already in execution or finished execution. This can happen if tmpParent has been put in execution queue due to forwarding but we still need to save its children in memory.
                if(tmpParent->latestIntermediateResultAvailable == 0 || tmpParent->readyBit == true){
                    continue;
                }

                if(tmpParent->op == "mac_sub"){
                    //Suppose tmpParent is performing the operation A-BC-DE. If A is the ready_list[i] node(it implicitely indicates latestIntermediateResultAvailable == -1), then we need to chek if B and C are ready or D and E are ready
                    //If B is the ready_list[i] node, then we need to check first if tmpParent mac node has ever been evaluated(if latestIntermediateResultAvailable = -1 that means it has never been evaluated).If never been evaluated check if A and C are ready.
                    //If latestIntermediateResultAvailable = 0, that means the node is currently evaluating. No need to check any further. Don't push the node in schedulable_list.
                    //If latestIntermediateResultAvailable = 1, and B is the ready_list[i] node, then check only if C node is ready.

                    if(tmpParent->latestIntermediateResultAvailable == -1){//Indicating that the mac node has never been evaluated
                        //Checking if A is ready_list[i]
                        if(tmpParent->children[0]->nodeId == ready_list[i]->nodeId){
                            //Checking if any of the mul pairs is ready
                            for(int k = 1; k<tmpParent->children.size();k+=2){
                                if(tmpParent->children[k]->readyBit == true && tmpParent->children[k+1]->readyBit == true){
                                    //Push tmpParent in schedulable list
                                    int tmpIndex;
                                    tmpIndex = listPriorityInsert(schedulable_list,tmpParent);
                                    schedulable_list_cycles_left.insert(schedulable_list_cycles_left.begin()+tmpIndex,-1);
                                    break;
                                }
                            }
                        }
                        else{//Checking if the other operand in mul pair is ready and if A is ready
                            //First checking if A is ready, only then proceeding to check if the other operand in mul pair is ready
                            if(tmpParent->children[0]->readyBit == true){
                                //Checking if the other operand in mul pair is ready
                                for(int k = 1; k<tmpParent->children.size();k++){
                                    if(tmpParent->children[k]->nodeId == ready_list[i]->nodeId){
                                        if(k%2==1){//indicating ready_list[i] is the 1st operand in mul pair
                                            //Checking if the second operand is ready
                                            if(tmpParent->children[k+1]->readyBit == true){
                                                //Push tmpParent in schedulable list
                                                int tmpIndex;
                                                tmpIndex = listPriorityInsert(schedulable_list,tmpParent);
                                                schedulable_list_cycles_left.insert(schedulable_list_cycles_left.begin()+tmpIndex,-1);
                                            }
                                        }
                                        else{ //indicating ready_list[i] is the 2nd operand in mul pair
                                            //Check if the 1st operand is ready
                                            if(tmpParent->children[k-1]->readyBit == true){
                                                //Push tmpParent in schedulable list
                                                int tmpIndex;
                                                tmpIndex = listPriorityInsert(schedulable_list,tmpParent);
                                                schedulable_list_cycles_left.insert(schedulable_list_cycles_left.begin()+tmpIndex,-1);
                                            }
                                        }
                                        break;
                                    }
                                }
                            }
                        }
                    }
                    else if(tmpParent->latestIntermediateResultAvailable == 1){//Indicates that part of tmpParent mac node has already been evaluated earlier
                        //Checking if the other operand in mul pair is ready
                        for(int k = 1; k<tmpParent->children.size();k++){
                            if(tmpParent->children[k]->nodeId == ready_list[i]->nodeId){
                                if(k%2==1){//indicating ready_list[i] is the 1st operand in mul pair
                                    //Checking if the second operand is ready
                                    if(tmpParent->children[k+1]->readyBit == true){
                                        //Push tmpParent in schedulable list
                                        int tmpIndex;
                                        tmpIndex = listPriorityInsert(schedulable_list,tmpParent);
                                        schedulable_list_cycles_left.insert(schedulable_list_cycles_left.begin()+tmpIndex,-1);
                                    }
                                    break;
                                }
                                else{ //indicating ready_list[i] is the 2nd operand in mul pair
                                    //Check if the 1st operand is ready
                                    if(tmpParent->children[k-1]->readyBit == true){
                                        //Push tmpParent in schedulable list
                                        int tmpIndex;
                                        tmpIndex = listPriorityInsert(schedulable_list,tmpParent);
                                        schedulable_list_cycles_left.insert(schedulable_list_cycles_left.begin()+tmpIndex,-1);
                                    }
                                    break;
                                }
                            }
                        }
                    }
                }
                else if(tmpParent->op == "/"){//else part corresponds to '/' node
                    //Suppose tmpParent is performing the operation A/B. If A is the ready_list[i] node, then we need to check if B is ready. If B is the ready_list[i] node, then we need to check if A is ready.
                    for(int k =0; k<tmpParent->children.size();k++){
                        if(tmpParent->children[k]->nodeId != ready_list[i]->nodeId && tmpParent->children[k]->readyBit == true){
                            //Push the tmpParent in schedulable list
                            int tmpIndex;
                            tmpIndex = listPriorityInsert(schedulable_list,tmpParent);
                            schedulable_list_cycles_left.insert(schedulable_list_cycles_left.begin()+tmpIndex,-1);
                            break;
                        }
                    }
                }
                else if(tmpParent->op == "wr"){
                    //Puch the node in 'schedulable_list'
                    int tmpIndex;
                    tmpIndex = listPriorityInsert(schedulable_list,tmpParent);
                    schedulable_list_cycles_left.insert(schedulable_list_cycles_left.begin()+tmpIndex,-1);
                }
                else{
                    cout << "ERROR in function 'update_schedule_list' in function 'Schedule.cpp'" << endl;
                }
            }
        }
        else if(ready_list[i]->readyBit == false){
            //If ready bit is false and a node is still in ready_list, it indicates that its a mac node which is partially evaluated
            //Hence we need to check if the other operand of mul pair is ready or not
            //If the node ready_list[i] is partially evaluated, then what goes in schedulable_list is ready_list[i] itself

            //First we need to check if ready_list[i] itself is present in the schedulable_list(it's just a failsafe. If the scheduler code is working properly, it's impossible that ready_list[i] is already there in the schedulable_list)
            if(checkIfNodeInList(schedulable_list,ready_list[i]->nodeId) == true){
                continue; //skip to next iteration of the for loop
            }

            //Iterating through all the children except the 1st children because the 1st one is A(in A-BC-DE....)
            for(int k=1;k<ready_list[i]->children.size();k+=2){
                if(ready_list[i]->children[k]->readyBit == true && ready_list[i]->children[k+1]->readyBit == true  && ready_list[i]->nodeEvalStatus[k/2] == 0){
                    //Push the tmpParent in schedulable list
                    int tmpIndex;
                    tmpIndex = listPriorityInsert(schedulable_list,ready_list[i]);
                    schedulable_list_cycles_left.insert(schedulable_list_cycles_left.begin()+tmpIndex,-1);
                    break;
                }
            }
        }
    }

    //Clear ready_list
    ready_list.clear();
}

//The purpose of this function is to find appropriate children from the list 'live_list' so that 'some_node' can be scheduled.
bool findChildren_live_list(vector<Node *> live_list, Node *some_node,vector<Node *> &correspondingChildren){

    if(some_node->op == "mac_sub"){
        if(some_node->latestIntermediateResultAvailable == -1){//Indicating that the mac node has never been evaluated
            //First checking if A is there is live_list(mac operation = A-BC) and it's execution is complete
            if((checkIfNodeInList(live_list,some_node->children[0]->nodeId) == true && checkIfExecutionComplete_live_list(some_node->children[0]) == true)|| some_node->children[0]->op == "const"){//"const" means A = 0
                //Check if any mul pair is there in live_list
                for(int k=1;k<some_node->children.size();k+=2){
                    if(checkIfNodeInList(live_list,some_node->children[k]->nodeId) == true && checkIfExecutionComplete_live_list(some_node->children[k]) == true && checkIfNodeInList(live_list,some_node->children[k+1]->nodeId) == true && checkIfExecutionComplete_live_list(some_node->children[k+1]) == true){
                        correspondingChildren.push_back(some_node->children[0]);
                        correspondingChildren.push_back(some_node->children[k]);
                        correspondingChildren.push_back(some_node->children[k+1]);
                        return true;
                    }
                }
            }
        }
        else{//Indicating that the mac node has been partially evaluated
            //First check if the node itself is present in live_list. The node itself corresponds to A(mac operation = A-BC)
            if(checkIfNodeInList(live_list,some_node->nodeId) == true){
                //Check if any mul pair is there in live_list
                for(int k=1;k<some_node->children.size();k+=2){
                    if(checkIfNodeInList(live_list,some_node->children[k]->nodeId) == true && checkIfExecutionComplete_live_list(some_node->children[k]) == true && checkIfNodeInList(live_list,some_node->children[k+1]->nodeId) == true && checkIfExecutionComplete_live_list(some_node->children[k+1]) == true && some_node->nodeEvalStatus[k/2] == 0){
                        correspondingChildren.push_back(some_node);
                        correspondingChildren.push_back(some_node->children[k]);
                        correspondingChildren.push_back(some_node->children[k+1]);
                        return true;
                    }
                }
            }
        }
    }
    else if(some_node->op == "/"){//else part corresponds to '/' nodes
        //Check if both the operands of '/' node are available in live_list
        if(checkIfNodeInList(live_list,some_node->children[0]->nodeId) == true && checkIfExecutionComplete_live_list(some_node->children[0]) == true && checkIfNodeInList(live_list,some_node->children[1]->nodeId) == true && checkIfExecutionComplete_live_list(some_node->children[1]) == true){
            correspondingChildren.push_back(some_node->children[0]);
            correspondingChildren.push_back(some_node->children[1]);
            return true;
        }
    }
    else if(some_node->op == "wr"){
        if(checkIfNodeInList(live_list,some_node->children[0]->nodeId) == true && checkIfExecutionComplete_live_list(some_node->children[0]) == true){
            correspondingChildren.push_back(some_node->children[0]);
            return true;
        }
    }
    return false;
}

void findExecutableAndWriteBackNodes(vector<Node *> &execution_list,vector<int> &execution_list_cycles_left,vector<Node *> &mem_read_list,vector<int> &mem_read_list_cycles_left,vector<Node *> &newExecutableNodes,vector<vector<Node *>> &correspondingChildren,vector<Node *> &writeBackNodes,int mode,int cyclesLeft){
    //First populate the list of nodes whose results are ready. This can be done by checking those nodes whose cycles_left = 0
    vector<Node *> live_list;

    Node *tmpParent;

    //First ther are common operations for both mode 0 and mode 1
    for(int i=0;i<execution_list.size();i++){
        if(execution_list_cycles_left[i] == cyclesLeft){
            //push the node into live list
            live_list.push_back(execution_list[i]);
        }
    }

    //In mode 1 nodes pushed from 'mem_read_list'  to 'live_list' will always be empty
    for(int i=0;i<mem_read_list.size();i++){
        if(mem_read_list_cycles_left[i] == cyclesLeft){
            //push the node into live list
            live_list.push_back(mem_read_list[i]);
        }
    }

    //First populating the newExecutableNodes vector
    for(int i=0;i<live_list.size();i++){
        //First we need to check if the execution of the node is complete. If the node is '/' or 'rd', then definitely the execution is complete.
        //If the node is 'mac_sub', the execution may be incomplete as some mac operations may still be remaining
        bool executionComplete = checkIfExecutionComplete_live_list(live_list[i]);

        if(executionComplete == true){//We need to check if any of the parents can be scheduled with the nodes available in 'live_list'.
            for(int j=0;j<live_list[i]->parents.size();j++){
                tmpParent = live_list[i]->parents[j];

                //If a parent has already been put in 'newExecutableNodes', no need to check again
                if(checkIfNodeInList(newExecutableNodes,tmpParent->nodeId) == true){
                    continue;//Move no to next iteration
                }

                //Then check if tmpParent is already in execution or finished execution. This can happen if tmpParent has been put in execution queue due to forwarding but we still need to save its children in memory.
                if(tmpParent->latestIntermediateResultAvailable == 0 || tmpParent->readyBit == true){
                    continue;//Move no to next iteration
                }

                //Now checking if the tmpParent node can be pushed to 'newExecutableNodes'
                //It can only be pushed if the children nodes required to schedule 'tmpParent' is there in 'live_list'
                vector<Node *> tmpChildren;
                if(findChildren_live_list(live_list,tmpParent,tmpChildren) == true){
                    int index = listPriorityInsert(newExecutableNodes,tmpParent);
                    correspondingChildren.insert(correspondingChildren.begin()+index,tmpChildren);
                }
            }
        }
        else{//definitely corresponds to "mac_sub" nodes with mac operations still remaining
            //If a live_list[i] has already been put in 'newExecutableNodes', no need to check again
            //Ideally this condition should always return false
            if(checkIfNodeInList(newExecutableNodes,live_list[i]->nodeId) == true){
                continue;//Move no to next iteration
            }
            //Now checking if the live_list[i] node can be pushed to 'newExecutableNodes'
            //It can only be pushed if the children nodes required to schedule 'live_list[i]' is there in 'live_list'
            vector<Node *> tmpChildren;
            if(findChildren_live_list(live_list,live_list[i],tmpChildren) == true){
                int index = listPriorityInsert(newExecutableNodes,live_list[i]);
                correspondingChildren.insert(correspondingChildren.begin()+index,tmpChildren);
            }
        }
    }

    //Next Updating the writeback nodes
    //There are 4 cases when we have to write back the node results back into the BRAM
    //First, if the node is '/'.
    //Second, if the node is 'mac_sub' and it has not completed all the mac operations and it cannot be scheduled in the next cycle
    //Third, if the node is 'mac_sub' and it has completed all the mac operations and it has calculated an element of U matrix(name = U_x_y)
    //Forth, if the node is 'mac_sub' and it has completed all the mac operations and it's name starts with 'mac_subL_x1_y1' and it's parent node which should have the name (L_x1_y1) cannot be scheduled

    for(int i=0;i<live_list.size();i++){
        //First checking if the node has already not been written back to memory
        if(live_list[i]->latestIntermediateResultAvailable == 1){
            continue; //Continue to next iteration of the loop
        }

        //Then checking if the node is not already in the 'writeBackNodes' list
        if(checkIfNodeInList(writeBackNodes,live_list[i]->nodeId) == true){
            continue;
        }

        //All the nodes of type '/' have to be written back to memory
        if(live_list[i]->op == "/"){
            writeBackNodes.push_back(live_list[i]);
        }
        else if(live_list[i]->op == "mac_sub"){
            //Check if live_list[i] belongs to a children of one of the nodes in the list 'newExecutableNodes'. If not save the node.
            //If Yes, then check if the node is done with all the mac operaions and the node calculates an element of U matrix. If both the answers are yes, save the node.
            bool isChildren = false;
            for(int j=0;j<correspondingChildren.size();j++){
                if(checkIfNodeInList(correspondingChildren[j],live_list[i]->nodeId)){
                    isChildren = true;
                    break;
                }
            }
            if(isChildren == false){
                writeBackNodes.push_back(live_list[i]);
            }
            else{
                bool executionComplete = checkIfExecutionComplete_live_list(live_list[i]);

                if(executionComplete == true && live_list[i]->matPointer->name == "U"){
                    writeBackNodes.push_back(live_list[i]);
                }
            }
        }

    }

    //Extra operations need to be done when mode = 1
    if(mode == 1){
        //The goal of mode 1 is to find nodes whose latest values are saved in memory to be added to 'mem_read_nodes' so that after cycles  = memory read latency cycles appropriate values are present at the ouput of BRAMS to schedule new nodes.
        //Extra operations for mode 1 is almost same as mode 0 itself but with some subltle changes
        //The nodes there in 'newExecutableNodes' will be ignored while we try to find new nodes to schedule. We are ignoring because those nodes are already schedulable using nodes that have just finished execution i.e. for scheduling those nodes extra memory read of operands is not required.
        // The 'live_list' will also be calculated very differently. After filling the 'live_list' with elements from 'execution_list', we fill those elements in 'live_list' which are already saved in memory and which along with an additional node from 'live_list' will enable some other node to get scheduled.
        //Mode 1 does not require the veector 'writeBackNodes'

        //re-populating the 'live_list'
        live_list.erase(live_list.begin(),live_list.end());
        for(int i=0;i<execution_list.size();i++){
            if(execution_list_cycles_left[i] == cyclesLeft){
                live_list.push_back(execution_list[i]);
            }
        }

        vector<Node *> tmp_newExecutableNodes;
        vector<vector<Node *>> tmp_correspondingChildren;
        vector<Node *> tmpList;

        //Moving the nodes from 'newExecutableNodes' to 'tmp_newExecutableNodes' and 'correspondingChildren' to 'tmp_correspondingChildren'
        for(int i=0;i<newExecutableNodes.size();i++){
            tmp_newExecutableNodes.push_back(newExecutableNodes[i]);
        }
        newExecutableNodes.erase(newExecutableNodes.begin(),newExecutableNodes.end());

        for(int i=0;i<correspondingChildren.size();i++){
            tmp_correspondingChildren.push_back(correspondingChildren[i]);
        }
        correspondingChildren.erase(correspondingChildren.begin(),correspondingChildren.end());

        //This is one of the part which differs from mode 0
        //Adding relevant nodes in live_list node that are present in memory
        for(int i=0;i<live_list.size();i++){
            //First we need to check if the execution of live_list[i] is complete
            bool exec_complete = true; //initially setting it to true
            if(live_list[i]->op == "mac_sub"){
                for(int j=0;j<live_list[i]->nodeEvalStatus.size();j++){
                    if(live_list[i]->nodeEvalStatus[j] == 0){
                        exec_complete = false;
                        break;
                    }
                }
            }

            if(exec_complete == false){
                //If live_list[i] is already in the list 'tmp_newExecutableNodes', then ignore and move on
                if(checkIfNodeInList(tmp_newExecutableNodes,live_list[i]->nodeId) == true){
                    continue;
                }
                for(int j=1;j<live_list[i]->children.size();j+=2){
                    if(live_list[i]->nodeEvalStatus[j/2]==0){
                        if(checkIfNodeInList(tmpList,live_list[i]->children[j]->nodeId) == false && live_list[i]->children[j]->readyBit == true){
                            tmpList.push_back(live_list[i]->children[j]);
                        }
                        if(checkIfNodeInList(tmpList,live_list[i]->children[j+1]->nodeId) == false && live_list[i]->children[j+1]->readyBit == true){
                            tmpList.push_back(live_list[i]->children[j+1]);
                        }
                    }
                }
            }
            else{
                for(int j=0;j<live_list[i]->parents.size();j++){
                    tmpParent = live_list[i]->parents[j];//The tmpParent node can be a div or mac node or wr

                    //If tmpParent is already in the list 'tmp_newExecutableNodes', then ignore and move on
                    if(checkIfNodeInList(tmp_newExecutableNodes,tmpParent->nodeId) == true){
                        continue;
                    }

                    //Browsing through the children of 'tmpParent' and moving them to a temporary vector 'tmpList' if they are not already in that list and if they are saved in memory ('readyBit' = true)
                    if(tmpParent->op == "mac_sub"){
                        if(checkIfNodeInList(tmpList,tmpParent->children[0]->nodeId) == false && tmpParent->children[0]->readyBit == true and tmpParent->latestIntermediateResultAvailable == -1){
                            tmpList.push_back(tmpParent->children[0]);
                        }
                        for(int k=1;k<tmpParent->children.size();k+=2){
                            if(checkIfNodeInList(tmpList,tmpParent->children[k]->nodeId) == false && tmpParent->children[k]->readyBit == true){
                                tmpList.push_back(tmpParent->children[k]);
                            }
                            if(checkIfNodeInList(tmpList,tmpParent->children[k+1]->nodeId) == false && tmpParent->children[k+1]->readyBit == true){
                                tmpList.push_back(tmpParent->children[k+1]);
                            }
                        }
                    }
                    else{
                        for(int k=0;k<tmpParent->children.size();k++){
                            if(checkIfNodeInList(tmpList,tmpParent->children[k]->nodeId) == false && tmpParent->children[k]->readyBit == true){
                                tmpList.push_back(tmpParent->children[k]);
                            }
                        }
                    }

                }
            }
        }

        //move the nodes from 'tmp_list' to 'live_list'
        for(int i=0;i<tmpList.size();i++){
            live_list.push_back(tmpList[i]);
        }

        //The next logic where I populate 'newExecutableNodes', 'correspondingChildren' and 'writeBackNodes' is similar to mode 0, with the only difference being, the nodes present in list 'tmp_newExecutableNodes' are ignored
        //First updating 'newExecutableNodes' & 'correspondingChildren'
        for(int i=0;i<live_list.size();i++){
            //Skipping the nodes which are already stored in memory
            //This is done because, oherwise there is a possibility that a node is scheduled whose all the operands have to be read from memory.
            //After the below 'if' condition is specified, it's certain that at least one node in the 'correspondingChildren' list will be the one whose result is currently available
            if(live_list[i]->latestIntermediateResultAvailable==1){
                continue;
            }

            //First we need to check if the execution of the node is complete. If the node is '/' or 'rd', then definitely the execution is complete.
            //If the node is 'mac_sub', the execution may be incomplete as some mac operations may still be remaining
            bool executionComplete = checkIfExecutionComplete_live_list(live_list[i]);

            if(executionComplete == true){//We need to check if any of the parents can be scheduled with the nodes available in 'live_list'.
                for(int j=0;j<live_list[i]->parents.size();j++){
                    tmpParent = live_list[i]->parents[j];

                    //If a parent has already been put in 'newExecutableNodes', no need to check again
                    if(checkIfNodeInList(newExecutableNodes,tmpParent->nodeId) == true){
                        continue;//Move no to next iteration
                    }

                    //Then check if tmpParent is already in execution or finished execution. This can happen if tmpParent has been put in execution queue due to forwarding but we still need to save its children in memory.
                    if(tmpParent->latestIntermediateResultAvailable == 0 || tmpParent->readyBit == true){
                        continue;//Move no to next iteration
                    }

                    //Now checking if the tmpParent node can be pushed to 'newExecutableNodes'
                    //It can only be pushed if the children nodes required to schedule 'tmpParent' is there in 'live_list'
                    vector<Node *> tmpChildren;
                    if(findChildren_live_list(live_list,tmpParent,tmpChildren) == true){
                        int index = listPriorityInsert(newExecutableNodes,tmpParent);
                        correspondingChildren.insert(correspondingChildren.begin()+index,tmpChildren);
                    }
                }
            }
            else{//definitely corresponds to "mac_sub" nodes with mac operations still remaining
                //If a live_list[i] has already been put in 'newExecutableNodes', no need to check again
                //Ideally this condition should always return false
                if(checkIfNodeInList(newExecutableNodes,live_list[i]->nodeId) == true){
                    continue;//Move no to next iteration
                }
                //Now checking if the live_list[i] node can be pushed to 'newExecutableNodes'
                //It can only be pushed if the children nodes required to schedule 'live_list[i]' is there in 'live_list'
                vector<Node *> tmpChildren;
                if(findChildren_live_list(live_list,live_list[i],tmpChildren) == true){
                    int index = listPriorityInsert(newExecutableNodes,live_list[i]);
                    correspondingChildren.insert(correspondingChildren.begin()+index,tmpChildren);
                }
            }
        }

        //Mode the contents from 'tmp_newExecutableNodes' to 'newExecutableNodes' and 'tmp_correspondingChildren' to 'correspondingChildren'
        //Note that 'tmp_newExecutableNodes' contains those nodes which can be scheduled immediately without needing to read any operand from memory
        //Hence the 1st part of 'newExecutableNodes' will contain those nodes for which atleast 1 operand has to be fetched from memory and at least 1 operand will be readily available. The 2nd part of the 'newExecutableNodes' has those nodes whose none of the operands needs to be fetched from memory
        for(int i=0;i<tmp_newExecutableNodes.size();i++){
            newExecutableNodes.push_back(tmp_newExecutableNodes[i]);
        }
        for(int i=0;i<tmp_correspondingChildren.size();i++){
            correspondingChildren.push_back(correspondingChildren[i]);
        }


    }//mode1 if block end

}

void estimateFutureBRAMUtilization(vector<int> &BRAM_status,vector<Node *> execution_list,vector<int> execution_list_cycles_left,int latency){
    //for the nodes with  cycles_left = latency, find in which BRAM that node result needs to be stored and increment that particular index in BRAM_status by 1.
    for(int i=0;i<execution_list_cycles_left.size();i++){
        if(execution_list_cycles_left[i] == latency){
            //Fetch the BRAMid where that node needs to be stored
            int destBRAMId;
            if(execution_list[i]->op == "wr"){
                //"wr" type node can never be in 'execution_list'. Hence this if part ideally should never be encountered.
                destBRAMId = execution_list[i]->wrBRAMId;
            }
            else{
                destBRAMId = execution_list[i]->matPointer->BRAMInd[execution_list[i]->memMapIndex];
            }

            //Increment
            BRAM_status[destBRAMId]  = BRAM_status[destBRAMId] + 1;
        }
    }
}

//This function is used to fetch how much of the BRAM ports have been used up due to memory write
void getCurrentBRAMUtilization(vector<int> &current_cycle_BRAM_status,vector<Node *> mem_write_list,vector<int> mem_write_list_cycles_left,int latency){
    for(int i=0;i<mem_write_list_cycles_left.size();i++){
        if(mem_write_list_cycles_left[i] == latency){
            //Fetch the BRAMid where that node needs to be stored
            int BRAMId;
            if(mem_write_list[i]->op == "wr"){
                BRAMId = mem_write_list[i]->wrBRAMId;
            }
            else{
                BRAMId = mem_write_list[i]->matPointer->BRAMInd[mem_write_list[i]->memMapIndex];
            }

            current_cycle_BRAM_status[BRAMId] = current_cycle_BRAM_status[BRAMId] + 1;
        }
    }
}

void rearrange_potential_executable_nodes(vector<Node *> &newExecutableNodes,vector<vector<Node *>> &correspondingChildren,vector<Node *> schedulable_list,vector<int> schedulable_list_cycles_left){
    for(int i=newExecutableNodes.size()-1;i>=0;i--){
        for(int j=schedulable_list.size()-1;j>=0;j--){
            if(newExecutableNodes[i]->nodeId == schedulable_list[j]->nodeId && schedulable_list_cycles_left[j] == 0){
                Node *tmpNode = newExecutableNodes[i];
                vector<Node *> tmpchildren = correspondingChildren[i];
                newExecutableNodes.erase(newExecutableNodes.begin()+i);
                correspondingChildren.erase(correspondingChildren.begin()+i);
                newExecutableNodes.push_back(tmpNode);
                correspondingChildren.push_back(tmpchildren);
                break;
            }
        }
    }
}

void update_mem_write_and_execution_list(vector<Node *> &execution_list,vector<int> &execution_list_cycles_left,vector<int> &AU_Ids,vector<Node *> &schedulable_list,vector<int> &schedulable_list_cycles_left,vector<Node *> &mem_write_list,vector<int> &mem_write_list_cycles_left,vector<int> &BRAM_Ids_mem_write,vector<Node *> &mem_read_list,vector<int> &mem_read_list_cycles_left,vector<int> &BRAM_Ids_mem_read,vector<int> latencies,vector<int> hwUnits,Schedule &schedule,int mode,int cyclesLeft){
    //Based on nodes which have finished execution and being read from memory, find nodes which can be scheduled for execution in the next cycle
    vector<Node *> newExecutableNodes;
    //This vector holds the list of children for each corresponding node in the the vector 'newExecutableNodes'
    vector<vector<Node *>> correspondingChildren;
    //Based only on nodes which have finished execution, generating a list of nodes which have to be written back to memory
    vector<Node *> writeBackNodes;

    //This function will take mem_read_list and execution_list as arguments and return two vectors, the 1st list will contain nodes that can be put to execution list again, and another list containing nodes that have to be written back to memory.
    findExecutableAndWriteBackNodes(execution_list,execution_list_cycles_left,mem_read_list,mem_read_list_cycles_left,newExecutableNodes,correspondingChildren,writeBackNodes,mode,cyclesLeft);

    //The below 2 variables are created and populated so that we can get the input location of the mux of the BRAMS and AUs while writing to 'schedule.memSchedule' & 'schedule.AUSchedule'
    vector<Node *> current_cycle_AU_operations;
    vector<int> current_cycle_AU_Ids;
    for(int i=0;i<execution_list.size();i++){
        if(execution_list_cycles_left[i] == 0){
            current_cycle_AU_operations.push_back(execution_list[i]);
            current_cycle_AU_Ids.push_back(AU_Ids[i]);
        }
    }
    for(int i=0;i<mem_read_list.size();i++){
        if(mem_read_list_cycles_left[i] == 0){
            current_cycle_AU_operations.push_back(mem_read_list[i]);
            //here the AU_Ids tell, to which input channel of the mux is the output of that BRAM port connected to
            current_cycle_AU_Ids.push_back(hwUnits[2] + hwUnits[3] + BRAM_Ids_mem_read[i]);
        }
    }

    //Now it's important that those nodes from 'schedulable_list' whose count in 'schedulable_list_cycles_left' have become 0 should be pushed in front of the 'newExecutableNodes'(i.e. they are given higher priorities)
    rearrange_potential_executable_nodes(newExecutableNodes,correspondingChildren,schedulable_list,schedulable_list_cycles_left);

    //This variable will keep a track of which all arithmetic units have been used up till now
    vector<int> AU_status;
    //This variable will keep a track of BRAM units and it's ports
    vector<int> future_BRAM_status_div_nodes;//Used to check if a div operation can be scheduled
    vector<int> future_BRAM_status_mac_nodes;//Used to check if a mac operation can be scheduled
    vector<int> current_cycle_BRAM_status;//While writing nodes in the list 'writeBackNodes' to the list 'mem_write_list', we keep a track using this vector.

    //First populating them with 0s
    //0th index is for mac and 1st index is for div
    for(int i=0;i<2;i++){
        AU_status.push_back(0);
    }

    //Each index is for 1 BRAM. Each index location will store how many ports of that BRAM have been used up.
    for(int i=0;i<hwUnits[0];i++){
        future_BRAM_status_div_nodes.push_back(0);
        future_BRAM_status_mac_nodes.push_back(0);
        current_cycle_BRAM_status.push_back(0);
    }

    //Fetching the BRAM locations that are already occupied
    //Based on the AU operations that finishes after a known amount of cycle(in future), we can estimate the max no. of BRAM operations that need to be scheduled in that cycle(in future.)
    //I say 'max' because if the node is schedulable immediately after the execution finishes, in some cases it need not be saved in BRAM.
    estimateFutureBRAMUtilization(future_BRAM_status_div_nodes,execution_list,execution_list_cycles_left,latencies[3]+cyclesLeft);
    estimateFutureBRAMUtilization(future_BRAM_status_mac_nodes,execution_list,execution_list_cycles_left,latencies[2]+cyclesLeft);

    //If mac and div latencies are same, merge them and save the merged value in both 'future_BRAM_status_div_latency' & 'future_BRAM_status_mac_latency'
    if(latencies[2] == latencies[3]){
        for(int i=0;i<future_BRAM_status_div_nodes.size();i++){
            future_BRAM_status_div_nodes[i] = future_BRAM_status_div_nodes[i] + future_BRAM_status_mac_nodes[i];
            future_BRAM_status_mac_nodes[i] = future_BRAM_status_div_nodes[i];
        }
    }

    //As a precaution, check if no index is greater than no. of BRAMS available. If yes the schedule has gone wrong in some place and is wrong
    for(int i=0;i<future_BRAM_status_div_nodes.size();i++){
        if(future_BRAM_status_div_nodes[i] > hwUnits[1]){
            cout << "Error1 detected in function 'update_mem_write_and_execution_list' in file Schedule.cpp" << endl;
            break;
        }
    }

    for(int i=0;i<future_BRAM_status_mac_nodes.size();i++){
        if(future_BRAM_status_mac_nodes[i] > hwUnits[1]){
            cout << "Error2 detected in function 'update_mem_write_and_execution_list' in file Schedule.cpp" << endl;
            break;
        }
    }

    //Remove the nodes which have finished operation from 'mem_read_list' & 'execution_list'
    for(int i=0;i<mem_read_list.size();i++){
        if(mem_read_list_cycles_left[i] == 0){
            mem_read_list.erase(mem_read_list.begin()+i);
            mem_read_list_cycles_left.erase(mem_read_list_cycles_left.begin()+i);
            BRAM_Ids_mem_read.erase(BRAM_Ids_mem_read.begin()+i);
            i--;//This is important, as everytime an element from a vector is removed, its size reduces by 1
        }
    }

    //Clearing the 'execution_list' and updating 'nodeEvalStatus'
    for(int i=0;i<execution_list.size();i++){
        if(execution_list_cycles_left[i] == 0){
            //In case of "mac_sub" node change the element of 'nodeEvalStatus' vector which is 2 to 1
            if(execution_list[i]->op == "mac_sub"){
                for(int j=0;j<execution_list[i]->nodeEvalStatus.size();j++){
                    if(execution_list[i]->nodeEvalStatus[j] == 2){
                        execution_list[i]->nodeEvalStatus[j] = 1;
                    }
                }
            }

            execution_list.erase(execution_list.begin()+i);
            execution_list_cycles_left.erase(execution_list_cycles_left.begin()+i);
            AU_Ids.erase(AU_Ids.begin()+i);
            i--;//This is important, as everytime an element from a vector is removed, its size reduces by 1
        }
    }

    //Now if the nodes in 'newExecutableNodes' will have enough BRAM ports available once they have finished execution, add them to execution_list.
    //Highest priority nodes are at the end of the list so we will start from end
    vector<AU_Operation> tmp_AU_Operation;
    for(int i=newExecutableNodes.size()-1;i>=0;i--){
        if(newExecutableNodes[i]->op == "wr"){
            continue;
        }
        //Fetching the BRAMId where the node is to be saved
        int dest_BRAMId = newExecutableNodes[i]->matPointer->BRAMInd[newExecutableNodes[i]->memMapIndex];

        //Checking if enough ports are available at the 'dest_BRAMId' and enough AUs are available in the current cycle
        if(newExecutableNodes[i]->op == "mac_sub" && future_BRAM_status_mac_nodes[dest_BRAMId] < hwUnits[1] && AU_status[0] < hwUnits[2]){
            execution_list.push_back(newExecutableNodes[i]);
            execution_list_cycles_left.push_back(latencies[2]);
            AU_Ids.push_back(AU_status[0]);

            //Checking if the node is in 'schedulable_list'. If yes, then remove that node.
            for(int j=0;j<schedulable_list.size();j++){
                if(schedulable_list[j]->nodeId == newExecutableNodes[i]->nodeId){
                    schedulable_list.erase(schedulable_list.begin()+j);
                    schedulable_list_cycles_left.erase(schedulable_list_cycles_left.begin()+j);
                    break;
                }
            }

            //updating the corrent index of 'nodeEvalStatus' vector to 2
            bool testFlag = false;
            for(int j=1;j<newExecutableNodes[i]->children.size();j++){
                if(correspondingChildren[i][1]->nodeId == newExecutableNodes[i]->children[j]->nodeId){
                    newExecutableNodes[i]->nodeEvalStatus[j/2] = 2;
                    testFlag = true;
                }
            }
            if(testFlag == false){
                cout << "Error4 occured in the function 'update_mem_write_and_execution_list' in file 'Schedule.cpp'" << endl;
            }

            //making 'latestIntermediateResultAvailable' equal to 0
            newExecutableNodes[i]->latestIntermediateResultAvailable = 0;

            //incrementing the count of 'future_BRAM_status_mac_nodes' & 'AU_status'
            future_BRAM_status_mac_nodes[dest_BRAMId] = future_BRAM_status_mac_nodes[dest_BRAMId] + 1;
            //If mac and div latencies are same, change should be reflected in both the arrays
            if(latencies[2] == latencies[3]){
                future_BRAM_status_div_nodes[dest_BRAMId] = future_BRAM_status_mac_nodes[dest_BRAMId];
            }

            //updating 'tmp_AU_Operation'
            AU_Operation tmpOpAU;
            tmpOpAU.node_name = newExecutableNodes[i]->name;
            tmpOpAU.op = "mac_sub";
            tmpOpAU.AUIndex = AU_status[0];
            tmpOpAU.nodePtr = newExecutableNodes[i];
            tmpOpAU.inputIds.push_back(correspondingChildren[i][0]->nodeId);
            tmpOpAU.inputIds.push_back(correspondingChildren[i][1]->nodeId);
            tmpOpAU.inputIds.push_back(correspondingChildren[i][2]->nodeId);
            int ind = findNodeIndex(current_cycle_AU_operations,correspondingChildren[i][0]->nodeId);
            if(ind == -1){//Indicates that the node is "const"
                tmpOpAU.inputLocs.push_back(hwUnits[0]*hwUnits[1] + hwUnits[2] + hwUnits[3]);
            }
            else{
                tmpOpAU.inputLocs.push_back(current_cycle_AU_Ids[ind]);
            }
            ind = findNodeIndex(current_cycle_AU_operations,correspondingChildren[i][1]->nodeId);
            if(ind == -1){
                cout << "Error5 occured in 'update_mem_write_and_execution_list' in file 'Schedule.cpp'" << endl;
            }
            tmpOpAU.inputLocs.push_back(current_cycle_AU_Ids[ind]);
            ind = findNodeIndex(current_cycle_AU_operations,correspondingChildren[i][2]->nodeId);
            if(ind == -1){
                cout << "Error6 occured in 'update_mem_write_and_execution_list' in file 'Schedule.cpp'" << endl;
            }
            tmpOpAU.inputLocs.push_back(current_cycle_AU_Ids[ind]);
            tmpOpAU.assignClock = current_cycle;
            tmpOpAU.retireClock = current_cycle + latencies[2];
            tmpOpAU.BRAMIndex = newExecutableNodes[i]->matPointer->BRAMInd[newExecutableNodes[i]->memMapIndex];
            tmpOpAU.BRAMAddress = newExecutableNodes[i]->matPointer->BRAMAddr[newExecutableNodes[i]->memMapIndex];
            tmpOpAU.outputId = newExecutableNodes[i]->nodeId;
            tmp_AU_Operation.push_back(tmpOpAU);

            AU_status[0] = AU_status[0] + 1;
        }
        else if(newExecutableNodes[i]->op == "/" && future_BRAM_status_div_nodes[dest_BRAMId] < hwUnits[1] && AU_status[1] < hwUnits[3]){
            execution_list.push_back(newExecutableNodes[i]);
            execution_list_cycles_left.push_back(latencies[3]);
            AU_Ids.push_back(hwUnits[2] + AU_status[1]);

            //Checking if the node is in 'schedulable_list'. If yes, then remove that node.
            for(int j=0;j<schedulable_list.size();j++){
                if(schedulable_list[j]->nodeId == newExecutableNodes[i]->nodeId){
                    schedulable_list.erase(schedulable_list.begin()+j);
                    schedulable_list_cycles_left.erase(schedulable_list_cycles_left.begin()+j);
                    break;
                }
            }

            //making 'latestIntermediateResultAvailable' equal to 0
            newExecutableNodes[i]->latestIntermediateResultAvailable = 0;

            //incrementing the count of 'future_BRAM_status_mac_nodes' & 'AU_status'
            future_BRAM_status_div_nodes[dest_BRAMId] = future_BRAM_status_div_nodes[dest_BRAMId] + 1;
            //If mac and div latencies are same, change should be reflected in both the arrays
            if(latencies[2] == latencies[3]){
                future_BRAM_status_mac_nodes[dest_BRAMId] = future_BRAM_status_div_nodes[dest_BRAMId];
            }

            //updating 'tmp_AU_Operation'
            AU_Operation tmpOpAU;
            tmpOpAU.node_name = newExecutableNodes[i]->name;
            tmpOpAU.op = "/";
            tmpOpAU.AUIndex = hwUnits[2] + AU_status[1];
            tmpOpAU.nodePtr = newExecutableNodes[i];
            tmpOpAU.inputIds.push_back(correspondingChildren[i][0]->nodeId);
            tmpOpAU.inputIds.push_back(correspondingChildren[i][1]->nodeId);
            int ind = findNodeIndex(current_cycle_AU_operations,correspondingChildren[i][0]->nodeId);
            if(ind == -1){//Indicates that the node is "const"
                cout << "Error7 occured in 'update_mem_write_and_execution_list' in file 'Schedule.cpp'" << endl;
            }
            tmpOpAU.inputLocs.push_back(current_cycle_AU_Ids[ind]);
            ind = findNodeIndex(current_cycle_AU_operations,correspondingChildren[i][1]->nodeId);
            if(ind == -1){
                cout << "Error8 occured in 'update_mem_write_and_execution_list' in file 'Schedule.cpp'" << endl;
            }
            tmpOpAU.inputLocs.push_back(current_cycle_AU_Ids[ind]);
            tmpOpAU.assignClock = current_cycle;
            tmpOpAU.retireClock = current_cycle + latencies[3];
            tmpOpAU.BRAMIndex = newExecutableNodes[i]->matPointer->BRAMInd[newExecutableNodes[i]->memMapIndex];
            tmpOpAU.BRAMAddress = newExecutableNodes[i]->matPointer->BRAMAddr[newExecutableNodes[i]->memMapIndex];
            tmpOpAU.outputId = newExecutableNodes[i]->nodeId;
            tmp_AU_Operation.push_back(tmpOpAU);

            AU_status[1] = AU_status[1] + 1;
        }
    }

    //Next we need to move the children of those "wr" nodes from "newExecutableNodes" to "writeBackNodes" whose child is "mac_sub" and belongs to "L" and readyBit = false
    for(int i=0;i<newExecutableNodes.size();i++){
        if(newExecutableNodes[i]->op == "wr"){
            if(checkIfNodeInList(writeBackNodes,correspondingChildren[i][0]->nodeId) == false && correspondingChildren[i][0]->op == "mac_sub" && correspondingChildren[i][0]->readyBit == false && correspondingChildren[i][0]->matPointer->name == "L"){
                writeBackNodes.push_back(correspondingChildren[i][0]);
            }
        }
    }

    //move the children nodes of nodes in 'newExecutableNodes' list which couldn't be pushed to 'execution_list' to the list 'writeBackNodes'(provided they already dont exist in that list)
    //But first delete those nodes from 'newExecutableNodes' which have been moved to 'execution_list'
    for(int i=0;i<newExecutableNodes.size();i++){
        if(checkIfNodeInList(execution_list,newExecutableNodes[i]->nodeId) == true || checkIfNodeInList(writeBackNodes,newExecutableNodes[i]->nodeId) == true){
            newExecutableNodes.erase(newExecutableNodes.begin()+i);
            correspondingChildren.erase(correspondingChildren.begin()+i);
            i--;//This is important, as everytime an element from a vector is removed, its size reduces by 1
        }
    }

    for(int i=0;i<newExecutableNodes.size();i++){
    	if(newExecutableNodes[i]->op == "wr"){
    		continue;
    	}
        for(int j=0;j<correspondingChildren[i].size();j++){
            if(checkIfNodeInList(writeBackNodes,correspondingChildren[i][j]->nodeId) == false && correspondingChildren[i][j]->latestIntermediateResultAvailable == 0){
                writeBackNodes.push_back(correspondingChildren[i][j]);
            }
        }
    }

    //If enough bram ports are not availbale to write the contents of 'writeBackNodes' till mandatoryWriteIndex, there is a bug in scheduling
    int mandatoryWriteIndex = writeBackNodes.size()-1;

    //Next we will move those 'wr' nodes from 'newExecutableNodes' to 'writeBackNodes' whose child has readyBit = true. These 'wr' nodes are from 'schedulable_list'
    for(int i=0;i<newExecutableNodes.size();i++){
        if(newExecutableNodes[i]->op == "wr"){
            if(checkIfNodeInList(writeBackNodes,newExecutableNodes[i]->nodeId) == false && correspondingChildren[i][0]->readyBit == true){
                writeBackNodes.push_back(newExecutableNodes[i]);
            }
        }
    }

    //Next we will move those 'wr' nodes from 'newExecutableNodes' to 'writeBackNodes' whose child is ('mac_sub' and 'U') or 'div' and readyBit = false
    //Indirectly these are those nodes which have finished operation in the current cycle and have 1 or more parent as 'wr' node. Hence the result can be written in multiple memory locations if sufficient ports are available
    for(int i=0;i<newExecutableNodes.size();i++){
        if(newExecutableNodes[i]->op == "wr"){
            if((correspondingChildren[i][0]->op == "mac_sub" && correspondingChildren[i][0]->matPointer->name == "U") || correspondingChildren[i][0]->op == "/"){
                if(checkIfNodeInList(writeBackNodes,newExecutableNodes[i]->nodeId) == false && correspondingChildren[i][0]->readyBit == false){
                    writeBackNodes.push_back(newExecutableNodes[i]);
                }
            }
        }
    }


    //Now we need to move the nodes from 'writeBackNodes' to 'mem_write_node'. And also update 'schedule.memSchedule'
    vector<BRAM_Operation> tmpBRAM_operation;
    for(int i=0;i<writeBackNodes.size();i++){
        //First obtaining the BRAMId where the node needs to be saved
        int temp_BRAMId;
        if(writeBackNodes[i]->op == "wr"){
            //for nodes of type 'wr', BRAMIds are saved in a different location
            temp_BRAMId = writeBackNodes[i]->wrBRAMId;
        }else{
            temp_BRAMId = writeBackNodes[i]->matPointer->BRAMInd[writeBackNodes[i]->memMapIndex];
        }

        //Checking if enough ports are free for that BRAMId. If no, then the scheduling has gone wrong. Display an error message in that case
        if(current_cycle_BRAM_status[temp_BRAMId] < hwUnits[1]){
            mem_write_list.push_back(writeBackNodes[i]);
            mem_write_list_cycles_left.push_back(latencies[1]);
            BRAM_Ids_mem_write.push_back(hwUnits[1]*temp_BRAMId + current_cycle_BRAM_status[temp_BRAMId]);

            //If the node is of type 'wr', checking if the node is in 'schedulable_list'. If yes, then remove that node.
            if(writeBackNodes[i]->op == "wr"){
                for(int j=0;j<schedulable_list.size();j++){
                    if(schedulable_list[j]->nodeId == writeBackNodes[i]->nodeId){
                        schedulable_list.erase(schedulable_list.begin()+j);
                        schedulable_list_cycles_left.erase(schedulable_list_cycles_left.begin()+j);
                        break;
                    }
                }
            }

            //Updating 'tmpBRAM_operation'
            BRAM_Operation tmpOp;
            tmpOp.node_name = writeBackNodes[i]->name;
            tmpOp.op = 1; //1 indicates memory write
            tmpOp.BRAMIndex = temp_BRAMId;
            tmpOp.portIndex = current_cycle_BRAM_status[temp_BRAMId];
            if(writeBackNodes[i]->op == "wr"){
                tmpOp.addr = writeBackNodes[i]->wrBRAMAddr;
            }
            else{
                tmpOp.addr = writeBackNodes[i]->matPointer->BRAMAddr[writeBackNodes[i]->memMapIndex];
            }

            int ind;
            if(writeBackNodes[i]->op == "wr"){
            	ind = findNodeIndex(current_cycle_AU_operations,writeBackNodes[i]->children[0]->nodeId);
            }
            else{
            	ind = findNodeIndex(current_cycle_AU_operations,writeBackNodes[i]->nodeId);
            }
            if(ind == -1){
            	cout << "Error4 occured in 'update_mem_write_and_execution_list' in file 'Schedule.cpp'" << endl;
            }
            tmpOp.dinLoc = current_cycle_AU_Ids[ind];

            tmpOp.nodeId = writeBackNodes[i]->nodeId;
            tmpOp.nodePtr = writeBackNodes[i];
            tmpBRAM_operation.push_back(tmpOp);

            current_cycle_BRAM_status[temp_BRAMId] = current_cycle_BRAM_status[temp_BRAMId] + 1;

        }
        else if(i<=mandatoryWriteIndex){
            cout << "Error3 occured in the function 'update_mem_write_and_execution_list' in file 'Schedule.cpp'" << endl;
        }
    }
    schedule.memSchedule.push_back(tmpBRAM_operation);
    schedule.AUSchedule.push_back(tmp_AU_Operation);
}

bool findChildren_schedulable_list(Node *some_node,vector<Node *> &correspondingChildren){
    if(some_node->op == "mac_sub"){
        //Checking if "mac_sub" node has ever been evaluated
        if(some_node->latestIntermediateResultAvailable == -1){
            //checking if A(in A-BC-DE...) is ready
            if(some_node->children[0]->readyBit == true){
                //Checking if any pair of multiplication operands is ready
                for(int i=1;i<some_node->children.size();i+=2){
                    if(some_node->children[i]->readyBit == true && some_node->children[i+1]->readyBit == true && some_node->nodeEvalStatus[i/2] == 0){
                        correspondingChildren.push_back(some_node->children[0]);
                        correspondingChildren.push_back(some_node->children[i]);
                        correspondingChildren.push_back(some_node->children[i+1]);
                        return true;
                    }
                }
            }
        }
        else{//else part indicates that the node has already been partially evaluated.
            //Checking if any pair of multiplication operands is ready
            for(int i=1;i<some_node->children.size();i+=2){
                if(some_node->children[i]->readyBit == true && some_node->children[i+1]->readyBit == true && some_node->nodeEvalStatus[i/2] == 0){
                    correspondingChildren.push_back(some_node);
                    correspondingChildren.push_back(some_node->children[i]);
                    correspondingChildren.push_back(some_node->children[i+1]);
                    return true;
                }
            }
        }
    }
    else{//Indicates that it's a div node
        correspondingChildren.push_back(some_node->children[0]);
        correspondingChildren.push_back(some_node->children[1]);
        return true;
    }

    cout << "Error in funcrtion 'findChildren_schedulable_list' in the file 'Schedule.cpp'" <<endl;
    return false;
}

void reset_schedulable_list_status(vector<int> schedulable_list_cycles_left){
    for(int i=0;i<schedulable_list_cycles_left.size();i++){
        if(schedulable_list_cycles_left[i] == 0){
            schedulable_list_cycles_left[i] = -1;
        }
    }
}

void update_mem_read_list(vector<Node *> &execution_list,vector<int> &execution_list_cycles_left,vector<Node *> &mem_write_list,vector<int> &mem_write_list_cycles_left,vector<Node *> &mem_read_list,vector<int> &mem_read_list_cycles_left,vector<int> &BRAM_Ids_mem_read,vector<Node *> &schedulable_list,vector<int> &schedulable_list_cycles_left,vector<int> latencies,Schedule &schedule,vector<int> hwUnits,int mode,int cyclesLeft){
    //Based on nodes which will finish execution after 'cyclesLeft' cycles and already nodes which are already available in memory, find nodes which can be scheduled for execution after 'cyclesLeft' cycles
    vector<Node *> newExecutableNodes;
    //This vector holds the list of children for each corresponding node in the the vector 'newExecutableNodes'
    vector<vector<Node *>> correspondingChildren;
    //This function has no purpose for this variable
    vector<Node *> writeBackNodes;

    //This function will take mem_read_list and execution_list as arguments and return two vectors, the 1st list will contain nodes that can be put to execution list again, and another list containing nodes that have to be written back to memory.
    findExecutableAndWriteBackNodes(execution_list,execution_list_cycles_left,mem_read_list,mem_read_list_cycles_left,newExecutableNodes,correspondingChildren,writeBackNodes,mode,cyclesLeft);

    //This variable will keep a track of which all arithmetic units have been used up till now at the cycle current cycle + memory read latency
    vector<int> AU_status;
    //This variable will keep a track of BRAM units and it's ports when the AU operations scheduled at time current cycle + memory read latency ends
    vector<int> future_BRAM_status_div_nodes;//Used to check if a div operation can be scheduled
    vector<int> future_BRAM_status_mac_nodes;//Used to check if a mac operation can be scheduled
    //This variable will keep a track of BRAM utilization in the current cycle. Note that for the current cycle BRAM has already been utilized partially for writing nodes back to memory in the function 'update_mem_write_and_execution_list'
    vector<int> current_cycle_BRAM_status;
    //To schedule 'wr' nodes from 'schedulable_list' we need to make sure that there is enough BRAM ports available read latency cycles after the current cycle.
    vector<int> future_BRAM_status_wr_nodes;

    //First populating them with 0s
    //0th index is for mac and 1st index is for div
    for(int i=0;i<2;i++){
        AU_status.push_back(0);
    }

    //Each index is for 1 BRAM. Each index location will store how many ports of that BRAM have been used up.
    for(int i=0;i<hwUnits[0];i++){
        future_BRAM_status_div_nodes.push_back(0);
        future_BRAM_status_mac_nodes.push_back(0);
        current_cycle_BRAM_status.push_back(0);
        future_BRAM_status_wr_nodes.push_back(0);
    }

    //Fetching the BRAM locations that are already occupied
    //Based on the AU operations that finishes after a known amount of cycle(in future), we can estimate the max no. of BRAM operations that need to be scheduled in that cycle(in future.)
    //I say 'max' because if the node is schedulable immediately after the execution finishes, in some cases it need not be saved in BRAM.
    estimateFutureBRAMUtilization(future_BRAM_status_div_nodes,execution_list,execution_list_cycles_left,latencies[3]+cyclesLeft);
    estimateFutureBRAMUtilization(future_BRAM_status_mac_nodes,execution_list,execution_list_cycles_left,latencies[2]+cyclesLeft);
    getCurrentBRAMUtilization(current_cycle_BRAM_status,mem_write_list,mem_write_list_cycles_left,latencies[1]);

    //If mac and div latencies are same, merge them and save the merged value in both 'future_BRAM_status_div_latency' & 'future_BRAM_status_mac_latency'
    if(latencies[2] == latencies[3]){
        for(int i=0;i<future_BRAM_status_div_nodes.size();i++){
            future_BRAM_status_div_nodes[i] = future_BRAM_status_div_nodes[i] + future_BRAM_status_mac_nodes[i];
            future_BRAM_status_mac_nodes[i] = future_BRAM_status_div_nodes[i];
        }
    }

    //As a precaution, check if no index is greater than no. of BRAMS available. If yes the schedule has gone wrong in some place and is wrong
    for(int i=0;i<future_BRAM_status_div_nodes.size();i++){
        if(future_BRAM_status_div_nodes[i] > hwUnits[1]){
            cout << "Error1 detected in function 'update_mem_read_list' in file Schedule.cpp" << endl;
            break;
        }
    }

    for(int i=0;i<future_BRAM_status_mac_nodes.size();i++){
        if(future_BRAM_status_mac_nodes[i] > hwUnits[1]){
            cout << "Error2 detected in function 'update_mem_read_list' in file Schedule.cpp" << endl;
            break;
        }
    }

    for(int i=0;i<current_cycle_BRAM_status.size();i++){
        if(current_cycle_BRAM_status[i] > hwUnits[1]){
            cout << "Error3 detected in function 'update_mem_read_list' in file Schedule.cpp" << endl;
            break;
        }
    }

    //Now we will start to find nodes to be put into read list
    //Highest priority nodes are at the end of the list so we will start from end
    vector<BRAM_Operation> &tmp_memSchedule = schedule.memSchedule[current_cycle];
    for(int i=newExecutableNodes.size()-1;i>=0;i--){
        if(newExecutableNodes[i]->op == "wr"){
            continue;
        }

        //Check if enough BRAM ports are free at the current cycle to fetch the operand nodes required to schedule newExecutableNodes[i]
        bool portsAvailable = true;//Initially assuming ports are available
        //A temporary vector to note the BRAM ports required to read the operand nodes
        vector<int> tmpBRAMStatus;
        vector<Node *> tmp_mem_read_list;
        vector<int> tmp_BRAM_Ids_mem_read;
        for(int j=0;j<hwUnits[0];j++){
            tmpBRAMStatus.push_back(0);
        }
        for(int j=0;j<correspondingChildren[i].size();j++){
             if(correspondingChildren[i][j]->latestIntermediateResultAvailable == 1 && correspondingChildren[i][j]->op != "const"){//Indiactes that this node has to be read from memory
                 //If the node already exists in the list 'mem_read_list' then continue to next iteration
                 if(checkIfNodeInList_withLatency(mem_read_list,mem_read_list_cycles_left,correspondingChildren[i][j]->nodeId,cyclesLeft) == true || checkIfNodeInList(tmp_mem_read_list,correspondingChildren[i][j]->nodeId) == true){
                     continue;
                 }

                 //Fetching the bram id from where this node has to be fetched
                 int childBRAMId;
                 if(correspondingChildren[i][j]->op == "wr"){
                     childBRAMId = correspondingChildren[i][j]->wrBRAMId;
                 }
                 else{
                     childBRAMId = correspondingChildren[i][j]->matPointer->BRAMInd[correspondingChildren[i][j]->memMapIndex];
                 }

                 //checking and then incrementing
                 if(tmpBRAMStatus[childBRAMId] + current_cycle_BRAM_status[childBRAMId] < hwUnits[1]){
                     tmp_mem_read_list.push_back(correspondingChildren[i][j]);
                     tmp_BRAM_Ids_mem_read.push_back(hwUnits[1]*childBRAMId + tmpBRAMStatus[childBRAMId] + current_cycle_BRAM_status[childBRAMId]);
                     tmpBRAMStatus[childBRAMId] = tmpBRAMStatus[childBRAMId] + 1;
                 }
                 else{
                     portsAvailable = false;
                     break;
                 }
             }
        }

        if(portsAvailable == false)
            continue;//move on to next node in newExecutableNodes

        //Fetching the BRAMId where the node is to be saved
        int dest_BRAMId = newExecutableNodes[i]->matPointer->BRAMInd[newExecutableNodes[i]->memMapIndex];

        //Next we need to check if enough AUs are available at the time current cycle + mem read latency cycles and enough BRAMs are available at the time when the AU operation ends
        if(newExecutableNodes[i]->op == "mac_sub" && future_BRAM_status_mac_nodes[dest_BRAMId] < hwUnits[1] && AU_status[0] < hwUnits[2]){

            //Updating the vector 'current_cycle_BRAM_status'
            for(int j=0;j<tmpBRAMStatus.size();j++){
                current_cycle_BRAM_status[j] = current_cycle_BRAM_status[j] + tmpBRAMStatus[j];
            }

            //Updating the vector 'mem_read_list'
            for(int j=0;j<tmp_mem_read_list.size();j++){
                mem_read_list.push_back(tmp_mem_read_list[j]);
                BRAM_Ids_mem_read.push_back(tmp_BRAM_Ids_mem_read[j]);
                mem_read_list_cycles_left.push_back(latencies[0]);

                //Updating 'tmpBRAMStatus'
                BRAM_Operation tmpOp;
                tmpOp.node_name = tmp_mem_read_list[j]->name;
                tmpOp.op = 0;//0 corresponds to memory read
                if(tmp_mem_read_list[j]->op == "wr"){
                   tmpOp.BRAMIndex =  tmp_mem_read_list[j]->wrBRAMId;
                   tmpOp.addr = tmp_mem_read_list[j]->wrBRAMAddr;
                }
                else{
                    tmpOp.BRAMIndex = tmp_mem_read_list[j]->matPointer->BRAMInd[tmp_mem_read_list[j]->memMapIndex];
                    tmpOp.addr = tmp_mem_read_list[j]->matPointer->BRAMAddr[tmp_mem_read_list[j]->memMapIndex];
                }
                tmpOp.portIndex = tmp_BRAM_Ids_mem_read[j] - (hwUnits[1]*tmpOp.BRAMIndex);
                tmpOp.dinLoc = hwUnits[0]*hwUnits[1] + hwUnits[2] + hwUnits[3] + 1; //This is not required during memory read
                tmpOp.nodeId = tmp_mem_read_list[j]->nodeId;
                tmpOp.nodePtr = tmp_mem_read_list[j];
                tmp_memSchedule.push_back(tmpOp);
            }

            //incrementing the count of 'future_BRAM_status_mac_nodes' & 'AU_status'
            future_BRAM_status_mac_nodes[dest_BRAMId] = future_BRAM_status_mac_nodes[dest_BRAMId] + 1;
            //If mac and div latencies are same, change should be reflected in both the arrays
            if(latencies[2] == latencies[3]){
                future_BRAM_status_div_nodes[dest_BRAMId] = future_BRAM_status_mac_nodes[dest_BRAMId];
            }

            AU_status[0] = AU_status[0] + 1;
        }
        else if(newExecutableNodes[i]->op == "/" && future_BRAM_status_div_nodes[dest_BRAMId] < hwUnits[1] && AU_status[1] < hwUnits[3]){

            //Updating the vector 'current_cycle_BRAM_status'
            for(int j=0;j<tmpBRAMStatus.size();j++){
                current_cycle_BRAM_status[j] = current_cycle_BRAM_status[j] + tmpBRAMStatus[j];
            }

            //Updating the vector 'mem_read_list'
            for(int j=0;j<tmp_mem_read_list.size();j++){
                mem_read_list.push_back(tmp_mem_read_list[j]);
                BRAM_Ids_mem_read.push_back(tmp_BRAM_Ids_mem_read[j]);
                mem_read_list_cycles_left.push_back(latencies[0]);

                //Updating 'tmpBRAMStatus'
                BRAM_Operation tmpOp;
                tmpOp.node_name = tmp_mem_read_list[j]->name;
                tmpOp.op = 0;//0 corresponds to memory read
                if(tmp_mem_read_list[j]->op == "wr"){
                    tmpOp.BRAMIndex = tmp_mem_read_list[j]->wrBRAMId;
                    tmpOp.addr = tmp_mem_read_list[j]->wrBRAMAddr;
                }
                else{
                    tmpOp.BRAMIndex = tmp_mem_read_list[j]->matPointer->BRAMInd[tmp_mem_read_list[j]->memMapIndex];
                    tmpOp.addr = tmp_mem_read_list[j]->matPointer->BRAMAddr[tmp_mem_read_list[j]->memMapIndex];
                }

                tmpOp.portIndex = tmp_BRAM_Ids_mem_read[j] - (hwUnits[1]*tmpOp.BRAMIndex);
                tmpOp.dinLoc = hwUnits[0]*hwUnits[1] + hwUnits[2] + hwUnits[3] + 1; //This is not required during memory read
                tmpOp.nodeId = tmp_mem_read_list[j]->nodeId;
                tmpOp.nodePtr = tmp_mem_read_list[j];
                tmp_memSchedule.push_back(tmpOp);
            }

            //incrementing the count of 'future_BRAM_status_mac_nodes' & 'AU_status'
            future_BRAM_status_div_nodes[dest_BRAMId] = future_BRAM_status_div_nodes[dest_BRAMId] + 1;
            //If mac and div latencies are same, change should be reflected in both the arrays
            if(latencies[2] == latencies[3]){
                future_BRAM_status_mac_nodes[dest_BRAMId] = future_BRAM_status_div_nodes[dest_BRAMId];
            }
            AU_status[1] = AU_status[1] + 1;
        }
    }

    //Now checking if nodes from 'schedulable_list' can be scheduled after memory read latency cycles
    for(int i=schedulable_list.size()-1;i>=0;i--){
        //Skip if the corresponding index in 'schedulable_list_cycles_left' is not -1 or node type is "wr"
        if(schedulable_list_cycles_left[i] != -1 || schedulable_list[i]->op == "wr"){
            continue;
        }

        //Check if enough BRAM ports are free at the current cycle to fetch the operand nodes required to schedule schedulable_list[i]
        bool portsAvailable = true;//Initially assuming ports are available
        //A temporary vector to note the BRAM ports required to read the operand nodes
        vector<int> tmpBRAMStatus;
        vector<Node *> tmp_mem_read_list;
        vector<int> tmp_BRAM_Ids_mem_read;
        for(int j=0;j<hwUnits[0];j++){
            tmpBRAMStatus.push_back(0);
        }
        vector<Node *> tmp_children;
        findChildren_schedulable_list(schedulable_list[i],tmp_children);
        for(int j=0;j<tmp_children.size();j++){
            if(tmp_children[j]->op != "const"){
                //If the node already exists in the list 'mem_read_list' then continue to next iteration
                if(checkIfNodeInList_withLatency(mem_read_list,mem_read_list_cycles_left,tmp_children[j]->nodeId,cyclesLeft) == true || checkIfNodeInList(tmp_mem_read_list,tmp_children[j]->nodeId) == true){
                    continue;
                }

                //Fetching the bram id from where this node has to be fetched from
                int childBRAMId;
                if(tmp_children[j]->op == "wr"){
                    childBRAMId = tmp_children[j]->wrBRAMId;
                }
                else{
                    childBRAMId = tmp_children[j]->matPointer->BRAMInd[tmp_children[j]->memMapIndex];
                }

                //checking and then incrementing
                if(tmpBRAMStatus[childBRAMId] + current_cycle_BRAM_status[childBRAMId] < hwUnits[1]){
                    tmp_mem_read_list.push_back(tmp_children[j]);
                    tmp_BRAM_Ids_mem_read.push_back(hwUnits[1]*childBRAMId + tmpBRAMStatus[childBRAMId] + current_cycle_BRAM_status[childBRAMId]);
                    tmpBRAMStatus[childBRAMId] = tmpBRAMStatus[childBRAMId] + 1;
                }
                else{
                    portsAvailable = false;
                    break;
                }
            }
        }

        if(portsAvailable == false)
            continue;//move on to next node in 'schedulable_list'

        //Fetching the BRAMId where the node is to be saved
        int dest_BRAMId = schedulable_list[i]->matPointer->BRAMInd[schedulable_list[i]->memMapIndex];

        //Next we need to check if enough AUs are available at the time current cycle + mem read latency cycles and enough BRAMs are available at the time when the AU operation ends
        if(schedulable_list[i]->op == "mac_sub" && future_BRAM_status_mac_nodes[dest_BRAMId] < hwUnits[1] && AU_status[0] < hwUnits[2]){

            //Updating the vector 'current_cycle_BRAM_status'
            for(int j=0;j<tmpBRAMStatus.size();j++){
                current_cycle_BRAM_status[j] = current_cycle_BRAM_status[j] + tmpBRAMStatus[j];
            }

            //Updating the vector 'mem_read_list'
            for(int j=0;j<tmp_mem_read_list.size();j++){
                mem_read_list.push_back(tmp_mem_read_list[j]);
                BRAM_Ids_mem_read.push_back(tmp_BRAM_Ids_mem_read[j]);
                mem_read_list_cycles_left.push_back(latencies[0]);

                //Updating 'tmpBRAMStatus'
                BRAM_Operation tmpOp;
                tmpOp.node_name = tmp_mem_read_list[j]->name;
                tmpOp.op = 0;//0 corresponds to memory read
                if(tmp_mem_read_list[j]->op == "wr"){
                    tmpOp.BRAMIndex = tmp_mem_read_list[j]->wrBRAMId;
                    tmpOp.addr = tmp_mem_read_list[j]->wrBRAMAddr;
                }
                else{
                    tmpOp.BRAMIndex = tmp_mem_read_list[j]->matPointer->BRAMInd[tmp_mem_read_list[j]->memMapIndex];
                    tmpOp.addr = tmp_mem_read_list[j]->matPointer->BRAMAddr[tmp_mem_read_list[j]->memMapIndex];
                }
                tmpOp.portIndex = tmp_BRAM_Ids_mem_read[j] - (hwUnits[1]*tmpOp.BRAMIndex);
                tmpOp.dinLoc = hwUnits[0]*hwUnits[1] + hwUnits[2] + hwUnits[3] + 1; //This is not required during memory read
                tmpOp.nodeId = tmp_mem_read_list[j]->nodeId;
                tmpOp.nodePtr = tmp_mem_read_list[j];
                tmp_memSchedule.push_back(tmpOp);
            }

            //incrementing the count of 'future_BRAM_status_mac_nodes' & 'AU_status'
            future_BRAM_status_mac_nodes[dest_BRAMId] = future_BRAM_status_mac_nodes[dest_BRAMId] + 1;
            //If mac and div latencies are same, change should be reflected in both the arrays
            if(latencies[2] == latencies[3]){
                future_BRAM_status_div_nodes[dest_BRAMId] = future_BRAM_status_mac_nodes[dest_BRAMId];
            }
            AU_status[0] = AU_status[0] + 1;

            //Updating the node in 'schedulable_list_cycles_left' to mem_read_latency
            schedulable_list_cycles_left[i] = cyclesLeft;
        }
        else if(schedulable_list[i]->op == "/" && future_BRAM_status_div_nodes[dest_BRAMId] < hwUnits[1] && AU_status[1] < hwUnits[3]){

            //Updating the vector 'current_cycle_BRAM_status'
            for(int j=0;j<tmpBRAMStatus.size();j++){
                current_cycle_BRAM_status[j] = current_cycle_BRAM_status[j] + tmpBRAMStatus[j];
            }

            //Updating the vector 'mem_read_list'
            for(int j=0;j<tmp_mem_read_list.size();j++){
                mem_read_list.push_back(tmp_mem_read_list[j]);
                BRAM_Ids_mem_read.push_back(tmp_BRAM_Ids_mem_read[j]);
                mem_read_list_cycles_left.push_back(latencies[0]);

                //Updating 'tmpBRAMStatus'
                BRAM_Operation tmpOp;
                tmpOp.node_name = tmp_mem_read_list[j]->name;
                tmpOp.op = 0;//0 corresponds to memory read
                if(tmp_mem_read_list[j]->op == "wr"){
                    tmpOp.BRAMIndex = tmp_mem_read_list[j]->wrBRAMId;
                    tmpOp.addr = tmp_mem_read_list[j]->wrBRAMAddr;
                }
                else{
                    tmpOp.BRAMIndex = tmp_mem_read_list[j]->matPointer->BRAMInd[tmp_mem_read_list[j]->memMapIndex];
                    tmpOp.addr = tmp_mem_read_list[j]->matPointer->BRAMAddr[tmp_mem_read_list[j]->memMapIndex];
                }
                tmpOp.portIndex = tmp_BRAM_Ids_mem_read[j] - (hwUnits[1]*tmpOp.BRAMIndex);
                tmpOp.dinLoc = hwUnits[0]*hwUnits[1] + hwUnits[2] + hwUnits[3] + 1; //This is not required during memory read
                tmpOp.nodeId = tmp_mem_read_list[j]->nodeId;
                tmpOp.nodePtr = tmp_mem_read_list[j];
                tmp_memSchedule.push_back(tmpOp);
            }

            //incrementing the count of 'future_BRAM_status_mac_nodes' & 'AU_status'
            future_BRAM_status_div_nodes[dest_BRAMId] = future_BRAM_status_div_nodes[dest_BRAMId] + 1;
            //If mac and div latencies are same, change should be reflected in both the arrays
            if(latencies[2] == latencies[3]){
                future_BRAM_status_mac_nodes[dest_BRAMId] = future_BRAM_status_div_nodes[dest_BRAMId];
            }
            AU_status[1] = AU_status[1] + 1;

            //Updating the node in 'schedulable_list_cycles_left' to mem_read_latency
            schedulable_list_cycles_left[i] = cyclesLeft;
        }
    }

    //Now we will schedule the "wr" nodes in 'schedulable_list'
    writeBackNodes.erase(writeBackNodes.begin(),writeBackNodes.end());
    newExecutableNodes.erase(newExecutableNodes.begin(),newExecutableNodes.end());
    correspondingChildren.erase(correspondingChildren.begin(),correspondingChildren.end());
    //This function will take mem_read_list and execution_list as arguments and return two vectors, the 1st list will contain nodes that can be put to execution list again, and another list containing nodes that have to be written back to memory.
    //We are interested in writeback nodes only
    findExecutableAndWriteBackNodes(execution_list,execution_list_cycles_left,mem_read_list,mem_read_list_cycles_left,newExecutableNodes,correspondingChildren,writeBackNodes,0,cyclesLeft);

    //Based on 'writeBackNodes' populate 'future_BRAM_status_wr_nodes'
    //A node of type "wr" is scheduled only if ther is enough BRAM ports available in current cycle and we can ensure that the "wr" node can be scheduled memory read latnecy cycles after the current cycle
    for(int i=0;i<writeBackNodes.size();i++){
        //Fetch the BRAMid where that node needs to be stored
        int destBRAMId;
        if(writeBackNodes[i]->op == "wr"){
            destBRAMId = writeBackNodes[i]->wrBRAMId;
        }
        else{
            destBRAMId = writeBackNodes[i]->matPointer->BRAMInd[writeBackNodes[i]->memMapIndex];
        }

        //Increment
        future_BRAM_status_wr_nodes[destBRAMId]  = future_BRAM_status_wr_nodes[destBRAMId] + 1;
    }

    for(int i=schedulable_list.size()-1;i>=0;i--){
        //Skip if the corresponding index in 'schedulable_list_cycles_left' is not -1 or node type is not "wr"
        if(schedulable_list_cycles_left[i] != -1 || schedulable_list[i]->op != "wr"){
            continue;
        }

        //Check if the children is already there in memory read list
        if(checkIfNodeInList(mem_read_list,schedulable_list[i]->children[0]->nodeId) == true){
        	schedulable_list_cycles_left[i] = cyclesLeft;
        	continue;
        }

        int curr_dest_BRAMId = schedulable_list[i]->children[0]->matPointer->BRAMInd[schedulable_list[i]->children[0]->memMapIndex];
        int future_dest_BRAMId = schedulable_list[i]->wrBRAMId;
        if(current_cycle_BRAM_status[curr_dest_BRAMId] < hwUnits[1] && future_BRAM_status_wr_nodes[future_dest_BRAMId] < hwUnits[1]){
            //Updating 'mem_read_list'
            mem_read_list.push_back(schedulable_list[i]->children[0]);
            BRAM_Ids_mem_read.push_back(hwUnits[1]*curr_dest_BRAMId + current_cycle_BRAM_status[curr_dest_BRAMId]);
            mem_read_list_cycles_left.push_back(latencies[0]);

            //Updating 'tmpBRAMStatus'
            BRAM_Operation tmpOp;
            tmpOp.node_name = schedulable_list[i]->children[0]->name;
            tmpOp.op = 0;//0 corresponds to memory read
            tmpOp.BRAMIndex = curr_dest_BRAMId;
            tmpOp.portIndex = current_cycle_BRAM_status[curr_dest_BRAMId];
            tmpOp.addr = schedulable_list[i]->children[0]->matPointer->BRAMAddr[schedulable_list[i]->children[0]->memMapIndex];
            tmpOp.dinLoc = hwUnits[0]*hwUnits[1] + hwUnits[2] + hwUnits[3] + 1; //This is not required during memory read
            tmpOp.nodeId = schedulable_list[i]->children[0]->nodeId;
            tmpOp.nodePtr = schedulable_list[i]->children[0];
            tmp_memSchedule.push_back(tmpOp);

            current_cycle_BRAM_status[curr_dest_BRAMId] = current_cycle_BRAM_status[curr_dest_BRAMId] + 1;
            future_BRAM_status_wr_nodes[future_dest_BRAMId] = future_BRAM_status_wr_nodes[future_dest_BRAMId] + 1;

            //Updating the node in 'schedulable_list_cycles_left' to mem_read_latency
            schedulable_list_cycles_left[i] = cyclesLeft;
        }
    }

}

void scheduleNoReg_exp(Graph & lGraph, HardwareConfig & hwConfig, Schedule &schedule){
    Node tmpNode;
    bool scheduling_finished = 0;

    //Fetching some useful information from 'hwConfig' so that the schedule generated can adjust accordingly
    vector<int> hwUnits;//index 0 = no. of BRAM units, 1 = no. of ports of each BBRAM, 2 = no. of mac units, 3 = no. of div units
    hwUnits.push_back(hwConfig.BRAMs.size());
    hwUnits.push_back(hwConfig.BRAMs[0]->ports);
    hwUnits.push_back(hwConfig.numMACUnits);
    hwUnits.push_back(hwConfig.AUs.size() - hwConfig.numMACUnits);

    vector<int> latencies; // index 0 = mem_read latency, 1 = mem_write latency, 2 = mac latency, 3 = div latency,
    latencies.push_back(hwConfig.BRAMs[0]->readLatency);
    latencies.push_back(hwConfig.BRAMs[0]->writeLatency);

    //Fetching the latencies of "mac_sub" and "/" nodes
    vector<string> ops = {"mac_sub","/"};
    vector<int> mac_div_latencies = getAULatency(ops,hwConfig);
    latencies.push_back(mac_div_latencies[0]);
    latencies.push_back(mac_div_latencies[1]);

    //Important queues that would be used up in scheduling
    vector<Node *> ready_list;

    vector<Node *> execution_list;//Holds the list of nodes currently executing
    vector<int> execution_list_cycles_left;//Stores the info on number of cycles left for the execution of a particular node wrt the current node. Size of 'execution_list' and 'execution_list_cycles_left' is same.
    //'AU_Ids' keeps a track of which node was assigned to which Arithmetic unit. The size of this list is same as the size of 'execution_list'
    //Suppose there are 4 macs and 7 divs. Id 0,1,2,3 corresponds to Macs and Id 4,5,6,7,8,9,10 correspond to div.
    vector<int> AU_Ids;

    vector<Node *> mem_read_list;//Holds the list of node undergoing memory read
    vector<int> mem_read_list_cycles_left;
    //'BRAM_Ids_mem_read' keep a track of BRAM ports used for memory write for a particular cycle.
    //Suppose ther are 3 BRAMs having 5 ports each. Id 0 to 4 corresponds to BRAM 1, Id 5 to 9 correspond to BRAM 2, Id 10 to 14 correspond to BRAM 3
    vector<int> BRAM_Ids_mem_read;

    vector<Node *> mem_write_list;//Holds the list of node undergoing memory write
    vector<int> mem_write_list_cycles_left;
    //'BRAM_Ids_mem_write' keep a track of BRAM ports used for memory write for a particular cycle.
    //Suppose ther are 3 BRAMs having 5 ports each. Id 0 to 4 corresponds to BRAM 1, Id 5 to 9 correspond to BRAM 2, Id 10 to 14 correspond to BRAM 3
    vector<int> BRAM_Ids_mem_write;

    //Stores the list of nodes that can be scheduled, because the inputs required by that node is available in memory.
    vector<Node *> schedulable_list;
    //-1 = node is sitting idle inn this list, anything else other than -1 = the operand node for nodes in schedulable list have been put up for mem read intentionally. 0 = time has come to schedule the node in the current cycle
    // 'schedulable_list_cycles_left' is necessary because if for some reason the node which was planned to be scheduled could not get scheduled, we can set the counter to -1 again
    //This situation can occur in two cases. 1st if operands are fetched for some nodes in the schedulable_list and an outside node with same priority is schedulable using some of those nodes. 2nd when the difference in latenties of mac and div units are less than (mem_read_latency-1)
    vector<int> schedulable_list_cycles_left;

    //Adding appripriate number of elements in the vector 'nodeEvalStatus' and setting them to 0.
    for(auto x : lGraph.nodes){
        tmpNode = x.second;
        if(tmpNode.op == "mac_sub"){
            for(int i=0;i<tmpNode.children.size()/2;i++){
                lGraph.nodes[x.first].nodeEvalStatus.push_back(0);
            }
        }
    }

    //Filling the ready queue with nodes with op='rd' so that scheduling can be started. And setting the readyBit to true. And latestIntermediateResultAvailable to 1
    for(auto x : lGraph.nodes){
        tmpNode = x.second;
        if(tmpNode.op == "rd"|| tmpNode.op == "const"){
            lGraph.nodes[x.first].readyBit = true;
            lGraph.nodes[x.first].latestIntermediateResultAvailable = 1;
            ready_list.push_back(&lGraph.nodes[x.first]);
        }
    }

    //Starting the scheduling algorithm
    while(schedulingStatusCheck(lGraph)==false){
        //increment the cycle count
        current_cycle += 1;
        if(current_cycle == 352){
            //break;
        	//cout << "reached\n" << endl;
        }

        //Decrease the no. of cycles left in execution_list, mem_read_list and mem_write_list by 1
        decreaseCyclesLeft(execution_list_cycles_left,mem_read_list_cycles_left,mem_write_list_cycles_left,schedulable_list_cycles_left);

        //Based on the nodes whose memory write is complete(cycle_left has become 0), updating the 'readyBit'(parameter of Node)and 'ready_list'
        //This function also removes those nodes from the 'mem_write_list' which have completed memory write.
        //This function also updates the 'latestIntermediateResultAvailable' to 1.
        update_readyBit_ready_list(mem_write_list,mem_write_list_cycles_left,BRAM_Ids_mem_write,ready_list);


        //Based on the ready_list generated, updating the schedulable queue.
        //For each node in the ready list, for each parent of that node, check if the children are ready i.e. 'readyBit' = true. If yes put that parent node in 'schedulable_list'
        //If the node in 'ready_list' is of type 'mac_sub', then 1st check if the 'readyBit' = true. If true then for each parent of that node, check if the children are ready i.e. 'readyBit' = true. If yes put that parent node in 'schedulable_list'.
        //If not then for the same 'mac_sub' node check for which mul pair 'nodeEvalStatus' = 0. Then check if the 'readyBit' = true for those corresponding childrens. If yes put that 'mac_sub' node in 'schedulable_list'.
        //Also the schedulable_list is checked for any dublicates and ready_list is cleared.
        //Nodes in the schedulable_list are arranged in ascending order of priorities
        update_schedule_list(schedulable_list,schedulable_list_cycles_left, ready_list);
        //cout << "schedulable list size before scheduling: " << schedulable_list.size() << endl;

        //Based on 'mem_read_list' and 'execution_list'(whose cycles_left has become 0) add new nodes in 'execution_list' and 'mem_write_list'
        //Remove those nodes from the 'mem_read_list' and 'execution_list' whose cycles_left has become 0
        //The second last parameter is mode(two modes 0 and 1), and the last parameter is cyclesLeft.
        update_mem_write_and_execution_list(execution_list,execution_list_cycles_left,AU_Ids,schedulable_list,schedulable_list_cycles_left,mem_write_list,mem_write_list_cycles_left,BRAM_Ids_mem_write,mem_read_list,mem_read_list_cycles_left,BRAM_Ids_mem_read,latencies,hwUnits,schedule,0,0);

        //Reset the cycles_left to -1 if some node in 'schedulable_list' which was to be scheduled in the current cycle could not have been scheduled for some reason
        reset_schedulable_list_status(schedulable_list_cycles_left);

        //The next function serves two purpose
        //The First task is to update the 'mem_read_list' based on 'execution_list'. This task focuses on nodes that will finish execution memory read latency cycles after the current cycle. The goal is to fetch additional nodes so that they are available at the right time so that without waisting cycles we can schedule the next node.
        //In the First task, we schedule the memory reads only if we are sure that there will be enough AUs memory read latency cycle after the current cycle and there would be enough BRAM ports when the AUs operations scheduled after current cycle + mem read latency cycle ends.
        //In the second task, we try to schedule nodes from 'schedulable_list' based on priority. First we check if any of the children node of a node from 'schedulable_list' that we are planning to execute already exists in the 'mem_read_list' from First task. Then we put the remaining children node necessary for execution in the 'mem_read_list'. In doing so we make sure that enough AUs are available after the time current cycle + mem read latency cycle and enough BRAM ports are available after the execution of the node finishes. This ensures that we are not doing unnecessary memory reads
        //In performing the two tasks we make sure that we are not using more BRAM ports than what is available to us in the current cycle.
        update_mem_read_list(execution_list,execution_list_cycles_left,mem_write_list,mem_write_list_cycles_left,mem_read_list,mem_read_list_cycles_left,BRAM_Ids_mem_read,schedulable_list,schedulable_list_cycles_left,latencies,schedule,hwUnits,1,latencies[0]);

        //cout << "schedulable list size after scheduling: " << schedulable_list.size() << endl;
        //cout << "mem read list size: " << mem_read_list.size() << endl;

        //Test
        /*for(auto x : lGraph.nodes){
            tmpNode = x.second;
            if(tmpNode.name.substr(0,8) == "mac_subL"){
                cout << tmpNode.name << ", ";
                cout << tmpNode.parents[0]->name << endl;
            }
        }*/


    }//While end

}
