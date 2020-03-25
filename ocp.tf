provider "openstack" {
    user_name   = var.user_name
    password    = var.password
    tenant_name = var.tenant_name
    domain_name = var.domain_name
    auth_url    = var.auth_url
    insecure    = var.insecure
}

resource "random_id" "label" {
    byte_length = "2" # Since we use the hex, the word lenght would double
    prefix = "${var.cluster_id_prefix}-"
}

module "bastion" {
    source                          = "./modules/1_bastion"

    cluster_domain                  = var.cluster_domain
    cluster_id                      = "${random_id.label.hex}"
    bastion                         = var.bastion
    network_name                    = var.network_name
    openstack_availability_zone     = var.openstack_availability_zone
    rhel_username                   = var.rhel_username
    private_key                     = local.private_key
    public_key                      = local.public_key
    create_keypair                  = local.create_keypair
    keypair_name                    = "${random_id.label.hex}-keypair"
    ssh_agent                       = var.ssh_agent
    rhel_subscription_username      = var.rhel_subscription_username
    rhel_subscription_password      = var.rhel_subscription_password
}

module "preinstall" {
    source                          = "./modules/2_preinstall"

    bastion_ip                      = module.bastion.bastion_ip
    cluster_domain                  = var.cluster_domain
    cluster_id                      = "${random_id.label.hex}"
    rhel_username                   = var.rhel_username
    private_key                     = local.private_key
    public_key                      = local.public_key
    ssh_agent                       = var.ssh_agent
    pull_secret                     = file(coalesce(var.pull_secret_file, "/dev/null"))
    openshift_install_tarball       = var.openshift_install_tarball
    master_count                    = var.master["count"]
    release_image_override          = var.release_image_override
}

module "network" {
    source                          = "./modules/3_network"

    cluster_domain                  = var.cluster_domain
    cluster_id                      = "${random_id.label.hex}"
    network_name                    = var.network_name
    master_count                    = var.master["count"]
    worker_count                    = var.worker["count"]
    bastion_ip                      = module.bastion.bastion_ip
    rhel_username                   = var.rhel_username
    private_key                     = local.private_key
    ssh_agent                       = var.ssh_agent
    network_type                    = var.network_type
}

module "nodes" {
    source                          = "./modules/4_nodes"

    bootstrap_ign_url               = module.preinstall.bootstrap_ign_url
    master_ign_url                  = module.preinstall.master_ign_url
    worker_ign_url                  = module.preinstall.worker_ign_url
    bastion_ip                      = module.bastion.bastion_ip
    cluster_domain                  = var.cluster_domain
    cluster_id                      = "${random_id.label.hex}"
    bootstrap                       = var.bootstrap
    master                          = var.master
    worker                          = var.worker
    openstack_availability_zone     = var.openstack_availability_zone
    bootstrap_port_id               = module.network.bootstrap_port_id
    master_port_ids                 = module.network.master_port_ids
    worker_port_ids                 = module.network.worker_port_ids
}

module "dns_haproxy" {
    source                          = "./modules/5_dns_haproxy"

    cluster_domain                  = var.cluster_domain
    cluster_id                      = "${random_id.label.hex}"
    bootstrap_ip                    = module.nodes.bootstrap_ip
    master_ips                      = module.nodes.master_ips
    worker_ips                      = module.nodes.worker_ips
    bastion_ip                      = module.bastion.bastion_ip
    rhel_username                   = var.rhel_username
    private_key                     = local.private_key
    ssh_agent                       = var.ssh_agent
    dns_enabled                     = var.dns_enabled
}

module "install" {
    source                          = "./modules/6_install"

    bootstrap_ip                    = module.nodes.bootstrap_ip
    bastion_ip                      = module.bastion.bastion_ip
    master_ips                      = module.nodes.master_ips
    worker_ips                      = module.nodes.worker_ips
    rhel_username                   = var.rhel_username
    private_key                     = local.private_key
    ssh_agent                       = var.ssh_agent
}

module "storage" {
    source                          = "./modules/7_storage"

    install_status                  = module.install.install_status
    cluster_id                      = "${random_id.label.hex}"
    bastion_ip                      = module.bastion.bastion_ip
    bastion_id                      = module.bastion.bastion_id
    storage_type                    = var.storage_type
    storageclass_name               = var.storageclass_name
    volume_size                     = var.volume_size
    volume_storage_template         = var.volume_storage_template
    rhel_username                   = var.rhel_username
    private_key                     = local.private_key
    ssh_agent                       = var.ssh_agent
}

module "e2e_tests" {
    source                          = "./modules/8_e2e_tests"

    install_status                  = module.install.install_status
    bastion_ip                      = module.bastion.bastion_ip
    rhel_username                   = var.rhel_username
    private_key                     = local.private_key
    ssh_agent                       = var.ssh_agent
    e2e_tests_enabled               = var.e2e_tests_enabled
    e2e_tests_git                   = var.e2e_tests_git
    e2e_tests_git_branch            = var.e2e_tests_git_branch
    e2e_tests_exclude_list_url      = var.e2e_tests_exclude_list_url
}

module "icp_install" {
    source                          = "./modules/9_cp_install"

    skip_cp_install                 = var.skip_cp_install
    install_status                  = module.install.install_status
    cluster_domain                  = var.cluster_domain
    cluster_id                      = "${random_id.label.hex}"
    storageclass_name               = module.storage.storageclass_name
    cp_admin_username               = var.cp_admin_username
    cp_admin_password               = var.cp_admin_password
    cp_stage                        = var.cp_stage
    cp_repo_server                  = var.cp_repo_server
    cp_repo_user                    = var.cp_repo_user
    cp_repo_token                   = var.cp_repo_token
    cp_repo_namespace               = var.cp_repo_namespace
    cp_additional_configs           = var.cp_additional_configs
    cp_offline_tarball_url          = var.cp_offline_tarball_url
    inception_image                 = "${var.inception_image_name}:${var.inception_image_tag}"
    bastion_ip                      = module.bastion.bastion_ip
    master_count                    = var.master["count"]
    worker_ips                      = module.nodes.worker_ips
    rhel_username                   = var.rhel_username
    private_key                     = local.private_key
    ssh_agent                       = var.ssh_agent
    docker_install_rpm_url          = var.docker_install_rpm_url
}
