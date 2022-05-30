NS = eu.gcr.io/wi-q-145611
REPO = php-roadrunner
PHP_VERSION ?= 8.1-alpine
ROADRUNNER_VERSION ?= 2.10.2
VERSION = 8.1

.PHONY: build
build:
	docker build --build-arg RR_VERSION=$(ROADRUNNER_VERSION) --build-arg PHP_VERSION=$(PHP_VERSION) -t $(NS)/$(REPO):$(VERSION) -f ./Dockerfile --rm .

.PHONY: build-multi-platform
build-multi-platform:
	docker buildx build --build-arg RR_VERSION=$(ROADRUNNER_VERSION) --build-arg PHP_VERSION=$(PHP_VERSION) -t $(NS)/$(REPO):$(VERSION) --platform linux/arm64,linux/amd64 --rm .

.PHONY: push
push: build
	docker push $(NS)/$(REPO):$(VERSION)

.PHONY: push-multi-platform
push-multi-platform:
	docker buildx build -t $(NS)/$(REPO):$(VERSION) --platform linux/arm64,linux/amd64 --push --rm .
