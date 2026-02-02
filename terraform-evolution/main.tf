resource "cloudru_k8s_cluster" "farm-k8s-cluster" {
    name            = var.cluster_name
    control_plane   = {
        count       = 1
        type        = "MASTER_TYPE_SMALL"
        version     = var.k8s_version
        zones = [
            var.az3
        ]
    }
    release_channel = "RELEASE_CHANNEL_REGULAR"
# VPC               10.0.0.0/16
# Service network   10.96.0.0/12
# Node subnet       10.0.4.0/24 
# Pod network       10.244.0.0/16
    network_configuration = {
        services_subnet_cidr    = "10.96.0.0/12"
        # nodes_subnet_cidr       = "10.0.5.0/24"
        nodes_subnet_id         = cloudru_evolution_subnet.farm-subnet.id
        pods_subnet_cidr        = "10.1.0.0/16"
        # публикация  kube-apiserver в интернет
        kube_api_internet       = true
    }
    logging_service = {
        enabled = true # default - true
    }
    monitoring_service = {
        enabled = false # default - true
    }
    audit_service = {
        enabled = true # default - true
    }
    depends_on = [
        cloudru_evolution_subnet.farm-subnet,
        cloudru_evolution_nat_gateway.gateway
    ]
}

resource "cloudru_k8s_nodepool" "farm-k8s-nodepool" {
    cluster_id  = cloudru_k8s_cluster.farm-k8s-cluster.id
    name        = var.nodepool_name
    zone        = var.az3
    scale_policy  = {
        fixed_scale = {
            count   = 2
        }
    }
    hardware_compute = {
        disk_size = 10
        disk_type = "DISK_TYPE_SSD_NVME"
        flavor_id = var.flavor-2-4-10
    }
    nodes_network_configuration = {
        # nodes_subnet_cidr = "10.0.5.0/24"
        nodes_subnet_id         = cloudru_evolution_subnet.farm-subnet.id
    }
    remote_access = {
        ssh_key_id = var.ssh_user_key_id
        username = "farmer"
    }
    depends_on = [
        cloudru_k8s_cluster.farm-k8s-cluster
    ]
}

resource "cloudru_evolution_subnet" "farm-subnet" {
    name            = "farm-subnet"
    subnet_address  = "10.0.7.0/24"
    default_gateway = "10.0.7.1"
    default = true
    routed_network  = true
    dns_servers     = [
        "8.8.8.8",
        "8.8.4.4"
    ]
    availability_zone {
        id = var.az3
    }
}

resource "cloudru_evolution_nat_gateway" "gateway" {
    name = "farm-gateway"
    availability_zone {
        id = var.az3
    }
    nat_type    = "Public sNAT"
    depends_on = [
        cloudru_evolution_subnet.farm-subnet
    ]
}

# resource "cloudru_evolution_public_key" "farm-access-key" {
#     name = "farm-access-key"
#     public_key = var.ssh_pub
# }