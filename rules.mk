.PHONY: gen plan init get apply

gen: config.tf state.tf terraform.tfvars

terraform.tfvars:
	if [ -f terraform.tfvars ]; then \
	  if find terraform.tfvars -mtime -1 > /dev/null; then exit 0; fi \
        fi; \
	echo my_ip = \"$$(curl -s ifconfig.me)\" > terraform.tfvars

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
