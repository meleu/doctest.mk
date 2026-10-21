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

# Settings
# ---------------------------------------------------------------

CXX         := clang++
CXXFLAGS    := -std=c++23 -Wall -Wextra -Wpedantic
DOCTEST_DIR := /usr/include/doctest
INCLUDES    := -isystem $(DOCTEST_DIR)
DEPFLAGS    := -MMD -MP

# Which file is which, by naming convention
# ---------------------------------------------------------------

TEST_SRCS := $(wildcard *_test.cpp)
LIB_SRCS  := $(filter-out main.cpp $(TEST_SRCS), $(wildcard *.cpp))

TEST_OBJS := doctest_main.o $(TEST_SRCS:.cpp=.o) $(LIB_SRCS:.cpp=.o)
APP_OBJS  := main.o $(LIB_SRCS:.cpp=.o)

# `make test` / `make run`
# Pass arguments with ARGS, e.g.: make test ARGS='-tc="add*"'
# ---------------------------------------------------------------

test: tests
	./tests $(ARGS)

run: app
	./app $(ARGS)

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

# doctest's own main(), compiled straight from its header
doctest_main.o: $(DOCTEST_DIR)/doctest.h
	$(CXX) $(CXXFLAGS) -x c++ -DDOCTEST_CONFIG_IMPLEMENT_WITH_MAIN -c $< -o $@

# Housekeeping
# ---------------------------------------------------------------

clean:
	rm -f *.o *.d tests app

.PHONY: test run clean

