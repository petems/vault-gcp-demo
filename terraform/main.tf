provider "vault" {
  # Set token via VAULT_TOKEN=<token>
  #
  address = "http://127.0.0.1:8200"
}

resource "vault_policy" "demo" {
  name = "demo"

  policy = <<EOT
path "secret/data/demo" {
  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "vault_notify" {
  path = "secret/location"

  data_json = <<EOT
{
  "value": "London"
}
EOT
}
