# Fetch existing secrets by name
data "google_secret_manager_secret" "secrets" {
  for_each  = toset(var.secret_ids)
  secret_id = each.value
}

# Grant secretAccessor role to the service account for each secret
resource "google_secret_manager_secret_iam_member" "access" {
  for_each  = data.google_secret_manager_secret.secrets

  secret_id = each.value.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.service_account_email}"
}

