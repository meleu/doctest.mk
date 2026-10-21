#include <doctest/doctest.h>

#include "add.h"

TEST_CASE("add()") { CHECK(add(1, 1) == 2); }
