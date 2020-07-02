################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
../src/cppFiles/CCS.cpp \
../src/cppFiles/Graph.cpp \
../src/cppFiles/Schedule.cpp \
../src/cppFiles/main.cpp \
../src/cppFiles/sparseLU.cpp 

OBJS += \
./src/cppFiles/CCS.o \
./src/cppFiles/Graph.o \
./src/cppFiles/Schedule.o \
./src/cppFiles/main.o \
./src/cppFiles/sparseLU.o 

CPP_DEPS += \
./src/cppFiles/CCS.d \
./src/cppFiles/Graph.d \
./src/cppFiles/Schedule.d \
./src/cppFiles/main.d \
./src/cppFiles/sparseLU.d 


# Each subdirectory must supply rules for building sources it contributes
src/cppFiles/%.o: ../src/cppFiles/%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ -I"/home/ricky/eclipse-workspace/LUD/src/cppFiles" -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


