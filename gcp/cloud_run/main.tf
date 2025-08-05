locals {
  has_service_account = length(var.service_account) > 0
}

resource "google_cloud_run_v2_service" "default" {
  name                = var.cloud_run_name
  location            = var.location
  deletion_protection = var.deletion_protection
  ingress             = var.ingress

  template {
    containers {
      image = var.image

      ports {
        container_port = var.port
      }

      resources {
        limits = {
          cpu    = var.cpu
          memory = var.memory
        }
      }
    }
  }
}
resource "google_cloud_run_service_iam_member" "unauthenticated" {
  count     = local.has_service_account ? 0 : 1
  location  = google_cloud_run_v2_service.default.location
  project   = google_cloud_run_v2_service.default.project
  service   = google_cloud_run_v2_service.default.name
  role      = "roles/run.invoker"
  member    = var.allow_unauthenticated ? "allUsers" : "allAuthenticatedUsers"
}

resource "google_cloud_run_service_iam_member" "invoker" {
  count     = local.has_service_account ? 1 : 0
  location  = google_cloud_run_v2_service.default.location
  project   = google_cloud_run_v2_service.default.project
  service   = google_cloud_run_v2_service.default.name
  role      = "roles/run.invoker"
  member    = "serviceAccount:${var.service_account}"
}


output "url" {
  value = google_cloud_run_v2_service.default.uri
}
