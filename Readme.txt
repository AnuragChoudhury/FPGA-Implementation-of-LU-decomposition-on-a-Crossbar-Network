For brief explanation of the project I would recommend watching the video tutorials.

The Makefile and Eclipse project are the same. The Eclipse project is provided for easier debugging.

This project uses MATLAB and Python to do the preprocessing of matrix. The pre-processed matrices are stored in folder scheduler/test/exported in case of the Makefile project and LUD/src/test/exported in case of Eclipse project. The project uploaded here already contains the pre-processed matrices in the exported folder and hence you do not need MATLAB and python to run this project with the matrices already provided in this project.
Hence I have commented out the 2 pre-processing steps in the Makefile project i.e. (cd Scheduler/cppFiles; make buildPreprocessTests), (cd Scheduler/cppFiles; make preprocessTests)

If you want to work on your own matrix, you have to put the .mat file in scheduler/test folder of the Makefile project and do the pre-processing.

For some matrices, the scheduler can take a long time. To have a status report, you can uncomment the "cout" in the function "schedulingStatusCheck" present in file scheduler/cppFiles/Schedule.cpp(in case of Makefile project) and LUD/src/cppFiles/Schedule.cpp(in case of Eclipse project)
