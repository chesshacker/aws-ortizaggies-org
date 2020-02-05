# ortizaggies-master

Only billing and organization things should go in the master payer account.

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
  --policy-id "${POLICY_ID}"
  --content "$(yq -c '.' account-baseline-scp.yml)" \
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
