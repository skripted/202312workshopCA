variable "config_file_profile" { type = string }
variable "home_region" { type = string }
variable "region" { type = string }
variable "tenancy_id" { type = string }
variable "compartment_id" { type = string }
variable "ssh_public_key_path" { type = string }
variable "ssh_private_key_path" { type = string }

module "oke" {
  source  = "oracle-terraform-modules/oke/oci"
  version = "5.1.0"

  # Provider
  providers           = { oci.home = oci.home }
  config_file_profile = var.config_file_profile
  home_region         = var.home_region
  region              = var.region
  tenancy_id          = var.tenancy_id
  compartment_id      = var.compartment_id
  ssh_public_key_path = var.ssh_public_key_path
  ssh_private_key_path = var.ssh_private_key_path
  
  kubernetes_version = "v1.27.2"
  cluster_type = "enhanced"
  cluster_name         = "myoke-cluster"
  bastion_allowed_cidrs = ["0.0.0.0/0"]
  allow_worker_ssh_access     = true
  control_plane_allowed_cidrs = ["0.0.0.0/0"]
  control_plane_is_public = true

  # Resource creation
  assign_dns           = true
  create_vcn           = true
  create_bastion       = true
  create_cluster       = true
  create_operator      = true
  create_iam_resources = true
  use_defined_tags     = false

  metrics_server_install       = true
  metrics_server_namespace     = "metrics"

  prometheus_install           = true
  prometheus_reapply           = false
  prometheus_namespace         = "metrics"
  prometheus_helm_version      = "45.2.0"
  prometheus_helm_values       = {}
  prometheus_helm_values_files = []





  worker_pools = {
   system = {
     description = "CPU pool", enabled = true,
     mode = "node-pool", boot_volume_size = 150, shape = "VM.Standard.E4.Flex", ocpus = 2, memory = 32, size = 3
    }
    armpool = {
     description = "ARM CPU Pool", enabled = true,
     mode = "node-pool", boot_volume_size = 150, shape = "VM.Standard.A1.Flex", ocpus = 12, memory = 64, size = 3
    }
  }
}
terraform {
  required_providers {
    oci = {
      configuration_aliases = [oci.home]
      source                = "oracle/oci"
      version               = ">= 5.22.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "oci" {
  config_file_profile = var.config_file_profile
  region              = var.region
  tenancy_ocid        = var.tenancy_id
}

provider "oci" {
  alias               = "home"
  config_file_profile = var.config_file_profile
  region              = var.home_region
  tenancy_ocid        = var.tenancy_id
}