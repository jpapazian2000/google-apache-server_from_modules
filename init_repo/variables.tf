variable "tfe_token" {
  description = "token for hcp terraform"
}

variable "gcp_project_id" {
  type        = string
  description = "The ID for your GCP project"
}

variable "hcpt_organization" {
    default = "jpapazian-org"
}

variable "hcpt_project_name" {
  description = "default project already existing"
  default = "dyn_creds_gcp"
}

variable "hcpt_workspace_name" {
    description = "workspace to create"
    default = "another_google_ubuntu_workspace"
}

variable "oauth_token" {
    description = "oauth_token to use for vcs connection"
}

variable "hcp_vs"  {
    description = "default variable set for hcp creds"
    default = "hcp_credentials"
}

variable "google_vs" {
    description = "default variable set for google credentials"
    default = "google_credentials"
}

variable "allowed_ip" {
    description = "authorized ip to connect to the ubuntu vm"
    default = "82.124.90.200/32"
}

variable "machine_type" {
    description = "default machine type for ubuntu vm"
    default = "e2-small"
}

variable "prefix" {
    description = "prefix for all resources"
    default = "jp"
}

variable "subnet_prefix" {
    description = "google subnet where vm will be instanciated"
    default = "10.7.0.0/16"
}

variable "sysops_info" {
    description =  "servicenow value to be checked by api call"
}

###Following variables are needed for the WIF GOOGLE INTEGRATION
variable "tfc_gcp_audience" {
  type        = string
  default     = ""
  description = "The audience value to use in run identity tokens if the default audience value is not desired."
}

variable "gcp_service_list" {
  description = "APIs required for the project"
  type        = list(string)
  default = [
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "sts.googleapis.com",
    "iamcredentials.googleapis.com"
  ]
}




