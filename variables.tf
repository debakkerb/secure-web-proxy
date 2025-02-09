variable "iap_access_users" {
  description = "Members who require IAP access to the project"
  type        = set(string)
}

variable "project_id" {
  description = "Project ID where all resources will be created."
  type        = string
}

variable "region" {
  description = "Region in which resources will be created."
  type        = string
  default     = "europe-west1"
}
