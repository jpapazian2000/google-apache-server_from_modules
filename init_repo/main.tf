terraform {
    required_providers {
      tfe = {
      source = "hashicorp/tfe"
      version = "0.59.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.6.3"
    }
    }
}

provider "random" {
  # Configuration options
}

provider "tfe" {
  hostname = "app.terraform.io"
  token = var.tfe_token
  organization = var.hcpt_organization
}

data "tfe_project" "ubuntu_google" {
  name = var.hcpt_project_name
  organization = var.hcpt_organization
}

resource "tfe_oauth_client" "github_oauth_client" {
  api_url = "https://api.github.com"
  http_url = "https://github.com"
  oauth_token = var.oauth_token
  service_provider = "github"
}

resource "tfe_workspace" "ubuntu_workspace" {
    name = var.hcpt_workspace_name
    queue_all_runs = false
    vcs_repo {
        branch = "main"
        identifier = "jpapazian2000/google-apache-server_from_modules"
        oauth_token_id = tfe_oauth_client.github_oauth_client.oauth_token_id
    }
    project_id = data.tfe_project.ubuntu_google.id
    tag_names = [
      "infra",
      "ubuntu",
      "google",
      "modules"
    ]
    assessments_enabled = true
}

resource "tfe_variable" "allowed_ip" {
  workspace_id = tfe_workspace.ubuntu_workspace.id
  category = "terraform"
  key = "allowed_ip"
  value = var.allowed_ip
  description = "autorized ip for connection to the ubuntu machine"

}

resource "tfe_variable" "machine_type" {
  workspace_id = tfe_workspace.ubuntu_workspace.id
  category = "terraform"
  key = "machine_type"
  value = var.machine_type
  description = "e2-small n1-standard-2 "
}

resource "tfe_variable" "prefix" {
  workspace_id = tfe_workspace.ubuntu_workspace.id
  category = "terraform"
  key = "prefix"
  value = var.prefix
}

resource "tfe_variable" "subnet_prefix" {
  workspace_id = tfe_workspace.ubuntu_workspace.id
  category = "terraform"
  key = "subnet_prefix"
  value = var.subnet_prefix
}

resource "tfe_variable" "sysops_info" {
  workspace_id = tfe_workspace.ubuntu_workspace.id
  category = "terraform"
  key = "sysops_info"
  value = var.sysops_info
  description = "{ \"APPLI1 DEV AZURE\" : \"LOW\", \"APPLI2 DEV AZURE\" : \"HIGH\" }"
}

data "tfe_variable_set" "hcp_credentials" {
  name         = var.hcp_vs
  organization = var.hcpt_organization
}

data "tfe_variable_set" "google_credentials" {
  name         = var.google_vs
  organization = var.hcpt_organization
}

resource "tfe_workspace_variable_set" "hcp_credentials" {
  variable_set_id = data.tfe_variable_set.hcp_credentials.id
  workspace_id = tfe_workspace.ubuntu_workspace.id
}

resource "tfe_workspace_variable_set" "google_credentials" {
  variable_set_id = data.tfe_variable_set.google_credentials.id
  workspace_id = tfe_workspace.ubuntu_workspace.id
}
###The following variables are the ones needed for the WIF integration with Google
# The following variables must be set to allow runs
# to authenticate to GCP.
#
# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable
resource "tfe_variable" "enable_gcp_provider_auth" {
  workspace_id = tfe_workspace.ubuntu_workspace.id

  key      = "TFC_GCP_PROVIDER_AUTH"
  value    = "true"
  category = "env"

  description = "Enable the Workload Identity integration for GCP."
}

# The provider name contains the project number, pool ID,
# and provider ID. This information can be supplied using
# this TFC_GCP_WORKLOAD_PROVIDER_NAME variable, or using
# the separate TFC_GCP_PROJECT_NUMBER, TFC_GCP_WORKLOAD_POOL_ID,
# and TFC_GCP_WORKLOAD_PROVIDER_ID variables below if desired.
#
resource "tfe_variable" "tfc_gcp_workload_provider_name" {
  workspace_id = tfe_workspace.ubuntu_workspace.id

  key      = "TFC_GCP_WORKLOAD_PROVIDER_NAME"
  value    =  google_iam_workload_identity_pool_provider.tfc_provider.name
  category = "env"

  description = "The workload provider name to authenticate against."
}

# Uncomment the following variables and comment out
# tfc_gcp_workload_provider_name if you wish to supply this
# information in separate variables instead!

# resource "tfe_variable" "tfc_gcp_project_number" {
#   workspace_id = data.tfe_workspace.ubuntu_workspace.id

#   key      = "TFC_GCP_PROJECT_NUMBER"
#   value    = data.google_project.project.number
#   category = "env"

#   description = "The numeric identifier of the GCP project"
# }

# resource "tfe_variable" "tfc_gcp_workload_pool_id" {
#   workspace_id = data.tfe_workspace.ubuntu_workspace.id

#   key      = "TFC_GCP_WORKLOAD_POOL_ID"
#   value    = google_iam_workload_identity_pool.tfc_pool.workload_identity_pool_id
#   category = "env"

#   description = "The ID of the workload identity pool."
# }

# resource "tfe_variable" "tfc_gcp_workload_provider_id" {
#   workspace_id = data.tfe_workspace.ubuntu_workspace.id

#   key      = "TFC_GCP_WORKLOAD_PROVIDER_ID"
#   value    = google_iam_workload_identity_pool_provider.tfc_provider.workload_identity_pool_provider_id
#   category = "env"

#   description = "The ID of the workload identity pool provider."
# }

resource "tfe_variable" "tfc_gcp_service_account_email" {
  workspace_id = tfe_workspace.ubuntu_workspace.id

  key      = "TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL"
  value    = google_service_account.tfc_service_account.email
  category = "env"

  description = "The GCP service account email runs will use to authenticate."
}

# The following variables are optional; uncomment the ones you need!

# resource "tfe_variable" "tfc_gcp_audience" {
#   workspace_id = data.tfe_workspace.ubuntu_workspace.id

#   key      = "TFC_GCP_WORKLOAD_IDENTITY_AUDIENCE"
#   value    = var.tfc_gcp_audience
#   category = "env"

#   description = "The value to use as the audience claim in run identity tokens"
# }