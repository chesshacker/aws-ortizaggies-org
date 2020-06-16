# ortizaggies-org

This account is meant to support other accounts in the organization.

Ran initially to create groups, cloudtrail bucket and athena results bucket. To
update any of these, change out create for update.

```
aws cloudformation create-stack \
  --stack-name groups \
  --template-body file://groups.yml \
  --capabilities CAPABILITY_NAMED_IAM

aws cloudformation create-stack \
  --stack-name cloudtrail-bucket \
  --template-body file://cloudtrail-bucket.yml

aws cloudformation create-stack \
  --stack-name athena-results \
  --template-body file://athena-results.yml
```
