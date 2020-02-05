# AWS Organization for OrtizAggies

Starting from just a master payer account, run `add-account.sh` to create an
org/admin account. Then create the things in ortizaggies-org. Then run
`init-account.sh` on both the master-payer and the org/admin account. Create
a user, and add this user to the Everyone group and the Admin group.

To generate an aws config file, run generate-aws-config using an Admin user. No
need to assume any particular role first.

To verify all aws profiles are good to go, first login with the `aws-login.sh`
script and you MFA. Then try out all the profiles with vault and aws cli.

```
./scripts/aws-login.sh 123456

aws-vault list | tail -n+4 | awk '{print $1}' | xargs -I % -n 1 bash -c "aws-vault exec % -- aws sts get-caller-identity"

aws-vault list | tail -n+4 | awk '{print $1}' | xargs -I % -n 1 aws --profile % sts get-caller-identity
```

To list all accounts:

```
aws organizations --profile ortizaggies-master-admin list-accounts | jq -r '.Accounts[]|.Id + " " + .Name'
```
