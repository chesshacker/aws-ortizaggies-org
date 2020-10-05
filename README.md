# AWS Organization for OrtizAggies

Starting from just a master payer account, run `add-account.sh` to create an
org/admin account. Then create the things in both ortizaggies-master and
ortizaggies-org. Then run `init-account.sh` on both the master-payer and the
org/admin account. Create a user, and add this user to the Everyone group and
the Admin group.

To generate an aws config file, run generate-aws-config using an Admin user.

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

## How-to create a new account

Since the account-baseline StackSet is attached to the organization root, the
only setup required is creating the account (add-account.sh) and creating the
alias within the account (init-account.sh). Both of these are done using the
ortizaggies-master-admin role. After initializing the account, you probably want
to generate a new config and test it out. Here is an example from
ortizaggies-sunburst:

```
cd scripts
aws-vault exec ortizaggies-master-admin -- ./add-account.sh ortizaggies-sunburst
aws-vault exec ortizaggies-master-admin -- ./init-account.sh ortizaggies-sunburst 684162369826
./generate-aws-config.sh
aws-vault exec ortizaggies-sunburst-admin -- aws sts get-caller-identity
```
