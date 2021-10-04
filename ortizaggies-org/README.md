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

## Athena and CloudTrail

Access all the accounts have a Glue database called account and a table called
cloudtrail which can be used to search through cloudtrail events. This account
also has access to an organization database which can query any account.

The following fields vary by service and action, and JSON_EXTRACT can be used to
query within these fields:
* requestparameters (string)
* responseelements (string)
* additionaleventdata (string)

Here is an example of how you might do some attribution with CloudTrail. Let's
figure out who deleted the ever import `temp` table from glue.

```
SELECT eventtime, useridentity.type, useridentity.principalid, useridentity.accountid, useridentity.username
FROM cloudtrail
WHERE region = 'us-east-1'
  and date_partition >= date_format(current_timestamp - interval '1' hour, '%Y/%m/%d')
  and eventsource = 'glue.amazonaws.com'
  and eventname = 'DeleteTable'
  and json_extract_scalar(requestparameters,'$.name') = 'cloudtrail'
```

Ah ha! The AssumedRole AROA3MKQQQZKBDTLH4XXX:12345678 is to blame. The next step
is to see who assumed that role.

```
SELECT eventtime, useridentity.type, useridentity.principalid, useridentity.accountid, useridentity.username, sharedeventid
FROM cloudtrail
WHERE region = 'us-east-1'
  and date_partition >= date_format(current_timestamp - interval '1' hour, '%Y/%m/%d')
  AND eventsource = 'sts.amazonaws.com'
  AND eventname = 'AssumeRole'
  AND json_extract_scalar(responseelements,'$.assumedRoleUser.assumedRoleId') = 'AROA3MKQQQZKBDTLH4XXX:12345678'
```

This role was assumed by an AWSAccount and the principalId is
AIDARK6VB7Z4NN5TXOXXX. At this point, there are two ways to proceed. If you have
access to the originating account, you can query the IAM service directly to
find out who that principal belongs to.

```
aws iam list-users | jq -r '.Users[]|select(.UserId=="AIDARK6VB7Z4NN5TXOXXX")|.UserName'
```

Or, if you have access to either the organization cloudtrail or the account
cloudtrail that request came from, you can search for the sharedeventid. This
example uses the organization CloudTrail.

```
SELECT eventtime, useridentity.type, useridentity.principalid, useridentity.accountid, useridentity.username
FROM cloudtrail
WHERE region = 'us-east-1' and account = '092251712345'
  and date_partition >= date_format(current_timestamp - interval '1' hour, '%Y/%m/%d')
  AND sharedeventid = 'b68b55e1-aaaa-1234-8f7d-ef2bd08ca088'
```

The result in this case explains the role was assumed by an IAM User, and
provides the username. Unfortunately, all your work showed that you were to
blame! Don't you hate it when that happens?

To help you with attribution in other cases, here are some helpful references:

* [AWS CloudTrail - CloudTrail userIdentity element]
* [AWS Identity and Access Management - IAM Identifiers]
* [Athena SQL Reference]
* [Actions for AWS services]: Useful reference for the eventsource, eventname, requestparameters, responseelements, and resources for each action.

[AWS CloudTrail - CloudTrail userIdentity element]: https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-event-reference-user-identity.html
[AWS Identity and Access Management - IAM Identifiers]: https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_identifiers.html#identifiers-prefixes
[Athena SQL Reference]: https://docs.aws.amazon.com/athena/latest/ug/ddl-sql-reference.html
[Actions for AWS services]: https://docs.aws.amazon.com/service-authorization/latest/reference/reference_policies_actions-resources-contextkeys.html
