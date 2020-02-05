# ortizaggies-org

This account is used to manage the other accounts with an account-baseline stackset.

Ran initially to create groups, roles and stack sets used by account baseline:

```
aws cloudformation create-stack \
  --stack-name groups \
  --template-body file://groups.yml \
  --capabilities CAPABILITY_NAMED_IAM

aws cloudformation create-stack \
  --stack-name stack-set-admin-role \
  --template-body file://stack-set-admin-role.yml \
  --capabilities CAPABILITY_NAMED_IAM

aws cloudformation create-stack-set \
  --stack-set-name account-baseline \
  --template-body file://account-baseline.yml \
  --capabilities CAPABILITY_NAMED_IAM
```

You may find you want to update some of these:

```
aws cloudformation update-stack \
  --stack-name groups \
  --template-body file://groups.yml \
  --capabilities CAPABILITY_NAMED_IAM

aws cloudformation update-stack \
  --stack-name stack-set-admin-role \
  --template-body file://stack-set-admin-role.yml \
  --capabilities CAPABILITY_NAMED_IAM

aws cloudformation update-stack-set \
  --stack-set-name account-baseline \
  --template-body file://account-baseline.yml \
  --capabilities CAPABILITY_NAMED_IAM
```
