terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

variable project_id {
  type    = string
}

variable image_id {
  type    = string
}

provider "google" {
  project = var.project_id
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

resource "google_compute_firewall" "web" {
  name    = "packer-demoweb-firewall"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "8080"]
  }
  source_ranges = ["0.0.0.0/0"]
}


resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = var.image_id
    }
  }
  tags = ["${google_compute_firewall.web.name}"]
  metadata_startup_script = "#!/bin/bash\nsudo su - terraform -c 'cd /home/terraform/go/src/github.com/hashicorp/learn-go-webapp-demo/ && go run webapp.go & '"
  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }
}

output "instance_ip" {
  value = "http://${google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip}:8080"
}