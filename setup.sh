#!/bin/sh

BUILDKIT_URL=https://github.com/moby/buildkit/releases/download/v0.7.1/buildkit-v0.7.1.linux-amd64.tar.gz
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

install_buildkit() {
  setup buildkit $BUILDKIT_URL targz
  cp $apptmp/bin/buildctl $app
  ln -svf $app/buildctl $bin/buildctl
}

install_github_actions_runner() {
  setup github-actions-runner $RUNNER_URL targz
  cp -rT $apptmp $app
}

install_buildkit
install_github_actions_runner

mkdir -p /work
