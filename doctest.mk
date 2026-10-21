# Shared build rules for small C++ projects tested with doctest.
# Use it from a project's Makefile with:
# ```Makefile
# include $(HOME)/.local/include/doctest.mk
# ```
#
# Conventions:
#   *_test.cpp      -> the `tests` binary (doctest provides its main())
#   main.cpp        -> the `app` binary
#   any other .cpp  -> domain code, linked into both
#
# Everything generated goes to $(BUILD_DIR).

# Settings
# ---------------------------------------------------------------

CXX         := clang++
CXXFLAGS    := -std=c++23 -Wall -Wextra -Wpedantic
DOCTEST_DIR := /usr/include/doctest
INCLUDES    := -isystem $(DOCTEST_DIR)
DEPFLAGS    := -MMD -MP
BUILD_DIR   := build

# Which file is which, by naming convention
# ---------------------------------------------------------------

TEST_SRCS := $(wildcard *_test.cpp)
LIB_SRCS  := $(filter-out main.cpp $(TEST_SRCS), $(wildcard *.cpp))

LIB_OBJS  := $(LIB_SRCS:%.cpp=$(BUILD_DIR)/%.o)
TEST_OBJS := $(BUILD_DIR)/doctest_main.o $(TEST_SRCS:%.cpp=$(BUILD_DIR)/%.o) $(LIB_OBJS)
APP_OBJS  := $(BUILD_DIR)/main.o $(LIB_OBJS)

# `make test` / `make run`
# Pass arguments with ARGS, e.g.: make test ARGS='-tc="add*"'
# ---------------------------------------------------------------

test: $(BUILD_DIR)/tests
	./$< $(ARGS)

run: $(BUILD_DIR)/app
	./$< $(ARGS)

# Link (set LDFLAGS / LDLIBS in your Makefile for extra libraries)
# ---------------------------------------------------------------

$(BUILD_DIR)/tests: $(TEST_OBJS)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $^ $(LDLIBS) -o $@

$(BUILD_DIR)/app: $(APP_OBJS)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $^ $(LDLIBS) -o $@

# Compile: one pattern rule for every .cpp
# ---------------------------------------------------------------

$(BUILD_DIR)/%.o: %.cpp | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) $(DEPFLAGS) $(INCLUDES) -c $< -o $@

-include $(wildcard $(BUILD_DIR)/*.d)

# doctest's own main(), compiled straight from its header
$(BUILD_DIR)/doctest_main.o: $(DOCTEST_DIR)/doctest.h | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -x c++ -DDOCTEST_CONFIG_IMPLEMENT_WITH_MAIN -c $< -o $@

# Housekeeping
# ---------------------------------------------------------------

$(BUILD_DIR):
	mkdir -p $@

clean:
	rm -rf $(BUILD_DIR)

.PHONY: test run clean

