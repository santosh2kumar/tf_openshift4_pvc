output "cp_web_console_url" {
    depends_on = [null_resource.cp_install]
    value = "https://icp-console.apps.${var.cluster_id}.${var.cluster_domain}:443"
}

output "cp_admin_username" {
    depends_on = [null_resource.cp_install]
    value = var.cp_admin_username
}

output "cp_admin_password" {
    depends_on = [null_resource.cp_install]
    value = var.cp_admin_password
}
