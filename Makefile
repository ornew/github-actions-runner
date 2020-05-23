
DOCKER_IMAGE ?= ornew/github-actions-runner

BUILDKIT_HOST  ?= tcp://127.0.0.1:1234
BUILDKIT_CERTS ?=

.PHONY: image

.cache:
	@mkdir -p .cache

.cache/image: .cache setup.sh entrypoint.sh Dockerfile
	@mkdir -p `dirname $@`
	buildctl \
		--debug \
		--addr ${BUILDKIT_HOST} \
		$(BUILDKIT_CERTS) \
		build \
		--progress plain \
		--frontend dockerfile.v0 \
		--local context=. \
		--local dockerfile=. \
		--opt filename=Dockerfile \
		-o type=docker,name=$(DOCKER_IMAGE),oci-mediatypes=true,name-canonical=true > $@.tmp
	mv $@.tmp $@
	docker load -i $@

image: .cache/image
