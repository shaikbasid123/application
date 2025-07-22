variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "my-app-458011"  # Replace with your actual project ID
}

variable "region" {
  description = "GCP Region"
  default     = "us-central1"
}

variable "zone" {
  default = "us-central1-a"
}

variable "network_name" {
  default = "tf-vpc"
}

variable "gke_cluster_name" {
  default = "tf-gke-cluster"
}

variable "db_instance_name" {
  default = "tf-mysql-instance"
}

variable "db_user" {
  description = "user for the database"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "name for the database"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Password for the database"
  type        = string
  sensitive   = true
}
