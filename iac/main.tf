terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_artifact_registry_repository" "repo" {
  location      = var.region
  repository_id = "app-repo"
  format        = "DOCKER"
}

resource "google_service_account" "cloudrun_sa" {
  account_id   = "svc-cloudrun"
  display_name = "Cloud Run Deploy Service Account"
}

resource "google_cloud_run_service" "app" {
  name     = "devops-challenge"
  location = var.region

  template {
    spec {
      containers {
        image = var.image
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

output "cloudrun_url" {
  value = google_cloud_run_service.app.status[0].url
}
