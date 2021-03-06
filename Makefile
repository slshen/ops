BUILD_ROOT:=$(shell pwd)
BIN:=$(BUILD_ROOT)/bin
TOOLS:=$(BUILD_ROOT)/tools
TERRAFORM_VERSION:=0.11.3
TERRAFORM=$(shell $(TOOLS)/get-terraform.sh $(TERRAFORM_VERSION) $(BIN))

.PHONY: clean setup

setup: config.mk

config.mk: Makefile
	echo TERRAFORM=$(TERRAFORM) > config.mk
	echo BUILD_ROOT=$(BUILD_ROOT) >> config.mk

clean:
	rm -rf $(BIN) config.mk

