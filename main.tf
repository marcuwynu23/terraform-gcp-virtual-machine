provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}

# Create a VPC network
resource "google_compute_network" "vpc_network" {
  name                    = "free-tier-vpc"
  auto_create_subnetworks = false
}

# Create a subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "free-tier-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

# Allow SSH traffic
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-enabled"]
}

# Create the VM instance (Free Tier eligible)
resource "google_compute_instance" "vm_instance" {
  name         = var.instance_name
  machine_type = "e2-micro" # Free Tier eligible
  zone         = var.zone

  tags = ["ssh-enabled"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 30 # Free Tier eligible (up to 30GB)
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id

    access_config {
      # Include this block to give the instance a public IP address
      # Note: One non-preemptible e2-micro VM instance per month is free.
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file("~/.ssh/id_rsa.pub")}"
  }

  # Optional: metadata_startup_script can be added here
}
