# Shared build rules for small C++ projects tested with doctest.
# Use it from a project's Makefile with:
# ```Makefile
# include $(HOME)/.local/include/doctest.mk
# ```
#
# Conventions:
#   test_main.cpp, *_test.cpp  -> the `tests` binary
#   main.cpp                   -> the `app` binary
#   any other .cpp             -> domain code, linked into both

# Settings
# ---------------------------------------------------------------

CXX         := clang++
CXXFLAGS    := -std=c++23 -Wall -Wextra -Wpedantic
DOCTEST_DIR := /usr/include/doctest
INCLUDES    := -isystem $(DOCTEST_DIR)
DEPFLAGS    := -MMD -MP

# Which file is which, by naming convention
# ---------------------------------------------------------------

TEST_SRCS := test_main.cpp $(wildcard *_test.cpp)
LIB_SRCS  := $(filter-out main.cpp $(TEST_SRCS), $(wildcard *.cpp))

TEST_OBJS := $(TEST_SRCS:.cpp=.o) $(LIB_SRCS:.cpp=.o)
APP_OBJS  := main.o $(LIB_SRCS:.cpp=.o)

# `make test` / `make run`
# ---------------------------------------------------------------

test: tests
	./tests

run: app
	./app

# Link
# ---------------------------------------------------------------

tests: $(TEST_OBJS)
	$(CXX) $(CXXFLAGS) $^ -o $@

app: $(APP_OBJS)
	$(CXX) $(CXXFLAGS) $^ -o $@

# Compile: one pattern rule for every .cpp
# ---------------------------------------------------------------

%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(DEPFLAGS) $(INCLUDES) -c $< -o $@

-include $(wildcard *.d)

# Housekeeping
# ---------------------------------------------------------------

clean:
	rm -f *.o *.d tests app

.PHONY: test run clean

