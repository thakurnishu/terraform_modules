variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket"
}

variable "public_read_access" {
  type        = bool
  description = "Allow public read access to objects"
  default     = false
}

variable "static_website_enabled" {
  type        = bool
  description = "Enable Static Websiter Hosting"
  default     = false
}

variable "index_document" {
  type    = string
  default = "index.html"
}

variable "error_document" {
  type    = string
  default = "error.html"
}
variable "tags" {
  type = map(string)
}
