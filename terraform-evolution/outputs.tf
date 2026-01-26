# # ========= flavors
# data "cloudru_k8s_zone_flavors" "flavors" {
# }

# output "flavors" {
#     value = data. cloudru_k8s_zone_flavors.flavors
# }


# ========= k8s version
# data "cloudru_k8s_versions" "versions" {
# }

# output "k8s_versions" {
#     value = data. cloudru_k8s_versions.versions
# }

# ========= kubeconfig

data "cloudru_k8s_kubeconfig" "kubeconfig" {
    cluster_id = cloudru_k8s_cluster.farm-k8s-cluster.id
    network_type = "NETWORK_TYPE_PUBLIC"
}
output "kubeconfig" {
    value     = data.cloudru_k8s_kubeconfig.kubeconfig
    sensitive = true
}
