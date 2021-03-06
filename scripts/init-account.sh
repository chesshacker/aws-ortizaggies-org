#!/usr/bin/env bash
set -e
cd $(dirname "${BASH_SOURCE[0]}")
source utilities.sh
verify_all

if [ $# -ne 2 ]; then
  echo "Usage: init-account.sh <account_name> <account_id>"
  echo "Example: init-account.sh ortizaggies-experiment 111111111111"
  exit 1
fi

ACCOUNT_NAME=$1
ACCOUNT_ID=$2

echo "Initialize account: ${ACCOUNT_NAME}..."
are_you_sure

./create-alias.sh ${ACCOUNT_NAME} ${ACCOUNT_ID}
