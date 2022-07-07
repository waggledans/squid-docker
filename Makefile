.PHONY: build
.DEFAULT_GOAL := help

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([0-9a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef

export PRINT_HELP_PYSCRIPT
PYTHONPATH := $(shell pwd)

help: ## prints (this) help message
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

build: ## builds docker image
	@docker build --tag=dans/squid:5.6 .
run: ## runs docker container
	@docker run -p 3128:3128 -it --name squid --rm dans/squid:5.6
shell: ## starts a container and execs into its shell
	@docker run -p 3128:3128 -it --name squid --rm dans/squid:5.6 -- bash
