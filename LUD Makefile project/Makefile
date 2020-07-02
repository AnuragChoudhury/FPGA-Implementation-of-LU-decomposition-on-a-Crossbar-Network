
TEST_MATRIX =

.PHONY: clean preprocess process all cleanall cleanup

all: cleanall preprocess process cleanup

cleanall:
	(cd Scheduler/cppFiles; make cleanall)

preprocess:
	#(cd Scheduler/cppFiles; make buildPreprocessTests)
	#(cd Scheduler/cppFiles; make preprocessTests)

process:
	(cd Scheduler/cppFiles; make all)
	(cd Scheduler/cppFiles; ./main $(TEST_MATRIX))

cleanup:
	(cd Scheduler/cppFiles; make clean)
	(cd Scheduler/cppFiles; make cleanPreprocess)
	#(cd Scheduler/test; rm -f *.csv)
	#(rm -rf Scheduler/test/exported)
