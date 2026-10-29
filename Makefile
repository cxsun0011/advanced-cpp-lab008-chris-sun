CXX := g++
CXXFLAGS := -std=c++17 -Wall -Itests -Isrc -Iinclude

SRC_DIR := src
TEST_DIR := tests
BUILD_DIR := build

# All src files except main.cpp
SRC := $(filter-out $(SRC_DIR)/main.cpp,$(wildcard $(SRC_DIR)/*.cpp))
OBJ := $(patsubst $(SRC_DIR)/%.cpp,$(BUILD_DIR)/%.o,$(SRC))

MAIN_OBJ := $(BUILD_DIR)/main.o
EXECUTABLE := $(BUILD_DIR)/main

MAIN_SRC := $(wildcard $(SRC_DIR)/main.cpp)
ifneq ($(strip $(MAIN_SRC)),)
  MAIN_OBJ := $(BUILD_DIR)/main.o
  EXECUTABLE := $(BUILD_DIR)/main
else
  MAIN_OBJ :=
  EXECUTABLE :=
endif
# Test sources (these contain Catch2 main)
TEST_SRC := $(wildcard $(TEST_DIR)/*.cpp)
TEST_OBJ := $(patsubst $(TEST_DIR)/%.cpp,$(BUILD_DIR)/%.o,$(TEST_SRC))
TEST_EXECUTABLE := $(BUILD_DIR)/test.out

.PHONY: all clean run test

all: test

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Compile program .cpp files (except main)
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.cpp | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Compile main.cpp
$(BUILD_DIR)/%.o: $(TEST_DIR)/%.cpp | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Compile test .cpp files
ifneq ($(strip $(MAIN_SRC)),)
$(MAIN_OBJ): $(MAIN_SRC) | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Link main program
$(EXECUTABLE): $(MAIN_OBJ) $(OBJ)
	$(CXX) $(CXXFLAGS) $^ -o $@
endif

# Build and run tests — IMPORTANT: DO NOT LINK main.o
test: $(OBJ) $(TEST_OBJ)
	$(CXX) $(CXXFLAGS) $(OBJ) $(TEST_OBJ) -o $(TEST_EXECUTABLE)
	./$(TEST_EXECUTABLE)

run: $(EXECUTABLE)
	./$(EXECUTABLE)

clean:
	rm -rf $(BUILD_DIR)

