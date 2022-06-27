provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_region
}

resource "yandex_compute_instance" "vm" {
  name = "ubuntu"
  zone = "ru-central1-a"
  resources {
    cores = 2
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
