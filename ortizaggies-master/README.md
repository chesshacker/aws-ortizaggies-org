# ortizaggies-master

Only billing and organization things should go in the master payer account.

# Account Baseline

To create the account-baseline stackset.

```
aws --profile ortizaggies-master cloudformation create-stack-set \
  --stack-set-name account-baseline \
  --template-body file://account-baseline.yml \
  --capabilities CAPABILITY_NAMED_IAM \
  --permission-model SERVICE_MANAGED \
  --auto-deployment Enabled=true,RetainStacksOnAccountRemoval=true
```

```
ROOT_ID=$(aws --profile ortizaggies-master organizations list-roots | jq -r '.Roots[0].Id')
aws --profile ortizaggies-master cloudformation create-stack-instances \
  --stack-set-name account-baseline \
  --deployment-targets OrganizationalUnitIds=${ROOT_ID} \
  --regions=us-east-1 \
  --operation-preferences FailureTolerancePercentage=100,MaxConcurrentPercentage=100
```

To update the account-baseline stackset.

```
aws --profile ortizaggies-master cloudformation update-stack-set \
  --stack-set-name account-baseline \
  --template-body file://account-baseline.yml \
  --capabilities CAPABILITY_NAMED_IAM \
  --operation-preferences FailureTolerancePercentage=100,MaxConcurrentPercentage=100
```

To add the account baseline to the master account...

```
aws --profile ortizaggies-master cloudformation create-stack \
  --stack-name account-baseline \
  --template-body file://account-baseline.yml \
  --capabilities CAPABILITY_NAMED_IAM

aws --profile ortizaggies-master cloudformation update-stack \
  --stack-name account-baseline \
  --template-body file://account-baseline.yml \
  --capabilities CAPABILITY_NAMED_IAM
```

## yq

The policy commands below need the YAML as one line of JSON. Two unrelated programs are both named `yq`.

`brew install yq` installs the Go program from mikefarah. That is the `yq` on the PATH after a Homebrew install. `yq -c` prints compact YAML, which Organizations rejects. Compact JSON is:

```
yq -o=json -I=0 '.' account-baseline-scp.yml
```

The other program is the Python package (`pip install yq`), a wrapper around jq. It is not installed. There, compact JSON is `yq -c '.' file.yml`.

## Account Baseline SCP

```
aws --profile ortizaggies-master organizations create-policy \
  --type SERVICE_CONTROL_POLICY \
  --name account-baseline-scp \
  --description "protects account baseline" \
  --content "$(yq -o=json -I=0 '.' account-baseline-scp.yml)"
```

```
POLICY_ID=$(aws --profile ortizaggies-master organizations list-policies \
  --filter SERVICE_CONTROL_POLICY | jq -r \
  '.Policies[]|select(.Name=="account-baseline-scp")|.Id')
aws --profile ortizaggies-master organizations update-policy \
  --policy-id "${POLICY_ID}" \
  --content "$(yq -o=json -I=0 '.' account-baseline-scp.yml)"
```

## Disable Root SCP

```
aws --profile ortizaggies-master organizations create-policy \
  --type SERVICE_CONTROL_POLICY \
  --name disable-root-scp \
  --description "prevents root user from doing anything" \
  --content "$(yq -o=json -I=0 '.' disable-root-scp.yml)"
```

```
POLICY_ID=$(aws --profile ortizaggies-master organizations list-policies \
  --filter SERVICE_CONTROL_POLICY | jq -r \
  '.Policies[]|select(.Name=="disable-root-scp")|.Id')
aws --profile ortizaggies-master organizations update-policy \
  --policy-id "${POLICY_ID}"
  --content "$(yq -o=json -I=0 '.' disable-root-scp.yml)" \
```
