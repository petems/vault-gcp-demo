resource "google_compute_instance" "vault_server" {
  name         = "vault-server"
  machine_type = "n1-standard-1"
  zone         = "europe-west2-a"
  project      = "${google_project.vault_gcp_demo.project_id}"

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-8"
    }
  }

  metadata_startup_script = "${file("./install_vault.sh")}"

}

resource "google_compute_instance" "vault_happy" {
  name         = "vault-requester-happy"
  machine_type = "f1-micro"
  zone         = "europe-west2-a"
  project      = "${google_project.vault_gcp_demo.project_id}"

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-8"
    }
  }

  metadata_startup_script = "${file("./configure_requester.sh")}"

}

resource "google_compute_instance" "vault_sad" {
  name         = "vault-requester-sad"
  machine_type = "f1-micro"
  zone         = "europe-west1-b"
  project      = "${google_project.vault_gcp_demo.project_id}"

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-8"
    }
  }

  metadata_startup_script = "${file("./configure_requester.sh")}"

}

output "vault_server_instance_id" {
 value = "${google_compute_instance.vault_server.self_link}"
}

output "vault_happy_instance_id" {
 value = "${google_compute_instance.vault_happy.self_link}"
}

output "vault_sad_instance_id" {
 value = "${google_compute_instance.vault_sad.self_link}"
}
