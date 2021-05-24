# ortizaggies-storage

This account is used to store this that and the other.

Ran initially to create the Everyone user group and a bucket. When creating a
bucket, specify the name. This will also create a user group to manage objects
in that bucket. To update any of these, change out create for update.

```
aws cloudformation create-stack \
  --stack-name iam \
  --template-body file://iam.yml \
  --capabilities CAPABILITY_NAMED_IAM

aws cloudformation create-stack \
  --stack-name bucket \
  --parameters ParameterKey=BucketName,ParameterValue=ortizaggies-mom \
  --template-body file://bucket.yml \
  --capabilities CAPABILITY_NAMED_IAM
```
