resource "null_resource" "e2e_tests" {
    count       = var.e2e_tests_enabled == "true" && var.install_status == "COMPLETED" ? 1 : 0
    connection {
        type        = "ssh"
        user        = var.rhel_username
        host        = var.bastion_ip
        private_key = var.private_key
        agent       = var.ssh_agent
        timeout     = "15m"
    }
    provisioner "file" {
        content      = templatefile("${path.module}/templates/e2e_tests.tpl",local.e2e_cfg)
        destination = "/tmp/e2e_tests.sh"
    }
    provisioner "remote-exec" {
        on_failure  = continue
        inline = [
            "sudo chmod +x /tmp/e2e_tests.sh",
            "/tmp/e2e_tests.sh"
        ]
    }
}
locals {
    e2e_cfg = {
        e2e_tests_git           = var.e2e_tests_git
        e2e_tests_git_branch    = var.e2e_tests_git_branch
        e2e_tests_exclude_list_url  = var.e2e_tests_exclude_list_url
    }
}

