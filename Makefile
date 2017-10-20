BASH:=$(which bash)
DOCKER:=$(which docker)

.DEFAULT_GOAL := help

mutt:
	docker run \
		-v $(PWD)/configs/davmail.properties:/root/.davmail.properties \
		-v $(PWD)/configs/offlineimaprc:/root/.offlineimaprc \
		-v $(PWD)/configs/muttrc:/root/.muttrc \
		-v $(PWD)/configs/msmtprc/:/root/.msmtprc \
		-v $(PWD)/mutt:/root/.mutt \
		-v $(PWD)/Maildir:/root/Maildir \
		-v $(PWD)/wrapper.bash:/wrapper.bash \
		-it exchange2mutt /wrapper.bash

ithappen: ## Creates all the annoying config / systemd files for you
	@$$BASH prompter.bash
	@$$BASH templatizer.bash
	@$$DOCKER build . -t exchange2mutt

help:
	@printf "\033[0;32m Welcome to the exchange to mutt repo!\033[0m\n"
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: mutt
