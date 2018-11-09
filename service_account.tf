data "google_iam_policy" "vault_policy" {
  binding {
    role = "roles/compute.viewer"

    members = [
      "serviceAccount:${google_service_account.vault_auth_checker.email}",
    ]
  }

  binding {
    role = "roles/iam.securityReviewer"

    members = [
      "serviceAccount:${google_service_account.vault_auth_checker.email}",
    ]
  }
}

resource "google_service_account" "vault_auth_checker" {
  project      = "${google_project.vault_gcp_demo.project_id}"
  account_id   = "vault-auth-checker"
  display_name = "Vault Auth Checker (KMS for unseal, IAM for GCP Backend)"
}

resource "google_project_iam_policy" "vault_policy" {
  project     = "${google_project.vault_gcp_demo.project_id}"
  policy_data = "${data.google_iam_policy.vault_policy.policy_data}"
}
