resource "google_kms_key_ring" "vault_server_kms" {
  project  = "${google_project.vault_gcp_demo.project_id}"
  name     = "vault-keyring"
  location = "global"
}

resource "google_kms_key_ring_iam_binding" "vault_iam_kms_binding" {
  key_ring_id = "${google_kms_key_ring.vault_server_kms.id}"
  role = "roles/owner"

  members = [
    "serviceAccount:${google_service_account.vault_auth_checker.email}",
  ]
}

resource "google_kms_crypto_key" "vault_server_kms" {
  name            = "vault-key"
  key_ring        = "${google_kms_key_ring.vault_server_kms.self_link}"

  // one week
  rotation_period = "604800s"
}
