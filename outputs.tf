output "ssh_cmd" {
  value = "gcloud compute ssh ${google_compute_instance.swp_tst_vm.name} --zone ${google_compute_instance.swp_tst_vm.zone} --project ${data.google_project.default.project_id}"
}