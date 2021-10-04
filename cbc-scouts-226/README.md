# cbc-scouts-226

This account is holds a few things for the scout's website.

Ran initially to create a webmaster group and a bucket for their website. To
update any of these, change out create for update.

```
aws cloudformation create-stack \
  --stack-name iam \
  --template-body file://iam.yml \
  --capabilities CAPABILITY_NAMED_IAM

aws cloudformation create-stack \
  --stack-name website \
  --template-body file://website.yml

aws cloudformation create-stack \
  --stack-name dns \
  --template-body file://dns.yml

aws cloudformation create-stack \
  --stack-name website-code-pipeline \
  --template-body file://website-code-pipeline.yml \
  --capabilities CAPABILITY_NAMED_IAM
```

## One-time set up access to GitHub

After creating the website-code-pipeline stack, finish setting up the [Pending Connection].

[Pending Connection]: https://console.aws.amazon.com/codesuite/settings/connections
