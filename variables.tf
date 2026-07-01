variable "project_id" {
  description = "The GCP Project ID (e.g., gen-lang-client-xxxxxx)"
  type        = string
}

variable "region" {
  description = "The region to deploy to (Free Tier eligible: us-west1, us-central1, us-east1)"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The zone to deploy to"
  type        = string
  default     = "us-central1-a"
}

variable "instance_name" {
  description = "The name of the VM instance"
  type        = string
  default     = "free-tier-vm"
}

variable "ssh_user" {
  description = "The SSH username to create on the VM"
  type        = string
  default     = "gcp-user"
}

variable "ssh_public_key" {
  description = "The SSH public key content (e.g., ssh-rsa AAA...)"
  type        = string
}
variable "firewall_rules" {
  description = "List of firewall rules to create"
  type = list(object({
    name          = string
    direction     = string
    priority      = number
    source_ranges = list(string)
    allowed = list(object({
      protocol = string
      ports    = list(string)
    }))
  }))
  default = [
    {
      name          = "allow-ssh"
      direction     = "INGRESS"
      priority      = 1000
      source_ranges = ["0.0.0.0/0"]
      allowed = [
        {
          protocol = "tcp"
          ports    = ["22"]
        }
      ]
    }
  ]
}