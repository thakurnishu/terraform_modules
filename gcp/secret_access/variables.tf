variable "service_account_email" {
  type        = string
  description = "Email of the service account to be granted access"
}

variable "secret_ids" {
  type        = list(string)
  description = "List of existing Secret Manager secret names to grant access to"
}

