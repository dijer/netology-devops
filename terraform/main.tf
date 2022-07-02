provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_region
}

resource "yandex_compute_instance" "vm" {
  count = 2
  name = "ubuntu"
  zone = "ru-central1-a"
  resources {
    cores = locals.cores[terraform.workspace]
    memory = 2
  }
  boot_disk {
    initialize_params {
      image_id = var.yc_compute_image_id
    }
  }
  network_interface {
    subnet_id = var.subnet_id
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_compute_instance" "vm2" {
  for_each = toset([ "stage", "prod" ])
  name = "ubuntu"
  zone = "ru-central1-a"
  resources {
    cores = locals.cores[each.key]
    memory = 2
  }
  boot_disk {
    initialize_params {
      image_id = var.yc_compute_image_id
    }
  }
  network_interface {
    subnet_id = var.subnet_id
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

locals {
  cores = {
    stage = 2
    prod = 4
  }
  count = {
    stage = 1
    prod = 2
  }
}
