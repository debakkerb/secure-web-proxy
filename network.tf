resource "google_compute_network" "standard" {
  project                 = data.google_project.default.project_id
  name                    = "web-proxy-tst-network"
  auto_create_subnetworks = false

  depends_on = [google_project_service.apis]
}

resource "google_compute_subnetwork" "proxy" {
  project       = data.google_project.default.project_id
  name          = "proxy"
  network       = google_compute_network.standard.self_link
  region        = var.region
  ip_cidr_range = "10.0.0.0/22"
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}

resource "google_compute_subnetwork" "resource" {
  project                  = data.google_project.default.project_id
  name                     = "resources"
  network                  = google_compute_network.standard.self_link
  ip_cidr_range            = "10.10.0.0/16"
  region                   = var.region
  private_ip_google_access = true
}

resource "google_compute_firewall" "iap_ssh_access_rule" {
  project     = data.google_project.default.project_id
  name        = "ssh-iap-access-rule"
  network     = google_compute_network.standard.self_link
  description = "Firewall rule to allow IAP SSH access"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]

  target_service_accounts = [google_service_account.vm_identity.email]
}

resource "google_project_iam_member" "tcp_iam_access" {
  for_each = toset(var.iap_access_users)
  project  = data.google_project.default.project_id
  member   = each.value
  role     = "roles/compute.instanceAdmin.v1"
}

# resource "google_compute_route" "secure_web_proxy_next_hop" {
#   project      = data.google_project.default.project_id
#   name         = "secure-web-route"
#   network      = google_compute_network.standard.name
#   dest_range   = "0.0.0.0/0"
#   next_hop_ilb = google_network_services_gateway.default.addresses.0
#   tags         = ["all"]
# }
