variable "skip_cp_install" {}
variable "install_status" {}
variable "cluster_id" {}
variable "cluster_domain" {}

variable "storageclass_name" {}

variable "cp_admin_username" {}
variable "cp_admin_password" {}

variable "cp_stage" {}
variable "cp_repo_server" {}
variable "cp_repo_user" {}
variable "cp_repo_token" {}
variable "cp_repo_namespace" {}
variable "cp_additional_configs" {}

variable "cp_offline_tarball_url" {}

variable "inception_image" {}

variable "bastion_ip" {}
variable "master_count" {}

variable "worker_ips" {}
variable "rhel_username" {}
variable "private_key" {}
variable "ssh_agent" {}

variable "docker_install_rpm_url" {}
