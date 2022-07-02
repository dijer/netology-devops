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

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "single-instance"

  ami                    = "ami-ebd02392"
  instance_type          = "t2.micro"
  key_name               = "user1"
  monitoring             = true
  vpc_security_group_ids = ["sg-12345678"]
  subnet_id              = "subnet-eddcdzz4"

  tags = {
    Terraform   = "true"
    Environment = "dev"
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
