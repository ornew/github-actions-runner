# syntax = docker/dockerfile:experimental
ARG UBUNTU_IMAGE_VERSION=20.04
FROM ubuntu:$UBUNTU_IMAGE_VERSION

ARG UBUNTU_CODENAME=focal
ARG APT_ARCHIVE_REPOSITORY_URL=http://archive.ubuntu.com
ARG INSTALL_PREFIX=/opt

ENV LANG   C.UTF-8
ENV LC_ALL C.UTF-8

COPY setup.sh /setup.sh
RUN \
  --mount=type=cache,mode=777,target=/var/lib/apt/lists \
  --mount=type=cache,mode=777,target=/var/cache \
  --mount=type=cache,mode=777,target=/tmp/build \
  /setup.sh
COPY entrypoint.sh /entrypoint.sh

WORKDIR /work

ENTRYPOINT ["/entrypoint.sh"]
