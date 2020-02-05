#!/usr/bin/env bash
set -e

if [ $# -ne 1 ]; then
  echo "Usage: aws-login <mfa-token>"
  exit 1
fi

CREDS="$(aws-vault exec --mfa-token=$1 --duration=12h default -- env | grep AWS_)"

env ${CREDS} bash -c 'aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID} --profile default'
env ${CREDS} bash -c 'aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY} --profile default'
env ${CREDS} bash -c 'aws configure set aws_session_token ${AWS_SESSION_TOKEN} --profile default'
