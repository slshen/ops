.PHONY: gen plan init get apply

gen: config.tf state.tf

state.tf: $(BUILD_ROOT)/state-template.tf
	sed -e "s/@name@/$$(basename $$(pwd))/g" $< > $@

config.tf: $(BUILD_ROOT)/config.tf
	cp $(BUILD_ROOT)/config.tf .

plan: gen
	$(TERRAFORM) plan $(TERRAFORM_OPTS)

init: gen
	$(TERRAFORM) init $(TERRAFORM_OPTS)

get: gen
	$(TERRAFORM) get $(TERRAFORM_OPTS)

apply: gen
	$(TERRAFORM) apply $(TERRAFORM_OPTS)
