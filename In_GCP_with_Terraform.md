## Instructions

Install gcloud

With Brew:

```
brew install gcloud
```

Or with the installer:

```
curl https://sdk.cloud.google.com |
exec -l $SHELL
gcloud init
```

Configure authentication:

```
gcloud auth login
gcloud auth application-default login
```

Export your billing and organisation settings:
```
gcloud organizations list
gcloud beta billing accounts list

export TF_VAR_org_id=<Organisation ID>
export TF_VAR_billing_account=<Billing Account ID>
```

Run terraform:

```
terraform plan
terraform apply
```

## Configure Vault after installation

Use the Terraform output to export Vault configuration:

```
vault_addr_export = Run the following for the Vault configuration: export VAULT_ADDR=http://11.22.33.44:8200
```

Initialize Vault:
```
vault operator init
```

Export the Vault token from the info from the initialize
```
export VAULT_TOKEN=7a902c8b-a14e-f2af-e007-4482218c586e
```

### Configure GCP Backend and secrets

Configure Vault with Terraform code:
```
cd vault/
terraform plan
terraform apply
```

## Show Backend and Policies

### SSH into the Vault Happy path instance

```
./scripts/ssh_to_vault_happy.sh
```

## Run the functions to get Vault credentials

```
$ sudo -i
$ source ~/.vault_credentials
$ env | grep VAULT
VAULT_ADDR=http://11.22.33.44:8200
VAULT_TOKEN=9a73bcbd-460f-bca8-39b5-04854799cb96
```

## Get the example data (with JQ for nice output)

```
$ curl \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    $VAULT_ADDR/v1/secret/demo | jq
{
  "request_id": "a4e5343c-e10f-dc80-19a3-cd107332014f",
  "lease_id": "",
  "renewable": false,
  "lease_duration": 2764800,
  "data": {
    "location": "London"
  },
  "wrap_info": null,
  "warnings": null,
  "auth": null
}
```

## Do the same on the Vault Unhappy path to see that their is a region bind:

```
$ ./scripts/ssh_to_vault_sad.sh
$ source ~/.vault_credentials
Error from vault: [
  "instance not in bound regions [\"europe-west2\"]"
]
```
