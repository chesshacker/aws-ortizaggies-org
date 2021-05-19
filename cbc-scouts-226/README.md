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
```
