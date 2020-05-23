IMAGE_URL ?= docker.io/ornew/github-actions-runner

BUILDKIT_HOST  ?= tcp://127.0.0.1:1234
BUILDKIT_CERTS ?=

.PHONY: image

.cache:
	@mkdir -p $@

.cache/image: .cache setup.sh entrypoint.sh Dockerfile
	buildctl \
		--debug \
		--addr $(BUILDKIT_HOST) \
		$(BUILDKIT_CERTS) \
		build \
		--progress plain \
		--frontend gateway.v0 \
		--opt source=docker/dockerfile \
		--local context=. \
		--local dockerfile=. \
		--output type=docker,name=$(IMAGE_URL),dest=$@

image: .cache/image

image/push: setup.sh entrypoint.sh Dockerfile
	buildctl \
		--debug \
		--addr $(BUILDKIT_HOST) \
		$(BUILDKIT_CERTS) \
		build \
		--progress plain \
		--frontend gateway.v0 \
		--opt source=docker/dockerfile \
		--local context=. \
		--local dockerfile=. \
		--output type=image,name=$(IMAGE_URL),push=true
