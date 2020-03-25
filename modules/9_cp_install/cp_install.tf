
locals {
    tmp_repo_server = "hyc-cloud-private-${var.cp_stage}-docker-local.artifactory.swg-devops.com"
    cp_repo_server  = var.cp_repo_server == "" ? local.tmp_repo_server : var.cp_repo_server

    tmp_image_name  = "${var.cp_repo_namespace}/${var.inception_image}"
    image_name      = var.cp_offline_tarball_url == "" ? "${local.cp_repo_server}/${local.tmp_image_name}" : local.tmp_image_name

    workers_info    = [for ix in range(length(var.worker_ips)): "${var.cluster_id}-worker-${ix}"]

    config_yaml = {
        storageclass_name   = var.storageclass_name
        admin_username      = var.cp_admin_username
        admin_password      = var.cp_admin_password
        offline_url         = var.cp_offline_tarball_url
        stage               = var.cp_stage
        repo_server         = local.cp_repo_server
        repo_namespace      = var.cp_repo_namespace
        repo_user           = var.cp_repo_user
        repo_token          = var.cp_repo_token
        additional_configs  = var.cp_additional_configs
        # If #master are >=3 use first 3 workers. Else, use 1st worker.
        master      = var.master_count >= 3 && length(local.workers_info) >= 3 ? slice(local.workers_info, 0, 3) : length(local.workers_info) == 1 ? slice(local.workers_info, 0, 1) : []
        proxy       = var.master_count >= 3 && length(local.workers_info) >= 3 ? slice(local.workers_info, 0, 3) : length(local.workers_info) == 1 ? slice(local.workers_info, 0, 1) : []
        # If #master are >=3 use first 3 workers. Else, If #workers = 2 use 2nd worker. Else, use 1st worker.
        management  = var.master_count >= 3 && length(local.workers_info) >= 3 ? slice(local.workers_info, 0, 3) : (length(local.workers_info) == 2 ? slice(local.workers_info, 1, 2) : (length(local.workers_info) == 1 ? slice(local.workers_info, 0, 1) : []))
    }
}

resource "null_resource" "docker_setup" {
    depends_on  = [var.install_status]
    count       = var.skip_cp_install ? 0 : length(var.docker_install_rpm_url) == 0 ? 0 : 1
    connection {
        type        = "ssh"
        user        = var.rhel_username
        host        = var.bastion_ip
        private_key = var.private_key
        agent       = var.ssh_agent
        timeout     = "15m"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo yum install -y ${join(" ", var.docker_install_rpm_url)}",
            "sudo systemctl enable --now docker"
        ]
    }
}

resource "null_resource" "cp_online" {
    depends_on  = [null_resource.docker_setup]
    count       = var.skip_cp_install || var.cp_offline_tarball_url != "" ? 0 : 1
    connection {
        type        = "ssh"
        user        = var.rhel_username
        host        = var.bastion_ip
        private_key = var.private_key
        agent       = var.ssh_agent
        timeout     = "15m"
    }

    provisioner "remote-exec" {
        inline = [
            "mkdir -p icp-setup && cd icp-setup",
            "sudo docker login -u ${var.cp_repo_user} -p ${var.cp_repo_token} ${local.cp_repo_server}",
            "sudo docker pull ${local.image_name}",
            "sudo docker run --rm -v $(pwd):/data:z -e LICENSE=accept --security-opt label:disable ${local.image_name} cp -r cluster /data",
        ]
    }

    provisioner "remote-exec" {
        when        = destroy
        on_failure  = continue
        inline = [
            "sudo rm -rf icp-setup",
            "sudo docker rmi ${local.image_name}"
        ]
    }
}

resource "null_resource" "cp_offline" {
    depends_on  = [null_resource.docker_setup]
    count       = var.skip_cp_install || var.cp_offline_tarball_url == "" ? 0 : 1
    connection {
        type        = "ssh"
        user        = var.rhel_username
        host        = var.bastion_ip
        private_key = var.private_key
        agent       = var.ssh_agent
        timeout     = "15m"
    }

    provisioner "remote-exec" {
        inline = [
            "mkdir -p icp-setup && cd icp-setup",
            "curl -H \"X-JFrog-Art-Api: ${var.cp_repo_token}\" -o $(basename ${var.cp_offline_tarball_url}) ${var.cp_offline_tarball_url}",
            "tar xf $(basename ${var.cp_offline_tarball_url}) -O | sudo docker load",
            "sudo docker run --rm -v $(pwd):/data:z -e LICENSE=accept --security-opt label:disable ${local.image_name} cp -r cluster /data",
        ]
    }

    provisioner "remote-exec" {
        when        = destroy
        on_failure  = continue
        inline = [
            "sudo rm -rf icp-setup",
            "sudo docker rmi ${local.image_name}"
        ]
    }
}

resource "null_resource" "cp_install" {
    depends_on  = [null_resource.cp_offline, null_resource.cp_online]
    count       = var.skip_cp_install ? 0 : 1
    connection {
        type        = "ssh"
        user        = var.rhel_username
        host        = var.bastion_ip
        private_key = var.private_key
        agent       = var.ssh_agent
        timeout     = "15m"
    }

    provisioner "file" {
        content     = templatefile("${path.module}/templates/config.yaml", local.config_yaml)
        destination = "/tmp/config.yaml"
    }

    provisioner "remote-exec" {
        inline = [
            "cd icp-setup",
            "sudo cp ~/openstack-upi/auth/kubeconfig  cluster/kubeconfig",
            "sudo cp cluster/config.yaml cluster/config.yaml.orig",
            "sudo tee -a cluster/config.yaml </tmp/config.yaml >/dev/null",
            "sudo docker run -t --net=host -e LICENSE=accept -v $(pwd)/cluster:/installer/cluster:z -v /var/run:/var/run:z --security-opt label:disable ${local.image_name} addon",
        ]
    }

    provisioner "remote-exec" {
        when        = destroy
        on_failure  = continue
        inline = [
            "cd icp-setup",
            "sudo docker run -t --net=host -e LICENSE=accept -v $(pwd)/cluster:/installer/cluster:z -v /var/run:/var/run:z --security-opt label:disable ${local.image_name} uninstall-addon",
        ]
    }
}
