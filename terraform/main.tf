terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.13.0"
    }
  }
}

locals {
  project_api_list = [
    "iam.googleapis.com"
  ]

  project = "helloworld-454409"
}

provider "google" {
  project = local.project
}



resource "google_project_service" "project_api" {
  for_each                   = toset(local.project_api_list)
  service                    = each.key
  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = "my-identity-pool"
  display_name              = "my-identity-pool"
}

resource "google_service_account" "sa_wif" {
  account_id   = "sa-wif"
  display_name = "SA utilisé pour les process utilisant le WIF"
}

resource "google_iam_workload_identity_pool_provider" "identity_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "my-identity-provider"

  display_name                       = "my-identity-provider"
  attribute_condition                = "attribute.repository==assertion.repository"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account_iam_member" "add_permission_serviceaccounttokencreator_on_sa_tf" {
  service_account_id = google_service_account.sa_wif.id
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "principalSet://iam.googleapis.com/projects/644621961258/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github_pool.workload_identity_pool_id}/attribute.repository/elkouhen/${google_iam_workload_identity_pool_provider.identity_provider.workload_identity_pool_provider_id}"
}