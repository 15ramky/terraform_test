provider "google" {
  credentials = "${file("account.json")}"
  project     = "${var.project_name}"
  region      = "us-west2"
}

variable "all_instances" {
  type    = "list"
  default = ["centos-cloud/centos-6", "rhel-cloud/rhel-6", "rhel-cloud/rhel-7", "rhel-cloud/rhel-8", "ubuntu-os-cloud/ubuntu-1604-lts"]
}

variable "master-puppet" {
  type    = "string"
  default = "centos-cloud/centos-7"
}

resource "google_compute_instance" "first-instance" {
  count        = 5
  name         = "puppet-agent-${count.index}"
  machine_type = "f1-micro"
  zone         = "us-west2-a"

  tags = ["terraform"]

  boot_disk {
    initialize_params {
      image = "${element(var.all_instances, count.index)}"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata {
    Name     = "Terraform Demo"
    ssh-keys = "${var.ssh_user}:${file("${var.public_key_path}")}"
  }

  metadata_startup_script = "/bin/bash puppet-agent-startup-file.sh > ~/result.txt"
}

resource "google_compute_instance" "master-instance" {
  count        = 1
  name         = "puppet-master"
  machine_type = "n1-standard-4"
  zone         = "us-west2-a"

  tags = [
    "puppet-master",
  ]

  boot_disk {
    initialize_params {
      image = "${var.master-puppet}"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata {
    Name     = "puppet master"
    ssh-keys = "${var.ssh_user}:${file("${var.public_key_path}")}"
  }

  metadata_startup_script = "/bin/bash puppet-master-startup-file.sh> ~/result.txt"
}
