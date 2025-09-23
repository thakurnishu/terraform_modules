variable "project_name" {
  type        = string
  description = "Project identifier for naming"
}

variable "distribution_mode" {
  type        = string
  description = "Mode of distribution: static or api"
  default     = "static"
}

variable "default_root_object" {
  type        = string
  description = "Default root object (index.html for static sites)"
  default     = "index.html"
}

variable "s3_bucket_name" {
  type        = string
  description = "Name of the origin S3 bucket"
}

variable "s3_bucket_arn" {
  type        = string
  description = "ARN of the origin S3 bucket"
}

variable "s3_domain_name" {
  type        = string
  description = "Domain name of the S3 bucket (from bucket output)"
  default = ""
}

variable "s3_website_domain_name" {
  type        = string
  description = "Website Domain name of the S3 bucket (from bucket output)"
  default = ""
}

variable "public_read_access" {
  type        = bool
  description = "Whether the bucket is public (skip OAC if true)"
  default     = false
}

variable "origin_type" {
  type    = string
  default = "s3" # options: "s3" or "s3_website"
}
