##############################################
# IAM Binding Logic for Cloud Run Access
#
# This logic determines who can invoke the service
# based on the combination of `access_service_account`
# and `public_access` variables.
#
# | access_service_account  | public_access | IAM Member                                | Access Type                      |
# |-------------------------|---------------|-------------------------------------------|----------------------------------|
# | ❌ (not set)            | true          | allUsers                                  | Public (Unauthenticated)         |
# | ❌ (not set)            | false         | allAuthenticatedUsers                     | Private (Any Authenticated User) |
# | ✅ (set)                | true or false | serviceAccount:<access_service_account>   | Private (Only specific SA)       |
#
# Note:
# - If `access_service_account` is set, it overrides `public_access`.
# - If neither are set, the service is private to authenticated users.
##############################################



locals {
  has_service_account        = length(var.service_account) > 0
  has_access_service_account = length(var.access_service_account) > 0
}

resource "google_cloud_run_v2_service" "default" {
  name                = var.cloud_run_name
  location            = var.location
  deletion_protection = var.deletion_protection
  ingress             = var.ingress

  template {
    service_account = local.has_service_account ? var.service_account : null
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

      dynamic "env" {
        for_each = var.secret_env_vars
        content {
          name = env.value.name
          value_source {
            secret_key_ref {
              secret  = env.value.secret
              version = env.value.version
            }
          }
        }
      }

      dynamic "env" {
        for_each = var.config_env_vars
        content {
          name  = env.value.name
          value = env.value.value
        }
      }
    }
  }
}

# If access_service_account is defined → bind it as the invoker (authenticated only)
resource "google_cloud_run_service_iam_member" "invoker_authenticated" {
  count    = local.has_access_service_account ? 1 : 0
  location = google_cloud_run_v2_service.default.location
  project  = google_cloud_run_v2_service.default.project
  service  = google_cloud_run_v2_service.default.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${var.access_service_account}"
}

# If access_service_account is not defined → allow unauthenticated access (if public_access = true)
resource "google_cloud_run_service_iam_member" "invoker_public" {
  count    = local.has_access_service_account || !var.public_access ? 0 : 1
  location = google_cloud_run_v2_service.default.location
  project  = google_cloud_run_v2_service.default.project
  service  = google_cloud_run_v2_service.default.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# If access_service_account is not defined and public_access is false → only allow authenticated users
resource "google_cloud_run_service_iam_member" "invoker_authenticated_users" {
  count    = local.has_access_service_account || var.public_access ? 0 : 1
  location = google_cloud_run_v2_service.default.location
  project  = google_cloud_run_v2_service.default.project
  service  = google_cloud_run_v2_service.default.name
  role     = "roles/run.invoker"
  member   = "allAuthenticatedUsers"
}

