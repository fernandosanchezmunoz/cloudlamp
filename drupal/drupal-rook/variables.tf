# //variables

# //master password is undefined for cloudsql and gke

variable "master_password" {
  default = "cloudlampcloudlamp"
}

# //project, admin

# These are populated from your gcloud config, from preflight.sh:

variable "gcp_project" {}
variable "gcp_region" {}
variable "gcp_zone" {}

# //network,security

# variable "network" {}
# variable "subnetwork" {}
# variable "tag" {}

# variable "ports" {
#   description = "Ports to open in the firewall. FIXME: separate ports_internal and ports_external"
#   type        = "list"
#   default     = [80, 443, 3306, 8080, 8081, 111, 2049, 1110, 4045]
# }

# //Storage - Shared filesystem
variable "fs_name" {
  default = "bitnami-fs"
}

variable "fs_size" {
  default = "200Gi"
}

variable "fs_mount_path" {
  default = "/bitnami"
}

//cloudsql service account

variable "cloudsql_service_account_name" {
  default = "cloudsql-service-account"
}

variable "cloudsql_client_role" {
  default = "roles/cloudsql.client"
}

variable "create_keys_role" {
  default = "roles/iam.serviceAccountKeyAdmin"
}

//cloudSQL

variable "cloudsql_instance" {
  default = "cloudlamp-sql-1"
}

variable "cloudsql_username" {
  default = "cloudlamp-user"
}

variable "cloudsql_tier" {
  default = "db-n1-standard-1"
}

variable "cloudsql_storage_type" {
  default = "SSD"
}

variable "cloudsql_db_version" {
  default = "MYSQL_5_7"
}

variable "cloudsql_db_creds_path" {
  default = "~/.ssh/cloudsql-tf-creds.json"
}

# //GKE

variable "gke_cluster_name" {
  default = "cloudlamp-gke-cluster"
}

variable "gke_cluster_size" {
  default = 3
}

variable "gke_cluster_version" {
  default = "1.8.8-gke.0"
}

variable "gke_machine_type" {
  default = "n1-standard-2"
}

variable "gke_max_cluster_size" {
  default = 10
}

variable "gke_username" {
  default = "cloudlamp-gke-client"
}

# //GKE service

variable "gke_service_name" {
  default = "cloudlamp-drupal-service"
}

variable "gke_app_name" {
  default = "cloudlamp-drupal-app"
}

variable "gke_drupal_image" {
  default = "bitnami/drupal:8.3.7-r0"
}

variable "drupal_username" {
  default = "cloudlamp-drupal-user"
}

variable "drupal_password" {
  default = "cloudlamp"
}

variable "drupal_email" {
  default = "user@example.com"
}

variable "gke_cloudsql_image" {
  default = "gcr.io/cloudsql-docker/gce-proxy:1.09"
}

# //networking


# variable "subnetcidr" {}
# variable "ext_ip_name" {}
# variable "domain" {}
# variable "dns_zone_name" {}
# variable "dns_name" {}


# //data
# data "google_compute_zones" "available" {}

