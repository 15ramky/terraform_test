provider "google" {
  credentials = "${file("account.json")}"
  project     = "${var.project_name}"
  region      = "us-east1"
}

variable "all_instances" {
  type    = "list"
  default = ["centos-cloud/centos-6", "centos-cloud/centos-7", "rhel-cloud/rhel-6", "rhel-cloud/rhel-7", "rhel-cloud/rhel-8", "ubuntu-os-cloud/ubuntu-1604-lts", "ubuntu-os-cloud/ubuntu-1810", "ubuntu-os-cloud/ubuntu-minimal-1604-lts"]
}

resource "google_compute_instance" "first-instance" {
  count        = 8
  name         = "instance-${count.index}"
  machine_type = "f1-micro"
  zone         = "us-east1-b"

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

  metadata_startup_script = "echo hi > /test.txt"
}
