INCLUDE_DIR ?= $(HOME)/.local/include

.PHONY: install
install:
	mkdir -p $(INCLUDE_DIR)
	cp doctest.mk $(INCLUDE_DIR)/doctest.mk
