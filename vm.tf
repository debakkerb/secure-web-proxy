resource "google_service_account" "vm_identity" {
  project    = data.google_project.default.project_id
  account_id = "vm-operator"
}

resource "google_service_account_iam_member" "swp_vm_sa_access" {
  for_each           = var.iap_access_users
  service_account_id = google_service_account.vm_identity.id
  role               = "roles/iam.serviceAccountUser"
  member             = each.value
}

data "google_compute_image" "debian" {
  family  = "debian-12"
  project = "debian-cloud"
}

resource "google_compute_instance" "swp_tst_vm" {
  project                   = data.google_project.default.project_id
  name                      = "swp-tst-vm"
  machine_type              = "n2-standard-2"
  zone                      = "europe-west1-b"
  tags                      = ["ssh", "all"]
  allow_stopping_for_update = true
  deletion_protection       = false

  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian.self_link
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.resource.self_link
  }

  metadata = {
    enable-oslogin-2fa : "TRUE"
  }

  service_account {
    email  = google_service_account.vm_identity.email
    scopes = ["cloud-platform"]
  }
}

resource "google_iap_tunnel_instance_iam_member" "swp_tst_vm_tcp_access" {
  for_each = var.iap_access_users
  project  = data.google_project.default.project_id
  zone     = google_compute_instance.swp_tst_vm.zone
  instance = google_compute_instance.swp_tst_vm.name
  role     = "roles/iap.tunnelResourceAccessor"
  member   = each.value
}

resource "google_compute_instance_iam_member" "swp_tst_vm_oslogin_access" {
  for_each      = var.iap_access_users
  project       = data.google_project.default.project_id
  zone          = google_compute_instance.swp_tst_vm.zone
  instance_name = google_compute_instance.swp_tst_vm.name
  role          = "roles/compute.osLogin"
  member        = each.value
}