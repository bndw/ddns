REPO ?= bndw/ddns
GITSHA=$(shell git rev-parse --short HEAD)
TAG_COMMIT=$(REPO):$(GITSHA)
TAG_LATEST=$(REPO):latest

all: build

.PHONY: build
build:
	@docker build -t $(TAG_LATEST) .

.PHONY: publish
publish:
	@docker login -u $(DOCKER_USER) -p $(DOCKER_PASS)
	docker push $(TAG_LATEST)
	@docker tag $(TAG_LATEST) $(TAG_COMMIT)
	docker push $(TAG_COMMIT)
