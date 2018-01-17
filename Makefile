.DEFAULT_GOAL := help

USER=$(shell id -u)
FULLNAME=$(shell cat /etc/passwd | grep $(USER) | awk -F ":" '{print $$5}')


image: ## build / rebuild the docker container
	docker build . -t exchange2mutt

mutt_from_scratch: image ## recreate the container (slower=more fun?)
	-@docker run --rm \
		--name="ex2mutt" \
		--env="DISPLAY" \
		-e USERID=$(USER) \
		-e FULLNAME="$(FULLNAME)" \
		-v /etc/localtime:/etc/localtime \
		-v /tmp/.X11-unix:/tmp/.X11-unix:rw \
		-v ~/Maildir:/home/user/Maildir \
		-it exchange2mutt

testing: ## starts in shell for testing, etc
	-@docker run --rm \
		-it --entrypoint="/bin/bash"
		--env="DISPLAY" \
		-v /etc/localtime:/etc/localtime \
		-v /tmp/.X11-unix:/tmp/.X11-unix:rw \
		-v ~/Maildir:/home/user/Maildir \
		-it docker.io/joshuajleigh/ex2mutt

vars:
	echo $(FULLNAME)
	echo $(USER)

help:
	@printf "\033[0;32m Welcome to the exchange to mutt repo!\033[0m\n"
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: mutt testing
