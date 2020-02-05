#!/usr/bin/env bash
set -e
cd $(dirname "${BASH_SOURCE[0]}")
source utilities.sh
verify_all

if [ $# -ne 1 ]; then
  echo "Usage: add-account.sh <account_name>"
  echo "Example: add-account.sh ortizaggies-experiment"
  exit 1
fi
ACCOUNT_NAME=$1

echo "Create account: ${ACCOUNT_NAME}..."
are_you_sure

RESPONSE=$(aws organizations create-account \
  --email "aws+${ACCOUNT_NAME}@ortizaggies.com" \
  --account-name "${ACCOUNT_NAME}" \
  --iam-user-access-to-billing ALLOW)

CREATE_ACCOUNT_REQUEST_ID=$(echo $RESPONSE | jq -r '.CreateAccountStatus.Id')
echo "Creating account ${ACCOUNT_NAME} --> ${CREATE_ACCOUNT_REQUEST_ID}"

while true; do
  RESPONSE=$(aws organizations describe-create-account-status \
    --create-account-request-id "${CREATE_ACCOUNT_REQUEST_ID}")
  STATUS=$(echo $RESPONSE | jq -r '.CreateAccountStatus.State')
  if [[ "${STATUS}" == "SUCCEEDED" ]]; then break; fi
  sleep 1
  echo -n '.'
done

ACCOUNT_ID=$(echo $RESPONSE | jq -r '.CreateAccountStatus.AccountId')
echo " Successfully created account... Next, run:"
echo "init-account.sh ${ACCOUNT_NAME} ${ACCOUNT_ID}"
