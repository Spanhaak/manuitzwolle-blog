#
# Use the Google Cloud Platform Provider
#
provider "google" {
  project       = var.project
  region        = var.region
  zone          = var.zone
}

#
# Create the VPC network 
#
resource "google_compute_network" "default" {
  name                    = "manuitzwolle-vpc"
  auto_create_subnetworks = false
}

#
# Create the ip subnet in the VPC network
#
resource "google_compute_subnetwork" "default" {
  name          = "manuitzwolle-subnet"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.default.id
}

#
# Create firewall entries to allow certain traffic
#
resource "google_compute_firewall" "allow_ssh" {
  name          = "allow-ssh"
  network       = "manuitzwolle-vpc"
  target_tags   = ["allow-ssh"]
  source_ranges = [var.ip]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "https" {
  name          = "https"
  network       = "manuitzwolle-vpc"
  target_tags   = ["https"]
  source_ranges = [var.ip]

  allow {
    protocol = "tcp"
    ports    = ["80","443","2368"]
  }
}

resource "google_compute_firewall" "allow_oslogin" {
  name          = "allow-oslogin"
  network       = "manuitzwolle-vpc"
  target_tags   = ["allow-oslogin"]
  source_ranges = ["35.235.240.0/20"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

#
# Create an external IP address
#
resource "google_compute_address" "static" {
  name         = "manuitzwolle-address"
  address_type = "EXTERNAL"
  region       = "europe-west4"
}

#
# Create the VM
#
data "google_compute_image" "debian_image" {
  family  = "ubuntu-2004-lts"
  project = "ubuntu-os-cloud"
}

resource "google_compute_instance" "instance_with_ip" {
  name         = "muz"
  machine_type = "e2-small"
  zone         = "europe-west4-a"
  tags = ["allow-ssh", "allow-oslogin"]
  metadata = {
    enable-oslogin: "TRUE"
  }

  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian_image.self_link
    }
  }

  network_interface {
    network = "manuitzwolle-vpc"
    subnetwork = "manuitzwolle-subnet"
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }
  
}

#
# create SSH access
#
data "google_client_openid_userinfo" "me" {
}

resource "google_os_login_ssh_public_key" "cache" {
  user =  data.google_client_openid_userinfo.me.email
  project = var.project
  key = file(var.path)
}

resource "google_project_iam_member" "iam_osadminlogin" {
  project = var.project
  role    = "roles/compute.osAdminLogin"
  member  = "user:${data.google_client_openid_userinfo.me.email}"
}

resource "google_project_iam_member" "iam_serviceaccountuser" {
  project = var.project
  role    = "roles/iam.serviceAccountUser"
  member  = "user:${data.google_client_openid_userinfo.me.email}"
}

resource "google_compute_project_metadata" "default" {
  metadata = {
    enable-oslogin = "TRUE"
  }
}