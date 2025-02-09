data "google_project" "default" {
  project_id = var.project_id
}

resource "google_project_service" "apis" {
  for_each = toset([
    "compute.googleapis.com",
    "iap.googleapis.com",
    "networkservices.googleapis.com",
    "networksecurity.googleapis.com",
  ])
  project = data.google_project.default.project_id
  service = each.value
}