BASH:=$(which bash)

.DEFAULT_GOAL := help

ithappen: ## Creates all the annoying config / systemd files for you
	@$$BASH prompter.bash
	@$$BASH bash

help:
	@printf "\033[0;32m Welcome to the exchange to mutt repo!\033[0m\n"
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

