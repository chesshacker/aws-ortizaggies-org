#!/usr/bin/env bash
set -e
cd $(dirname "${BASH_SOURCE[0]}")
source utilities.sh
verify_all()

if [ $# -ne 2 ]; then
  echo "Usage: add-to-stackset.sh <account_id>"
  echo "Example: add-to-stackset.sh 111111111111"
  exit 1
fi

ACCOUNT_ID=$1

ADMIN_ACCOUNT_ID=092251750008
CREDS=$(aws sts assume-role \
          --role-session-name create-execution-role \
          --role-arn arn:aws:iam::${ADMIN_ACCOUNT_ID}:role/OrganizationAccountAccessRole)
AWS_ACCESS_KEY_ID=$(echo $CREDS | jq -r .Credentials.AccessKeyId)
AWS_SECRET_ACCESS_KEY=$(echo $CREDS | jq -r .Credentials.SecretAccessKey)
AWS_SESSION_TOKEN=$(echo $CREDS | jq -r .Credentials.SessionToken)

RESPONSE=$(aws cloudformation create-stack-instances \
  --stack-set-name account-baseline \
  --regions us-east-1 \
  --accounts ${ACCOUNT_ID})

OPERATION_ID=$(echo $RESPONSE | jq -r '.OperationId')
echo "Creating instance of account-baseline --> ${OPERATION_ID}"

# If this fails, you will need to manually delete the stack set instance and try again
# aws cloudformation delete-stack-instances --stack-set-name account-baseline --no-retain-stacks --regions us-east-1 --accounts ${ACCOUNT_ID}

while true; do
  RESPONSE=$(aws cloudformation describe-stack-set-operation \
    --stack-set-name account-baseline \
    --operation-id "${OPERATION_ID}")
  STATUS=$(echo $RESPONSE | jq -r '.StackSetOperation.Status')
  if [[ "${STATUS}" == "SUCCEEDED" ]]; then break; fi
  sleep 1
  echo -n '.'
done
echo " Successfully created instance in account-baseline"
