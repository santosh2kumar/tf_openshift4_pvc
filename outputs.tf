output "bastion_ip" {
    value = module.bastion.bastion_ip
}

output "bastion_ssh_command" {
    value = "ssh ${var.rhel_username}@${module.bastion.bastion_ip}"
}

output "bootstrap_ip" {
    value = module.nodes.bootstrap_ip
}

output "master_ips" {
    value = module.nodes.master_ips
}

output "worker_ips" {
    value = module.nodes.worker_ips
}

output "etc_hosts_entries" {
    value = <<-EOF

${module.bastion.bastion_ip} api.${random_id.label.hex}.${var.cluster_domain}
${module.bastion.bastion_ip} console-openshift-console.apps.${random_id.label.hex}.${var.cluster_domain}
${module.bastion.bastion_ip} integrated-oauth-server-openshift-authentication.apps.${random_id.label.hex}.${var.cluster_domain}
${module.bastion.bastion_ip} oauth-openshift.apps.${random_id.label.hex}.${var.cluster_domain}
${module.bastion.bastion_ip} prometheus-k8s-openshift-monitoring.apps.${random_id.label.hex}.${var.cluster_domain}
${module.bastion.bastion_ip} grafana-openshift-monitoring.apps.${random_id.label.hex}.${var.cluster_domain}
${module.bastion.bastion_ip} example.apps.${random_id.label.hex}.${var.cluster_domain}
${var.skip_cp_install ? "" : "${module.bastion.bastion_ip} icp-console.apps.${random_id.label.hex}.${var.cluster_domain}"}
EOF
}

output "oc_server_url" {
    value = "https://api.${random_id.label.hex}.${var.cluster_domain}:6443/"
}

output "web_console_url" {
    value = "https://console-openshift-console.apps.${random_id.label.hex}.${var.cluster_domain}"
}

output "storageclass_name" {
    value = module.storage.storageclass_name
}

output "cp_web_console_url" {
    value = var.skip_cp_install ? "" : module.icp_install.cp_web_console_url
}
output "cp_admin_username" {
    value = var.skip_cp_install ? "" : module.icp_install.cp_admin_username
}
output "cp_admin_password" {
    value = var.skip_cp_install ? "" : module.icp_install.cp_admin_password
}
