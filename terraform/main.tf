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

resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = "myidentity-pool"
  display_name              = "myidentity-pool"
}

resource "google_service_account" "sa_wif" {
  account_id   = "sa-wif"
  display_name = "SA utilisé pour les process utilisant le WIF"
}

resource "google_iam_workload_identity_pool_provider" "identity_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "myidentity-provider"

  display_name                       = "myidentity-provider"
  attribute_condition                = "attribute.repository==assertion.repository"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}