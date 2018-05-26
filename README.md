# vault-gcp-demo
Demo of creating a Vault setup on GCP

## Instructions

* Run Vault locally in dev mode:

```
vault server -dev
```

* Run ngrok to get a public URL for Vault

```
ngrok http 8200
```

*Note: You could also run Vault in a GCP instance, but ngrok is the quickest way.

* Create a policy that can only read one secret:

```
$ cat policy.hcl
path "secret/data/demo" {
  capabilities = ["read"]
}

$ vault policy write reader ./policy.hcl

> You can also do it with the Terraform code under `terraform/`.


```

* Add data to that secret

```
$ vault kv put secret/demo location=London
Key              Value
---              -----
created_time     2018-04-07T21:29:09.46784517Z
deletion_time    n/a
destroyed        false
version          1
```

* Now, create a service user that has the "Security Reviewer" and the "Compute Viewer" role:

![screenshot 2018-05-31 14 51 57](https://user-images.githubusercontent.com/1064715/40792705-7bbea200-64f2-11e8-8c31-e9e5edb9479a.png)

> (You can also give them the more granular permissions of `iam.serviceAccounts.get` and `iam.serviceAccountKeys.get`)

* Download the credentials as a JSON file, looks something like this:

```json
{
  "type": "service_account",
  "project_id": "vault-gcp-demo",
  "private_key_id": "4aff3f5214319a5cd84b3b2c6310a9b558123a4",
  "private_key": "REDACTED",
  "client_email": "vault-auth-checker@vault-gcp-demo.iam.gserviceaccount.com",
  "client_id": "115273620673067746930",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://accounts.google.com/o/oauth2/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/vault-auth-checker%40vault-gcp-demo.iam.gserviceaccount.com"
}
```

* Mount the GCP auth in Vault with the JSON (Best done in the GUI)

<img width="1424" alt="screenshot 2018-05-31 09 38 03" src="https://user-images.githubusercontent.com/1064715/40771860-64fd58e0-64b6-11e8-8a47-7008315e901c.png">

> You currently can't do the GCP configuration with the Terraform provider, a PR is open: https://github.com/terraform-providers/terraform-provider-vault/pull/124

* Write a new role for GCP with the policy and the project ID

```
vault write auth/gcp/role/web \
type=gce \
policies=reader \
project_id="vault-gcp-demo"
```

* SSH into your GCE instance, and try and create a Vault token based on the GCE IAM Auth:

```
$ export VAULT_ADDR=http://e880f3f4.ngrok.io # NGROK ID from earlier
$ export JWT=$(curl -H "Metadata-Flavor: Google"\
   -G \
   --data-urlencode "audience=$VAULT_ADDR/vault/web"\
   --data-urlencode "format=full" \
   "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/identity")
$ vault write auth/gcp/login \
role=web \
jwt="$JWT"
```

* If you get an error like this, make sure you've enabled the IAM service

```
Error writing data to auth/gcp/login: Error making API request.
URL: PUT http://124b0dd9.ngrok.io/v1/auth/gcp/login
Code: 400. Errors:
* Could not find service account '1153232431111468285' used for GCE metadata token: service account 'projects/vault-gcp-demo/serviceAccounts/1153232431111468285' does not exist
```

> Enable it with the following link: https://console.developers.google.com/apis/library/iam.googleapis.com

* If it does work, you should get a Vault token:

```
vault write auth/gcp/login \
> role=web \
> jwt="$JWT"
Key                                       Value
---                                       -----
token                                     f01gse1c-4be5-5456-3ec8-f01b5110d02e
token_accessor                            1ad6e6e9-2d2f-8b90-340a-6b6e69110a85
token_duration                            768h
token_renewable                           true
token_policies                            [default reader]
token_meta_instance_id                    6232428913777061176
token_meta_role                           web
token_meta_service_account_email          1123123135223-compute@developer.gserviceaccount.com
token_meta_zone                           europe-west2-c
token_meta_instance_creation_timestamp    1529058265
token_meta_instance_name                  vault-instance-1
token_meta_project_id                     vault-gcp-demo
token_meta_project_number                 1123123135223
token_meta_service_account_id             115323474003184468285
```

* Export this Vault token

```
$ VAULT_TOKEN=f01gse1c-4be5-5456-3ec8-f01b5110d02e
```

* Now try and fetch the secret from before

```
$ vault kv get secret/demo
====== Metadata ======
Key              Value
---              -----
created_time     2018-06-15T11:15:31.30098998Z
deletion_time    n/a
destroyed        false
version          1
====== Data ======
Key         Value
---         -----
location    London
```

## Restricting Token access via bounds

You can demo restricting who can access the token:

```
$ vault write auth/gcp/role/web \
type=gce \
policies=reader \
project_id="vault-gcp-demo-ps"
bound_region="europe-west2"
```

Now, when we try to get a token from a non-eu-west-2 machine:

```
Error writing data to auth/gcp/login: Error making API request.
URL: PUT http://02feb634.eu.ngrok.io/v1/auth/gcp/login
Code: 400. Errors:
* instance zone europe-west1-b is not in role region 'europe-west2'
```

## TODOS

* Create Terraform code to install Vault instead of running ngrok
* Create Terraform code to automate Vault configuration
* Create Terraform code to create a GCP instance
* Show examples using curl and the API, instead of having to install Vault
