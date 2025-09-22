variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "public_read_access" {
  description = "Whether to allow public read access to the bucket"
  type        = bool
  default     = false
}
