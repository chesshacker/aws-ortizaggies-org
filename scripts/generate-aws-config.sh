#!/usr/bin/env bash
set -e
cd $(dirname "${BASH_SOURCE[0]}")
source utilities.sh
verify_tools

cat << EOF > ~/.aws/config
[default]
mfa_serial=arn:aws:iam::${USER_ACCOUNT}:mfa/SteveOrtiz
EOF

CREDS=$(aws sts assume-role \
					--role-session-name generate-aws-config \
					--role-arn arn:aws:iam::${MASTER_ACCOUNT}:role/Admin)
export AWS_ACCESS_KEY_ID=$(echo $CREDS | jq -r .Credentials.AccessKeyId)
export AWS_SECRET_ACCESS_KEY=$(echo $CREDS | jq -r .Credentials.SecretAccessKey)
export AWS_SESSION_TOKEN=$(echo $CREDS | jq -r .Credentials.SessionToken)

while
	response=$(aws organizations list-accounts ${nextToken:+ --starting-token "${nextToken}"})
	accountsText=$(echo $response | jq -r '.Accounts[]|select(.Status=="ACTIVE")|.Id+" "+.Name')
	while read -r accountId accountName; do
		for role in "Admin"; do
			roleLower=$(echo $role | tr [:upper:] [:lower:])
			cat <<- EOF >> ~/.aws/config
				[profile ${accountName}-${roleLower}]
				region=us-east-1
				source_profile=default
				parent_profile=default
				role_arn=arn:aws:iam::${accountId}:role/${role}
				EOF
		done
	done <<< "$accountsText"
	nextToken=$(echo $response | jq -r '.NextToken')
	[[ $nextToken != "null" ]]
do true; done
