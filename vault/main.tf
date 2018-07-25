resource "vault_policy" "reader" {
  name = "reader"

  policy = <<EOT
path "secret/demo" {

  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "demo_secret" {
  path = "secret/demo"

  data_json = <<EOT
{

  "location": "London"
}
EOT
}
