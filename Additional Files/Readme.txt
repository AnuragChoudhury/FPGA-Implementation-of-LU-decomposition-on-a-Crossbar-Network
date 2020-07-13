
While using QUAD PORT BRAMs, you can either use the synchronous or the asynchronous QUAD PORT BRAM wrapper. Both are provided in this folder. Whichever wrapper you want to use just copy paste the corresponding code in the required file. 
In whichever project I have used QUAD Port BRAM, I have used synchronous QUAD PORT BRAM wrapper as it is synthesizable. 
If you want to use asynchronous QUAD PORT BRAM wrapper, it can only work in simulation. If you do synthesis, FPGA will fail to meet timing. To understand why this happens, please read my report.