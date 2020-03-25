#This will read Openshift mirror clients listing on latest-4.3
latest_build=$(curl -sL https://mirror.openshift.com/pub/openshift-v4/ppc64le/clients/ocp-dev-preview/latest-4.3/ | grep openshift-install-linux-4.3  | sed 's/.*href=\"//' | awk -F'\"' '{print $1}');
latest_build_url=https://mirror.openshift.com/pub/openshift-v4/ppc64le/clients/ocp-dev-preview/latest-4.3/$latest_build
echo "OCP Build URL: $latest_build_url"

# Generate data files
ssh-keygen -t rsa -N '' -f data/id_rsa
cat data/id_rsa
cat data/id_rsa.pub

echo "$pull_secret" > data/pull-secret.txt


# Generate TF variables
# cluster_id_prefix should not exeed 8 charactors 
cat << EOF > ./var.tfvars
# Configure the OpenStack Provider
auth_url    = "https://9.114.192.193:5000/v3/"
user_name = "$user_name"
password = "$password"
tenant_name = "ibm-default"
domain_name = "Default"
openstack_availability_zone = "p8_pvm"

# Configure the Instance details
network_name        = "icp_network2"
rhel_username       = "root"
public_key_file     = "data/id_rsa.pub"
private_key_file    = "data/id_rsa"
rhel_subscription_username = "$rhel_subscription_username"
rhel_subscription_password = "$rhel_subscription_password"
bastion = {instance_type = "medium", image_id = "ce470187-b906-4ea5-ae9e-16aad3c246da"}
bootstrap = {instance_type = "medium", image_id = "846aa81b-cde5-473f-96d5-193a6614515f", "count" = 1}
master = {instance_type = "large", image_id = "846aa81b-cde5-473f-96d5-193a6614515f", "count" = 1}
worker = {instance_type = "large", image_id = "846aa81b-cde5-473f-96d5-193a6614515f", "count" = 2}

# OpenShift variables
openshift_install_tarball = "$latest_build_url"
release_image_override = ""
pull_secret_file = "data/pull-secret.txt"
cluster_domain = "power.com"
cluster_id_prefix = "travis" 

EOF

