#!/usr/bin/env bash
set -e
cd $(dirname "${BASH_SOURCE[0]}")
source utilities.sh
verify_all

if [ $# -ne 2 ]; then
  echo "Usage: create-execution-role.sh <account_name> <account_id>"
  echo "Example: create-execution-role.sh ortizaggies-example 111111111111"
  exit 1
fi

ACCOUNT_NAME=$1
ACCOUNT_ID=$2

if [ "${ACCOUNT_ID}" != "${MASTER_ACCOUNT}" ]; then
  CREDS=$(aws sts assume-role \
            --role-session-name create-execution-role \
            --role-arn arn:aws:iam::${ACCOUNT_ID}:role/OrganizationAccountAccessRole)
  AWS_ACCESS_KEY_ID=$(echo $CREDS | jq -r .Credentials.AccessKeyId)
  AWS_SECRET_ACCESS_KEY=$(echo $CREDS | jq -r .Credentials.SecretAccessKey)
  AWS_SESSION_TOKEN=$(echo $CREDS | jq -r .Credentials.SessionToken)
  unset AWS_SECURITY_TOKEN
fi

ALIAS=$(aws iam list-account-aliases | jq -c -r '.AccountAliases[0]')
if [ "$ALIAS" == "${ACCOUNT_NAME}" ]; then
  echo "Account alias ${ACCOUNT_NAME} is already set"
else
  if [ "$ALIAS" != "null" ]; then
    aws iam delete-account-alias --account-alias ${ALIAS}
    echo "Deleted account alias ${ALIAS}"
  fi
  aws iam create-account-alias --account-alias ${ACCOUNT_NAME}
  echo "Created account alias ${ACCOUNT_NAME}"
fi
