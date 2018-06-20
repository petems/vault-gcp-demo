variable "billing_account" {}

variable "org_id" {
}

provider "google" {
  version = "1.14.0"
}

resource "random_id" "id" {
 byte_length = 4
 prefix      = "vault-gcp-demo-"
}

resource "google_project" "vault_gcp_demo" {
 name            = "vault-gcp-demo"
 project_id      = "${random_id.id.hex}"
 billing_account = "${var.billing_account}"
 org_id          = "${var.org_id}"
}

resource "google_project_services" "vault_gcp_demo_services" {
 project = "${google_project.vault_gcp_demo.project_id}"
 services = [
   "oslogin.googleapis.com",
   "compute.googleapis.com"
 ]
}

output "project_id" {
 value = "${google_project.vault_gcp_demo.project_id}"
}
