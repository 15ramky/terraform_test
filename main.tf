provider "google" {
  credentials = "${file("account.json")}"
  project     = "${var.project_name}"
  region      = "us-west2"
}

variable "all_instances" {
  type    = "list"
  default = ["ubuntu-os-cloud/ubuntu-1604-lts", "ubuntu-os-cloud/ubuntu-1604-lts", "ubuntu-os-cloud/ubuntu-1604-lts", "ubuntu-os-cloud/ubuntu-1604-lts", "ubuntu-os-cloud/ubuntu-1604-lts"]
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
    Name     = "puppet agent"
    ssh-keys = "${var.ssh_user}:${file("${var.public_key_path}")}"

    startup-script = <<SCRIPT
    wget https://apt.puppetlabs.com/puppet5-release-xenial.deb
    sudo dpkg -i puppet5-release-xenial.deb
    sudo apt-get update -y
    apt-get install puppet-agent
    sudo systemctl start puppet
    sudo systemctl enable puppet
    SCRIPT
  }
}

resource "google_compute_instance" "master-instance" {
  count        = 1
  name         = "puppet"
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

    //startup-script = "./puppet-agent-startup-file.sh"
    startup-script = <<SCRIPT
    sudo yum update -y
    sudo rpm -Uvh https://yum.puppetlabs.com/puppet5/puppet5-release-el-7.noarch.rpm
    sudo yum install puppetserver -y
    # start and enable the puppet server service
    sudo systemctl start puppetserver
    sudo systemctl enable puppetserver
    sudo puppet agent --test -v
    SCRIPT
  }
}
