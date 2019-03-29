BUILD_ROOT:=$(shell pwd)
BIN:=$(BUILD_ROOT)/bin
TOOLS:=$(BUILD_ROOT)/tools
TERRAFORM_VERSION:=0.11.3
TERRAFORM=$(shell $(TOOLS)/get-terraform.sh $(TERRAFORM_VERSION) $(BIN))

.PHONY: clean

default:
	@echo ""

plan-%:
	$(TOOLS)/tf-plan.sh $@

clean:
	rm -rf $(BIN)
