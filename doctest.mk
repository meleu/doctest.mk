# Shared build rules for small C++ projects tested with doctest.
#
# Save this file somewhere and then include it from a project's Makefile.
#
# What I use myself: save it in `~/.local/include/doctest.mk` and then
# in projects I put this in the Makefile:
# ```
# include $(HOME)/.local/include/doctest.mk
# ```
#
# Conventions:
#   *_test.cpp      -> the `tests` binary (doctest provides its main())
#   main.cpp        -> the `app` binary
#   any other .cpp  -> domain code, linked into both
#
# Everything generated goes to $(BUILD_DIR).

# ---------------------------------------------------------------
# Settings
# ---------------------------------------------------------------

# Choose the C++ compiler
CXX         := clang++

# Language standard and warnings: -Wall/-Wextra turn on most useful
# warnings, -Wpedantic flags anything that isn't standard C++
CXXFLAGS    ?= -std=c++23 -Wall -Wextra -Wpedantic

# Where doctest.h lives (the path used by distro packages)
DOCTEST_DIR ?= /usr/include/doctest

# -isystem (instead of -I) treats doctest as a system header, so its
# own code doesn't trigger our warnings
INCLUDES    ?= -isystem $(DOCTEST_DIR)

# Make the compiler write a .d file next to each .o listing the headers
# it included, so editing a header rebuilds what depends on it.
# -MMD : skips system headers;
# -MP  : adds empty targets for each header so deleting one doesn't
#        break the build
DEPFLAGS    := -MMD -MP

# Directory for all generated files (objects, .d files, binaries)
BUILD_DIR   := build

# Plain `make` runs the tests, unless your Makefile picks another goal
.DEFAULT_GOAL ?= test

# ---------------------------------------------------------------
# Which file is which, by naming convention
# ---------------------------------------------------------------

TEST_SRCS := $(wildcard *_test.cpp)
LIB_SRCS  := $(filter-out main.cpp $(TEST_SRCS), $(wildcard *.cpp))

LIB_OBJS  := $(LIB_SRCS:%.cpp=$(BUILD_DIR)/%.o)
TEST_OBJS := $(BUILD_DIR)/doctest_main.o $(TEST_SRCS:%.cpp=$(BUILD_DIR)/%.o) $(LIB_OBJS)
APP_OBJS  := $(BUILD_DIR)/main.o $(LIB_OBJS)

# ---------------------------------------------------------------
# `make test` / `make run`
# Pass arguments with ARGS, e.g.: make test ARGS='-tc="add*"'
# ---------------------------------------------------------------

test: $(BUILD_DIR)/tests
	./$< $(ARGS)

run: $(BUILD_DIR)/app
	./$< $(ARGS)

# ---------------------------------------------------------------
# Link (set LDFLAGS / LDLIBS in your Makefile for extra libraries)
# ---------------------------------------------------------------

$(BUILD_DIR)/tests: $(TEST_OBJS)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $^ $(LDLIBS) -o $@

$(BUILD_DIR)/app: $(APP_OBJS)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $^ $(LDLIBS) -o $@

# ---------------------------------------------------------------
# Compile: one pattern rule for every .cpp
# ---------------------------------------------------------------

$(BUILD_DIR)/%.o: %.cpp | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) $(DEPFLAGS) $(INCLUDES) -c $< -o $@

-include $(wildcard $(BUILD_DIR)/*.d)

# doctest's own main(), compiled straight from its header
$(BUILD_DIR)/doctest_main.o: $(DOCTEST_DIR)/doctest.h | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -x c++ -DDOCTEST_CONFIG_IMPLEMENT_WITH_MAIN -c $< -o $@

# ---------------------------------------------------------------
# Housekeeping
# ---------------------------------------------------------------

$(BUILD_DIR):
	mkdir -p $@

clean:
	rm -rf $(BUILD_DIR)

# Add $(BUILD_DIR)/ to .gitignore, unless it's already there
gitignore:
	@if ! grep -qxF '$(BUILD_DIR)/' .gitignore 2>/dev/null; then \
		[ -s .gitignore ] && [ -n "$$(tail -c1 .gitignore)" ] && echo >> .gitignore; \
		echo '$(BUILD_DIR)/' >> .gitignore; \
		echo 'Added $(BUILD_DIR)/ to .gitignore'; \
	fi

.PHONY: test run clean gitignore

