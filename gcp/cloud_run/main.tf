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

data "google_iam_policy" "cloud_run_policy" {
  dynamic "binding" {
    for_each = local.has_service_account ? [1] : []
    content {
      role    = "roles/run.invoker"
      members = ["serviceAccount:${var.service_account}"]
    }
  }

  dynamic "binding" {
    for_each = !local.has_service_account ? [1] : []
    content {
      role    = "roles/run.invoker"
      members = var.allow_unauthenticated ? ["allUsers"] : ["allAuthenticatedUsers"]
    }
  }
}

resource "google_cloud_run_service_iam_policy" "auth" {
  location    = google_cloud_run_v2_service.default.location
  project     = google_cloud_run_v2_service.default.project
  service     = google_cloud_run_v2_service.default.name
  policy_data = data.google_iam_policy.cloud_run_policy.policy_data
}

output "url" {
  value = google_cloud_run_v2_service.default.uri
}
