variable "cloud_run_name" {
  type = string
}
variable "deletion_protection" {
  type        = bool
  description = "if false service is allowed to be deleted"
}
variable "ingress" {
  type        = string
  description = "Possible values are: INGRESS_TRAFFIC_ALL, INGRESS_TRAFFIC_INTERNAL_ONLY, INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
}
variable "location" {
  type = string
}
variable "image" {
  type = string
}
variable "port" {
  type = number
}
variable "cpu" {
  type        = string
  description = "Only memory, CPU, and nvidia.com/gpu are supported. Use key cpu for CPU limit, memory for memory limit, nvidia.com/gpu for gpu limit. Note: The only supported values for CPU are '1', '2', '4', and '8'. Setting 4 CPU requires at least 2Gi of memory"
}
variable "memory" {
  type        = string
  description = "Only memory, CPU, and nvidia.com/gpu are supported. Use key cpu for CPU limit, memory for memory limit, nvidia.com/gpu for gpu limit. Note: The only supported values for CPU are '1', '2', '4', and '8'. Setting 4 CPU requires at least 2Gi of memory"
}
variable "allow_authenticated" {
  type        = bool
  description = "If true, allow 'allUsers' to invoke the service. If false, only authenticated users can invoke."
}
variable "service_account" {
  type    = string
  default = ""
}
