BUILD_ROOT:=$(shell pwd)
BIN:=$(BUILD_ROOT)/bin
TOOLS:=$(BUILD_ROOT)/tools
TERRAFORM_VERSION=0.11.13
TERRAFORM_ARCH=amd64
TERRAFORM=$(BIN)/terraform-$(TERRAFORM_VERSION)

.PHONY: get-terraform clean

get-terraform:
	if [ ! -e $(TERRAFORM) ]; then \
	  mkdir -p $(BIN); \
	  curl -L -o $(TERRAFORM).zip https://releases.hashicorp.com/terraform/$(TERRAFORM_VERSION)/terraform_$(TERRAFORM_VERSION)_$$(uname -s | tr '[A-Z]' '[a-z]')_$(TERRAFORM_ARCH).zip; \
          cd $(BIN) && unzip $(TERRAFORM).zip && mv terraform $(TERRAFORM); \
	  chmod +x $(TERRAFORM); \
	fi

plan-%:
	$(TOOLS)/plan.sh $@

clean:
	rm -rf $(BIN)
