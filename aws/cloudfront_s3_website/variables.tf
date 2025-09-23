variable "bucket_name" {
  type = string
}
variable "project_name" {
  type = string
}
variable "function_code" {
  type    = string
  default = ""
}

variable "default_root_object" {
  type    = string
  default = "index.html"
}

variable "enable_custom_domain" {
  type    = bool
  default = false
}
variable "website_custom_domain" {
  type    = string
  default = ""
  validation {
    condition = var.website_custom_domain == "" || can(regex("^[a-z0-9.-]+\\.[a-z]{2,}$", var.website_custom_domain))
    error_message = "Domain must be a valid domain name format."
  }
}

variable "use_cloudfront_function" {
  type    = bool
  default = false
}

variable "acm_region" {
  type = string
  default = ""
}

variable "tags" {
  type = map(string)
}
