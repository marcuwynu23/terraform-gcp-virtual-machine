output "vm_external_ip" {
  description = "The external IP address of the VM instance"
  value       = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}

output "vm_internal_ip" {
  description = "The internal IP address of the VM instance"
  value       = google_compute_instance.vm_instance.network_interface[0].network_ip
}

output "ssh_connection_command" {
  description = "Command to connect to the VM via SSH"
  value       = "ssh -i ~/.ssh/id_rsa ${var.ssh_user}@${google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip}"
}
