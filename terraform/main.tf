terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.13.0"
    }
  }
}

provider "google" {
  project = "helloworld-454409"
}

locals {
  project_api_list = [
    "iam.googleapis.com"
  ]
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