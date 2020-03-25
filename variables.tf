################################################################
# Configure the OpenStack Provider
################################################################
variable "user_name" {
    description = "The user name used to connect to OpenStack"
    default = "my_user_name"
}

variable "password" {
    description = "The password for the user"
    default = "my_password"
}

variable "tenant_name" {
    description = "The name of the project (a.k.a. tenant) used"
    default = "ibm-default"
}

variable "domain_name" {
    description = "The domain to be used"
    default = "Default"
}

variable "auth_url" {
    description = "The endpoint URL used to connect to OpenStack"
    default = "https://<HOSTNAME>:5000/v3/"
}

variable "insecure" {
  default = "true" # OS_INSECURE
}

variable "openstack_availability_zone" {
    description = "The name of Availability Zone for deploy operation"
    default = ""
}


################################################################
# Configure the Instance details
################################################################

variable "bastion" {
    # only one node is supported
    default = {
        instance_type   = "m1.xlarge"
        image_id        = "daa5d3f4-ab66-4b2d-9f3d-77bd61774419"
    }
}
variable "bootstrap" {
    default = {
        # only one node is supported
        count = 1
        instance_type = "m1.xlarge"
        # rhcos image id
        image_id      = "468863e6-4b33-4e8b-b2c5-c9ef9e6eedf4"
    }
}

variable "master" {
    default = {
        count = 3
        instance_type = "m1.xlarge"
        # rhcos image id
        image_id      = "468863e6-4b33-4e8b-b2c5-c9ef9e6eedf4"
    }
}

variable "worker" {
    default = {
        count = 2
        instance_type = "m1.xlarge"
        # rhcos image id
        image_id      = "468863e6-4b33-4e8b-b2c5-c9ef9e6eedf4"
    }
}

variable "network_name" {
    description = "The name of the network to be used for deploy operations"
    default = "my_network_name"
}

variable "network_type" {
    #Eg: SEA or SRIOV
    default = "SEA"
    description = "Specify the name of the network adapter type to use for creating hosts"
}

variable "rhel_username" {
    default = "root"
}

variable "keypair_name" {
  # Set this variable to the name of an already generated
  # keypair to use it instead of creating a new one.
  default = ""
}

variable "public_key_file" {
    description = "Path to public key file"
    # if empty, will default to ${path.cwd}/data/id_rsa.pub
    default     = ""
}

variable "private_key_file" {
    description = "Path to private key file"
    # if empty, will default to ${path.cwd}/data/id_rsa
    default     = ""
}

variable "private_key" {
    description = "content of private ssh key"
    # if empty string will read contents of file at var.private_key_file
    default = ""
}

variable "public_key" {
    description = "Public key"
    # if empty string will read contents of file at var.public_key_file
    default     = ""
}

variable "rhel_subscription_username" {}

variable "rhel_subscription_password" {}

################################################################
### Instrumentation
################################################################
variable "ssh_agent" {
  description = "Enable or disable SSH Agent. Can correct some connectivity issues. Default: false"
  default     = false
}

variable "verbose" {
  # if anything is specified, it will be verbose.
  default = ""
}

locals {
    private_key_file    = "${var.private_key_file == "" ? "${path.cwd}/data/id_rsa" : "${var.private_key_file}" }"
    public_key_file     = "${var.public_key_file == "" ? "${path.cwd}/data/id_rsa.pub" : "${var.public_key_file}" }"
    private_key         = "${var.private_key == "" ? file(coalesce(local.private_key_file, "/dev/null")) : "${var.private_key}" }"
    public_key          = "${var.public_key == "" ? file(coalesce(local.public_key_file, "/dev/null")) : "${var.public_key}" }"
    create_keypair      = "${var.keypair_name == "" ? "1": "0"}"
}


################################################################
### OpenShift variables
################################################################
variable "openshift_install_tarball" {
    default = "https://mirror.openshift.com/pub/openshift-v4/ppc64le/clients/ocp-dev-preview/4.3.0-0.nightly-ppc64le-2020-02-13-160829/openshift-install-linux-4.3.0-0.nightly-ppc64le-2020-02-13-160829.tar.gz"
}
variable "release_image_override" {
    default = ""
    #default = "sys-powercloud-docker-local.artifactory.swg-devops.com/ocp-ppc64le/release-ppc64le:4.3.0-0.nightly-ppc64le-2020-02-02-235746"
}

variable "pull_secret_file" {
    default   = "data/pull-secret.txt"
}
# Must consist of lower case alphanumeric characters, '-' or '.', and must start and end with an alphanumeric character
variable "cluster_domain" {
    default   = "rhocp.com"
}
# Must consist of lower case alphanumeric characters, '-' or '.', and must start and end with an alphanumeric character
# Should not be more than 14 characters
variable "cluster_id_prefix" {
    default   = "test-ocp"
}

variable "dns_enabled" {
    default   = "true"
}

variable "storage_type" {
    #Supported values: nfs (other value won't setup a storageclass)
    default = "nfs"
}

variable "storageclass_name" {
    default = "managed-nfs-storage"
}

variable "volume_size" {
    # If storage_type = nfs, a new volume of this size will be attached to the bastion node.
    # Value in GB
    default = "300"
}

variable "volume_storage_template" {
    # Storage template name or ID for creating the volume.
    default = ""
}

variable "e2e_tests_enabled" {
    default = "false"
}

variable "e2e_tests_git" {
    # Github repo for the e2e tests
    default = "https://github.com/openshift/origin"
}

variable "e2e_tests_git_branch" {
    # The e2e Github repository branch
    default = "release-4.3"
}

variable "e2e_tests_exclude_list_url" {
    # e2e excluded testcases
    default = "https://gist.githubusercontent.com/mkumatag/ee4fdfa468f43f3cabffac945ccb843c/raw/a1ab152762f84ffbfd2d43e1f0aac58d002a45f3/ocp43_power_blacklist.txt"
}

################################################################
### IBM Cloud Paks (CS/CP4MCM) variables
################################################################
variable "skip_cp_install" {
    type    = bool
    default = true
}

variable "docker_install_rpm_url" {
    //HTTP location to install docker. Give list of urls including dependencies.
    default = []
}

### Offline Variables
variable "cp_offline_tarball_url" {
    default = ""
}

### Online Variables
variable "cp_stage" {
    default = "edge"
}
variable "cp_repo_server" {
    #Optional. When this value is empty, will default to "hyc-cloud-private-<cp_stage>-docker-local.artifactory.swg-devops.com"
    default = ""
}
variable "cp_repo_user" {
    default = "<artifactory_username>"
}

### Common Variables
variable "cp_repo_token" {
    default = "<artifactory_token>"
}
variable "cp_repo_namespace" {
    #Eg: ibmcom-ppc64le, ibmcom, etc.
    default = "ibmcom-ppc64le"
}
variable "inception_image_name" {
    #Eg: icp-inception, mcm-inception, inception-ppc64le, etc.
    default = "icp-inception"
}
variable "inception_image_tag" {
    default = "3.2.4"
}

variable "cp_admin_username" {
    default = "admin"
}
variable "cp_admin_password" {
    default = "yellow-yourself-yielding-youthful"
}

variable "cp_additional_configs" {
    # Any extra config will be appended to config.yaml, please provide multi-line string if more than one config with proper indentation as per YAML specs.
    default = <<EOF
management_services:
  # Common services
  iam-policy-controller: enabled
  metering: enabled
  licensing: disabled
  monitoring: enabled
  nginx-ingress: enabled
  common-web-ui: enabled
  catalog-ui: enabled
  mcm-kui: enabled
  logging: disabled
  audit-logging: disabled
  system-healthcheck-service: disabled
  multitenancy-enforcement: disabled
EOF
}

