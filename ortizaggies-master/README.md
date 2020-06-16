# ortizaggies-master

Only billing and organization things should go in the master payer account.

# Account Baseline

To create the account-baseline stackset.

```
aws --profile ortizaggies-master-admin cloudformation create-stack-set \
  --stack-set-name account-baseline \
  --template-body file://account-baseline.yml \
  --capabilities CAPABILITY_NAMED_IAM \
  --permission-model SERVICE_MANAGED \
  --auto-deployment Enabled=true,RetainStacksOnAccountRemoval=true
```

```
ROOT_ID=$(aws --profile ortizaggies-master-admin organizations list-roots | jq -r '.Roots[0].Id')
aws --profile ortizaggies-master-admin cloudformation create-stack-instances \
  --stack-set-name account-baseline \
  --deployment-targets OrganizationalUnitIds=${ROOT_ID} \
  --regions=us-east-1 \
  --operation-preferences FailureTolerancePercentage=100,MaxConcurrentPercentage=100
```

To update the account-baseline stackset.

```
aws --profile ortizaggies-master-admin cloudformation update-stack-set \
  --stack-set-name account-baseline \
  --template-body file://account-baseline.yml \
  --capabilities CAPABILITY_NAMED_IAM \
  --operation-preferences FailureTolerancePercentage=100,MaxConcurrentPercentage=100
```

To add the account baseline to the master account...

```
aws --profile ortizaggies-master-admin cloudformation create-stack \
  --stack-name account-baseline \
  --template-body file://account-baseline.yml \
  --capabilities CAPABILITY_NAMED_IAM

aws --profile ortizaggies-master-admin cloudformation update-stack \
  --stack-name account-baseline \
  --template-body file://account-baseline.yml \
  --capabilities CAPABILITY_NAMED_IAM
```

## Account Baseline SCP

```
aws --profile ortizaggies-master-admin organizations create-policy \
  --type SERVICE_CONTROL_POLICY \
  --name account-baseline-scp \
  --description "protects account baseline" \
  --content "$(yq -c '.' account-baseline-scp.yml)"
```

```
POLICY_ID=$(aws --profile ortizaggies-master-admin organizations list-policies \
  --filter SERVICE_CONTROL_POLICY | jq -r \
  '.Policies[]|select(.Name=="account-baseline-scp")|.Id')
aws --profile ortizaggies-master-admin organizations update-policy \
  --policy-id "${POLICY_ID}" \
  --content "$(yq -c '.' account-baseline-scp.yml)"
```

## Disable Root SCP

```
aws --profile ortizaggies-master-admin organizations create-policy \
  --type SERVICE_CONTROL_POLICY \
  --name disable-root-scp \
  --description "prevents root user from doing anything" \
  --content "$(yq -c '.' disable-root-scp.yml)"
```

```
POLICY_ID=$(aws --profile ortizaggies-master-admin organizations list-policies \
  --filter SERVICE_CONTROL_POLICY | jq -r \
  '.Policies[]|select(.Name=="disable-root-scp")|.Id')
aws --profile ortizaggies-master-admin organizations update-policy \
  --policy-id "${POLICY_ID}"
  --content "$(yq -c '.' disable-root-scp.yml)" \
```
