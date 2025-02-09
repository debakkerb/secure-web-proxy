resource "google_network_services_gateway" "default" {
  project                              = data.google_project.default.project_id
  name                                 = "secure-web-gateway"
  location                             = var.region
  type                                 = "SECURE_WEB_GATEWAY"
  ports                                = ["443"]
  scope                                = var.region
  network                              = google_compute_network.standard.id
  subnetwork                           = google_compute_subnetwork.resource.id
  delete_swg_autogen_router_on_destroy = true
  routing_mode                         = "NEXT_HOP_ROUTING_MODE"
}

resource "google_network_security_gateway_security_policy" "default" {
  project  = data.google_project.default.project_id
  name     = "web-gateway-policy"
  location = var.region
}

resource "google_network_security_gateway_security_policy_rule" "default" {
  project                 = data.google_project.default.project_id
  name                    = "wikipedia-access"
  location                = var.region
  enabled                 = true
  gateway_security_policy = google_network_security_gateway_security_policy.default.name
  priority                = 100
  session_matcher         = "host() == 'wikipedia.org'"
  basic_profile           = "ALLOW"
}

resource "google_network_security_url_lists" "default" {
  project  = data.google_project.default.project_id
  name     = "wikipedia"
  location = var.region
  values   = ["www.wikipedia.org", "www.wikipedia.com"]
}