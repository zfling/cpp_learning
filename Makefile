CUR_DIR = $(shell pwd)
INC_DIR = $(CUR_DIR)/include
CODE_DIR = $(CUR_DIR)/code
GTEST_DIR = $(CUR_DIR)/gtest
TESTCASE_DIR = $(CUR_DIR)/testcase
 
CC = g++
CCFLAGS = -g -Wall -I$(INC_DIR)
TARGET = runtest

SRC = ${wildcard ${CUR_DIR}/*.cpp} \
      ${wildcard ${CODE_DIR}/*.cpp} \
      ${wildcard ${TESTCASE_DIR}/*.cpp}
	  
OBJ = ${patsubst %.cpp, %.o, $(SRC)}

${TARGET}: $(OBJ)
	$(CC) $(OBJ) -o $@ -I$(INC_DIR) -L$(GTEST_DIR) -lgtest_main -lgtest -lpthread
	
$(OBJ):%.o:%.cpp
	$(CC) $(CCFLAGS) -c $< -o $@

.PHONY: clean
clean:
	rm -rf $(TARGET) *.o testcase/*.o code/*.o
	