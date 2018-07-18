# CloudLAMP Terraform Variables

# These are populated from your gcloud config, from preflight.sh:

variable "gcp_project" {}
variable "gcp_region" {}
variable "gcp_zone" {}

variable "master_password" {
  default = "cloudlampcloudlamp"
}

variable "fs_name" {
  default = "bitnami-fs"
}

variable "fs_size" {
  default = "200Gi"
}

variable "fs_mount_path" {
  default = "/bitnami"
}

# =============================================================================
# NFS
# =============================================================================

variable "nfs_server_name" {
  default = "cloudlamp-nfs-server"
}

variable "nfs_server_os_image" {
  default = "debian-9-stretch-v20180611"
}

variable "nfs_disk_name" {
  default = "cloudlamp-nfs-disk"
}

variable "export_path" {
  default = "/var/nfsroot"
}

variable "nfs_machine_type" {
  default = "n1-standard-2"
}

variable "nfs_raw_disk_type" {
  default = "pd-standard"
}

variable "vol_1" {
  default = "drupal-vol"
}

variable "vol_1_size" {
  default = "200Gi"
}

variable "gke_nfs_mount_path" {
  default = "/bitnami/"
}

# =============================================================================
# CloudSQL
# =============================================================================

variable "cloudsql_service_account_name" {
  default = "cloudsql-service-account"
}

variable "cloudsql_client_role" {
  default = "roles/cloudsql.client"
}

variable "create_keys_role" {
  default = "roles/iam.serviceAccountKeyAdmin"
}

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

# =============================================================================
# GKE
# =============================================================================

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

# =============================================================================
# Drupal
# =============================================================================

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
