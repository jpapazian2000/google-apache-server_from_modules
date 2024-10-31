variable "google_project" {
    description = "project id in gcp"
}

variable "google_region" {
    description = "gcp region in which to deploy"
}

variable "google_zone" {
    description = "gcp zone of the region"
}

variable "sysops_info" {
    description = "tag to be cross-checked by sentinel in snow"
}

variable "prefix" {
     description = "prefix for all resources in this project"
}
variable "subnet_prefix" {
    description = "subnet for the server to be deployed in"
}
variable "allowed_ip" {
    description = "my ip at home to restrict access"
}
variable "machine_type" {
    description = "a small one so that it's not too expensive :-) "
}
#variable "hcp_image" {
    #description = "that's the image from hcp"
#}
#variable "subnetwork" {
    #description = "that's the subnet that is created by gce"
#}
