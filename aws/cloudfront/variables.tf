variable "s3_domain_name" {
  description = "The regional domain name of the S3 bucket"
  type        = string
}

variable "distribution_mode" {
  description = "Behavior preset: static_site or api"
  type        = string
  default     = "static_site"
}

variable "default_root_object" {
  description = "Default root object for CloudFront"
  type        = string
  default     = "index.html"
}
