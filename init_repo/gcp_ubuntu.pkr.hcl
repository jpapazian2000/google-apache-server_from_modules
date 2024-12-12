packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1"
    }
  }
}
#variable "version" {
#type    = string
#default = "1.0.0"
#}
variable "project_id" {
  type    = string
  default = "hc-8ceaefae6c1a495096c2916e3f9"
}

variable "zone" {
  type    = string
  default = "europe-west9-a"
}

variable "customer" {
  type    = string
  default = "SOME-COMPANY.COM"
}


source "googlecompute" "test-image" {
  project_id          = var.project_id
  source_image_family = "ubuntu-2204-lts"
  zone                = var.zone
  image_description   = "Created with HashiCorp Packer from Cloudbuild"
  ssh_username        = "root"
  tags                = ["packer"]
  #impersonate_service_account = var.builder_sa
}

build {
  hcp_packer_registry {
    bucket_name = "ubuntu-apache-gcp"
    description = "an image for building a standard ubuntu apache vm ON GCP"

    bucket_labels = {
      "owner"          = "platform-team"
      "os"             = "Ubuntu",
      "ubuntu-version" = "Focal 20.04",
    }

    build_labels = {
      "build-time"   = timestamp()
      "build-source" = basename(path.cwd)
    }
  }

  sources = [
    "sources.googlecompute.test-image"
  ]
  provisioner "shell" {
    inline = [
      "echo customizing apache web server",
      "sleep 10",
      "sudo apt-get update",
      "sudo apt-get install -y apache2",
      "sudo systemctl start apache2",
      "sudo systemctl enable apache2",
      "echo \"<h1>Terraform Ready for ${var.customer} VERSION 4.0</h1>\" | sudo tee /var/www/html/index.html",
    ]
  }
}
