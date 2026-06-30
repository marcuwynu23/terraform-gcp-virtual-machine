# terraform-gcp-virtual-machine

This Terraform project provisions a Google Cloud Platform (GCP) virtual machine instance.

## Architecture

### Flowchart
```mermaid
graph TD
    A[User] -->|terraform apply| B(Terraform)
    B -->|Auth via gcloud ADC| C{GCP API}
    C -->|Create| D[VPC Network]
    C -->|Create| E[Subnet]
    C -->|Create| F[Firewall Rule: SSH]
    C -->|Provision| G[e2-micro VM Instance]
    G -->|Attach| D
    G -->|Attach| E
    G -->|Apply| F
```

### Sequence Diagram
```mermaid
sequenceDiagram
    participant U as User
    participant T as Terraform
    participant G as gcloud CLI
    participant API as GCP Cloud API

    U->>G: gcloud auth application-default login
    G-->>U: Authentication Success
    U->>T: terraform apply
    T->>API: Authenticate using ADC
    T->>API: Plan & Create Resources
    API-->>T: Resources Provisioned
    T-->>U: Outputs (IP, SSH Command)
    U->>API: SSH to VM
```

## Instance Specifications
- **Machine Type**: `e2-micro` (2 vCPUs, 1 GB RAM).
- **Regions**: `us-west1`, `us-central1`, or `us-east1`.
- **Disk**: 30 GB standard persistent disk (`pd-standard`).
- **External IP**: One non-preemptible external IP address.

## Prerequisites
1.  **Google Cloud SDK**: [Installed and initialized](https://cloud.google.com/sdk/docs/install).
2.  **Terraform**: [Installed](https://developer.hashicorp.com/terraform/downloads).

## Setup & Deployment

1.  **Authenticate and Select Project**:
    Instead of using a service account JSON file, this project uses your local `gcloud` credentials.
    ```bash
    # Authenticate
    gcloud auth application-default login

    # Select your project
    gcloud config set project your-project-id
    ```

2.  **Configure Variables**:
    Create a `terraform.tfvars` file based on the example:
    ```hcl
    project_id = "your-project-id"
    region     = "us-central1"
    zone       = "us-central1-a"
    ssh_user   = "gcp-user"
    ```

3.  **Deploy**:
    ```bash
    terraform init
    terraform apply
    ```

4.  **Connect**:
    Use the `ssh_connection_command` provided in the output.

## Usage as a Module

Reference this repository as a Terraform module in your own configurations:

> **Option 1**: Terraform Registry (recommended)
> ```hcl
> module "virtual-machine" {
>   source  = "marcuwynu23/virtual-machine/gcp"
>   version = "1.0.0"
>
>   project_id    = var.project_id
>   region        = "us-central1"
>   zone          = "us-central1-a"
>   instance_name = "my-app-vm"
>   ssh_user      = "gcp-user"
> }
> ```
>
> **Option 2**: GitHub source
> ```hcl
> module "virtual-machine" {
>   source = "github.com/marcuwynu23/terraform-gcp-virtual-machine?ref=main"
>
>   project_id    = var.project_id
>   region        = "us-central1"
>   zone          = "us-central1-a"
>   instance_name = "my-app-vm"
>   ssh_user      = "gcp-user"
> }
> ```

## Variables

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `project_id` | GCP project ID | `string` | (required) |
| `region` | GCP region (free tier: us-west1, us-central1, us-east1) | `string` | `"us-central1"` |
| `zone` | GCP zone | `string` | `"us-central1-a"` |
| `instance_name` | VM instance name | `string` | `"free-tier-vm"` |
| `ssh_user` | SSH username | `string` | `"gcp-user"` |

## Outputs

| Output | Description |
|--------|-------------|
| `vm_external_ip` | External IP address of the VM |
| `vm_internal_ip` | Internal IP address of the VM |
| `ssh_connection_command` | SSH connection command |

## Resources Created

- `google_compute_network.vpc_network` – VPC network for the VM
- `google_compute_subnetwork.subnet` – Subnet for the VM
- `google_compute_firewall.allow_ssh` – Firewall rule allowing SSH (port 22)
- `google_compute_instance.vm_instance` – Compute Engine VM instance (Free Tier eligible)
## CI/CD Setup (GitHub Actions)

### Prerequisites
1. **Create a GCS bucket** for Terraform remote state:
    ```bash
    gcloud storage buckets create gs://your-terraform-state-bucket \
      --location=us-central1 \
      --uniform-bucket-level-access
    ```

2. **Create a service account** with necessary permissions and generate a JSON key:
    - GCP Console → IAM & Admin → Service Accounts → Create Service Account
    - Grant the required roles for this module
    - Keys → Add Key → Create New Key → JSON
    - Copy the entire JSON file contents

3. **Add GitHub secrets**:

    | Secret Name | Value |
    |---|---|
    | `GCP_SA_KEY` | Full JSON key from step 2 |
    | `TF_BUCKET_NAME` | Your GCS bucket name |
    | `TF_BUCKET_PREFIX` | Bucket prefix/path (e.g., `gcp-virtual-machine`) |

4. **Run the workflow**:
    - **Apply**: Go to Actions → **CD - GCP Virtual Machine (Apply)** → fill in all inputs
    - **Destroy**: Go to Actions → **CD - GCP Virtual Machine (Destroy)** → fill in essential inputs

> Alternatively, create a `backend.tfvars` from `backend.tfvars.example` and run `terraform init -backend-config="backend.tfvars"` for local use.

## Remote State (GCS Backend)

This module uses Google Cloud Storage (GCS) as the Terraform backend for remote state management:

```hcl
terraform {
  backend "gcs" {
    bucket = "your-terraform-state-bucket"
    prefix = "gcp-virtual-machine"
  }
}
```

Create a `backend.tfvars` file based on `backend.tfvars.example` and initialize:

```bash
terraform init -backend-config="backend.tfvars"
```

