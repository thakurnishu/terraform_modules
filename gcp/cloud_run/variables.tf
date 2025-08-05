variable "cloud_run_name" {
  type = string
  description = "Name of the Cloud Run service"
}
variable "location" {
  type = string
  description = "Location for the Cloud Run service"
}
variable "deletion_protection" {
  type        = bool
  description = "If true, prevents the service from being deleted"
}
variable "ingress" {
  type        = string
  description = "Possible values are: INGRESS_TRAFFIC_ALL, INGRESS_TRAFFIC_INTERNAL_ONLY, INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
}

variable "service_account" {
  type        = string
  description = "Service account for Cloud Run to run as"
  default     = ""
}

variable "access_service_account" {
  type        = string
  description = "Service account allowed to access/invoke the Cloud Run service"
  default     = ""
}

variable "public_access" {
  type        = bool
  description = "If true, allow unauthenticated (public) access when no access_service_account is specified"
  default     = false
}


variable "image" {
  type = string
  description = "Container image to deploy on Cloud Run. Must be a valid container image URL"
}
variable "port" {
  type = number
  description = "Port on which the container listens. Must be a valid port number (e.g., 8080)"
}
variable "cpu" {
  type        = string
  description = "CPU limit for the Cloud Run service. Must be a valid CPU size (e.g., '1', '2', etc.)"
}
variable "memory" {
  type        = string
  description = "Memory limit for the Cloud Run service. Must be a valid memory size (e.g., '512Mi', '1Gi', etc.)"
}
variable "secret_env_vars" {
  description = "Optional list of environment variables sourced from Secret Manager"
  type = list(object({
    name    = string
    secret  = string
    version = string
  }))
  default = []

  validation {
    condition     = length(var.secret_env_vars) == 0 || length(var.service_account) > 0
    error_message = "You must specify a service_account when using secret_env_vars."
  }
}
variable "config_env_vars" {
  description = "Optional list of environment variables sourced from config"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}
