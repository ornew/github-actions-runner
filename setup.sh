#!/bin/sh

BUILDKIT_URL=https://github.com/moby/buildkit/releases/download/v0.7.1/buildkit-v0.7.1.linux-amd64.tar.gz
DOCKER_URL=https://download.docker.com/linux/static/stable/x86_64/docker-rootless-extras-19.03.9.tgz
RUNNER_URL=https://github.com/actions/runner/releases/download/v2.262.1/actions-runner-linux-x64-2.262.1.tar.gz

tee /etc/apt/sources.list <<EOF
deb $APT_ARCHIVE_REPOSITORY_URL/ubuntu/ $UBUNTU_CODENAME main restricted
#deb-src $APT_ARCHIVE_REPOSITORY_URL/ubuntu/ $UBUNTU_CODENAME main restricted
deb $APT_ARCHIVE_REPOSITORY_URL/ubuntu/ $UBUNTU_CODENAME-updates main restricted
#deb-src $APT_ARCHIVE_REPOSITORY_URL/ubuntu/ $UBUNTU_CODENAME-updates main restricted
deb $APT_ARCHIVE_REPOSITORY_URL/ubuntu/ $UBUNTU_CODENAME universe
#deb-src $APT_ARCHIVE_REPOSITORY_URL/ubuntu/ $UBUNTU_CODENAME universe
deb $APT_ARCHIVE_REPOSITORY_URL/ubuntu/ $UBUNTU_CODENAME-updates universe
#deb-src $APT_ARCHIVE_REPOSITORY_URL/ubuntu/ $UBUNTU_CODENAME-updates universe
#deb $APT_ARCHIVE_REPOSITORY_URL/ubuntu/ $UBUNTU_CODENAME multiverse
#deb-src $APT_ARCHIVE_REPOSITORY_URL/ubuntu/ $UBUNTU_CODENAME multiverse
#deb $APT_ARCHIVE_REPOSITORY_URL/ubuntu/ $UBUNTU_CODENAME-updates multiverse
#deb-src $APT_ARCHIVE_REPOSITORY_URL/ubuntu/ $UBUNTU_CODENAME-updates multiverse
#deb $APT_ARCHIVE_REPOSITORY_URL/ubuntu/ $UBUNTU_CODENAME-backports main restricted universe multiverse
#deb-src $APT_ARCHIVE_REPOSITORY_URL/ubuntu/ $UBUNTU_CODENAME-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu $UBUNTU_CODENAME-security main restricted
#deb-src http://security.ubuntu.com/ubuntu $UBUNTU_CODENAME-security main restricted
deb http://security.ubuntu.com/ubuntu $UBUNTU_CODENAME-security universe
#deb-src http://security.ubuntu.com/ubuntu $UBUNTU_CODENAME-security universe
#deb http://security.ubuntu.com/ubuntu $UBUNTU_CODENAME-security multiverse
#deb-src http://security.ubuntu.com/ubuntu $UBUNTU_CODENAME-security multiverse
EOF

export DEBIAN_FRONTEND=noninteractive

set -ex

apt update
apt install -y --no-install-recommends \
  file less tree unzip ca-certificates git make curl

app=${INSTALL_PREFIX:-/opt}
bin=/usr/local/bin
tmp=${TMPDIR:-/tmp/build}
tmp_archive_dir=$tmp/__archives

setup() {
  app=$INSTALL_PREFIX/$1
  apptmp=$tmp/__$1
  appfile=$tmp_archive_dir/$(basename $2)
  appurl=$2
  mkdir -p $app $apptmp
  cd $tmp_archive_dir
  curl -fsSLROz $appfile $appurl
  case $3 in
    zip) unzip -qo $appfile -d $apptmp ;;
    targz) tar xzf $appfile -C $apptmp ;;
  esac
}

install_docker() {
  setup docker $DOCKER_URL targz
  cp $apptmp/docker/docker $app
  ln -svf $app/docker $bin/docker
}

install_buildkit() {
  setup buildkit $BUILDKIT_URL targz
  cp $apptmp/bin/buildctl $app
  ln -svf $app/buildctl $bin/buildctl
}

install_github_actions_runner() {
  setup github-actions-runner $RUNNER_URL targz
  cp -rT $apptmp $app
}

install_docker
install_buildkit
install_github_actions_runner

/opt/github-actions-runner/bin/installdependencies.sh

mkdir -p /work

groupadd -r github-actions-runner
useradd -g github-actions-runner -r github-actions-runner -s /sbin/nologin -m
chown -R github-actions-runner:github-actions-runner /work
chown -R github-actions-runner:github-actions-runner /opt/github-actions-runner
