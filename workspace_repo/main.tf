terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.4.0"
    }
    #kubernetes = {
    #  source = "hashicorp/kubernetes"
    #  version = "2.32.0"
   #} 
 }

}

provider "google" {
  project = var.google_project
  region  = var.google_region
  zone    = var.google_zone
}

#provider "kubernetes" {
   #Configuration options
#}
#module "uuid" {
#  source  = "Kalepa/uuid/random"
#  version = "0.2.1"
#}

provider "hcp" {}

#locals {
  #valid_tags = ["dev", "int", "prod"]

  #matching_tags = [for tag in data.tfe.terraform.workspace.ubuntu_workspace.tag_names : tag if contains (local.valid_tags, tag)]

  #selected_tags = length(local.matching_tags) > 0 ? local.matching_tags[0] : "no-match"
#}

data "hcp_packer_version" "ubuntu" {
    bucket_name = "ubuntu-apache-gcp"
    channel_name = "${local.selected_tags}"
}

data "hcp_packer_artifact" "apache_gce" {
    bucket_name = "ubuntu-apache-gcp"
    platform = "gce"
    version_fingerprint = data.hcp_packer_version.ubuntu.fingerprint
    region = "europe-west9-a"
}

module "gcp-network" {
    source = "app.terraform.io/jpapazian-org/network_module/google"
    prefix = var.prefix
    subnet_prefix = var.subnet_prefix
    allowed_ip = var.allowed_ip
}

module "gcp-infra" {
    source  = "app.terraform.io/jpapazian-org/infra_module/google"
    #version = "1.0.6"
    machine_type = var.machine_type
    hcp_image = data.hcp_packer_artifact.apache_gce.external_identifier
    subnetwork = module.gcp-network.vpc_subnet_id
    #subnet_id= module.gcp-network.vpc_subnet_id
    sysops_info = var.sysops_info
    prefix = var.prefix
    #company = "${local.selected_tags}"
    company = var.company
    color = var.color
}

#check "revocation_check"{
#
#}

#check "image_version_check" {
#
#}



