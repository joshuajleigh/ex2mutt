DOCKER:=$(which docker)

.DEFAULT_GOAL := help

from_scratch_check_for_active: image
	-@docker ps | awk '{ while(getline ==1)if($$NF=="ex2mutt"){err=0; exit err} else {err=1} } {exit err}' && \
	docker attach ex2mutt

from_scratch_check_for_stopped: from_scratch_check_for_active
	-@docker ps | awk '{ while(getline ==1)if($$NF=="ex2mutt"){err=1; exit err} else {err=0} } {exit err}' && \
	docker start ex2mutt && \
	docker attach ex2mutt

mutt_from_scratch: from_scratch_check_for_stopped ## recreate the container (slower=more fun?)
	-@docker run \
		--name="ex2mutt" \
		--env="DISPLAY" \
		-e ENDUSER=$(USERNAME) \
		-v /etc/localtime:/etc/localtime \
		-v /etc/group:/etc/group:ro \
		-v /etc/passwd:/etc/passwd:ro \
		-v /etc/shadow:/etc/shadow:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix:rw \
		-v $(PWD)/Maildir:/home/$(USERNAME)/Maildir \
		-it ex2mutt /bin/sh

check_for_active:
	-@docker ps | awk '{ while(getline ==1)if($$NF=="ex2mutt"){err=0; exit err} else {err=1} } {exit err}' && \
	docker attach ex2mutt

check_for_stopped: check_for_active
	-@docker ps | awk '{ while(getline ==1)if($$NF=="ex2mutt"){err=1; exit err} else {err=0} } {exit err}' && \
	docker start ex2mutt && \
	docker attach ex2mutt

mutt: check_for_stopped ## start using mutt
	-@docker run \
		--name="ex2mutt" \
		--env="DISPLAY" \
		-e ENDUSER=$(USERNAME) \
		-v /etc/localtime:/etc/localtime \
		-v /etc/group:/etc/group:ro \
		-v /etc/passwd:/etc/passwd:ro \
		-v /etc/shadow:/etc/shadow:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix:rw \
		-v $(PWD)/Maildir:/home/$(USERNAME)/Maildir \
		-it joshuajleigh/ex2mutt ./wrapper.sh

testing: ## starts in shell for testing, etc
	-@docker run \
		--name="ex2mutt-testing" \
		--env="DISPLAY" \
		-e ENDUSER=$(USERNAME) \
		-v /etc/localtime:/etc/localtime \
		-v /etc/group:/etc/group:ro \
		-v /etc/passwd:/etc/passwd:ro \
		-v /etc/shadow:/etc/shadow:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix:rw \
		-v $(PWD)/Maildir:/home/$(USERNAME)/Maildir \
		-it joshuajleigh/ex2mutt /bin/sh

image: ## build / rebuild the docker container
	docker build . -t exchange2mutt

clean: ## remove any containers that currently exist
	docker stop ex2mutt
	docker rm ex2mutt

help:
	@printf "\033[0;32m Welcome to the exchange to mutt repo!\033[0m\n"
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: mutt testing
