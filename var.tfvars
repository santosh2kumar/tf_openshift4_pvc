# Configure the OpenStack Provider
auth_url                    = "https://9.114.192.193:5000/v3/"
user_name                   = ""
password                    = ""
tenant_name                 = "ibm-default"
domain_name                 = "Default"
openstack_availability_zone = "p8_pvm"

# Configure the Instance details
network_name                = "icp_network2"
#network_type               = "SRIOV"
rhel_username               = "root"
#keypair_name                = "mykeypair"
public_key_file             = "data/id_rsa.pub"
private_key_file            = "data/id_rsa"
private_key                 = ""
public_key                  = ""
rhel_subscription_username  = ""
rhel_subscription_password  = ""
bastion                     = {instance_type    = "ocp4-bastion", image_id     = "ce470187-b906-4ea5-ae9e-16aad3c246da"}
bootstrap                   = {instance_type    = "ocp4-bootstrap", image_id     = "846aa81b-cde5-473f-96d5-193a6614515f",  "count"   = 1}
master                      = {instance_type    = "ocp4x-master",  image_id     = "846aa81b-cde5-473f-96d5-193a6614515f",  "count"   = 1}
worker                      = {instance_type    = "ocp4-worker",  image_id     = "846aa81b-cde5-473f-96d5-193a6614515f",  "count"   = 1}

# OpenShift variables
openshift_install_tarball = "https://mirror.openshift.com/pub/openshift-v4/ppc64le/clients/ocp-dev-preview/4.3.0-0.nightly-ppc64le-2020-02-20-212303/openshift-install-linux-4.3.0-0.nightly-ppc64le-2020-02-20-212303.tar.gz"
release_image_override = ""
pull_secret_file = "data/pull-secret.txt"
cluster_domain = "example.com"

dns_enabled     = "true"

storage_type    = "nfs"
volume_size = "300" # Value in GB
volume_storage_template = ""
cluster_id_prefix = "test"

e2e_tests_enabled = "false"


# IBM Cloud Pak (CS/CP4MCM) Variables
skip_cp_install         = true
docker_install_rpm_url  = ["https://oplab9.parqtec.unicamp.br/pub/ppc64el/docker/version-19.03.7/centos/docker-ce-19.03.7-3.el7.ppc64le.rpm", "https://oplab9.parqtec.unicamp.br/pub/ppc64el/docker/version-19.03.7/centos/docker-ce-cli-19.03.7-3.el7.ppc64le.rpm", "https://download-ib01.fedoraproject.org/pub/epel/7/ppc64le/Packages/c/containerd-1.2.4-1.el7.ppc64le.rpm"]

#For Offline installation uncomment and configure below section
#cp_offline_tarball_url  = "https://na.artifactory.swg-devops.com/artifactory/hyc-cloud-private-stable-generic-local/offline/CS-boeblingen-2002/2020-0302/common-services-boeblingen-2002-ppc64le.tar.gz"
#cp_repo_namespace       = "ibmcom"
#inception_image_name    = "icp-inception-ppc64le"
#inception_image_tag     = "3.2.4"
#cp_repo_token           = "<your artifactory token>"

#For Online installation uncomment and configure below section
#cp_repo_namespace       = "ibmcom-ppc64le"
#inception_image_name    = "icp-inception"
#inception_image_tag     = "3.2.4"
#cp_repo_user            = "<your artifactory user>"
#cp_repo_token           = "<your artifactory token>"
