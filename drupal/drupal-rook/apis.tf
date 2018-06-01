# These are listed separately to unauthoratatively enable them, rather
# than set the total APIs to just those listed below:
resource "google_project_service" "cloudresourcemanager" {
  service = "cloudresourcemanager.googleapis.com"
}

resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}

resource "google_project_service" "container" {
  service = "container.googleapis.com"
}

resource "google_project_service" "dns" {
  service = "dns.googleapis.com"
}

resource "google_project_service" "iam" {
  service = "iam.googleapis.com"
}

resource "google_project_service" "replicapool" {
  service = "replicapool.googleapis.com"
}

resource "google_project_service" "replicapoolupdater" {
  service = "replicapoolupdater.googleapis.com"
}

resource "google_project_service" "resourceviews" {
  service = "resourceviews.googleapis.com"
}

resource "google_project_service" "sql-component" {
  service = "sql-component.googleapis.com"
}

resource "google_project_service" "sqladmin" {
  service = "sqladmin.googleapis.com"
}

resource "google_project_service" "storage-api" {
  service = "storage-api.googleapis.com"
}

resource "google_project_service" "storage-component" {
  service = "storage-component.googleapis.com"
}
