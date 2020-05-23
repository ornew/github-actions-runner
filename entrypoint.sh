#!/bin/sh

cd /work
/opt/github-actions-runner/config.sh \
  --unattended \
  --url $REPOSITORY_URL \
  --token $TOKEN \
  --name $(hostname -f) \
  --labels "self-hosted,Linux,X64${CUSTOM_LABELS}" \
  --work /work \
  --replace
/opt/github-actions-runner/run.sh
