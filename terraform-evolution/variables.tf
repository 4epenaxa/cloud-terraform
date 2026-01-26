# =======================================
# ===== SENSITIVE (terraform.tfvars) ====
# =======================================
variable "auth_key_id" {
    description = "Auth key"
    sensitive   = true
}
variable "auth_secret" {
    description = "Secret key"
    sensitive   = true
}
variable "customer_id" {
    description = "Customer id"
    sensitive   = true
}
variable "project_id" {
    description = "Project id"
    sensitive   = true
}
# =======================================
# ===== FLAVOR LIST =====================
# =======================================
variable "flavor-2-4-10" {
    type        = string
    default     = "82d31572-23e0-4937-a6af-45ddae64ba87"
    description = "2CPU/4RAM/10%"
}
variable "flavor-2-4-30" {
    type        = string
    default     = "49c10d7f-081d-4a2c-9a68-123ef11c6e32"
    description = "2CPU/4RAM/30%"
}
variable "flavor-2-4-100" {
    type        = string
    default     = "1f38e57c-0004-4f44-badf-1a0f3c09a128"
    description = "2CPU/4RAM/100%"
}
variable "flavor_VM_low_1_2" {
    type        = string
    default     = "c0a5a390-72ad-49e2-9b6f-a540d9ed0147"
    description = "1CPU/2RAM/30%"
}
# =======================================
# ===== ZONES LIST ======================
# ======================================= 
variable "az1" {
    type        = string
    default     = "7c99a597-8516-494f-a2c7-d7377048681e"
    description = "ru.AZ-1"
}
variable "az2" {
    type        = string
    default     = "479a4ab3-3ff3-4972-95c5-7610bac5c0bb"
    description = "ru.AZ-2"
}
variable "az3" {
    type        = string
    default     = "2c63c482-2532-4bba-8c9b-70ea330507bf"
    description = "ru.AZ-3"
}
# =======================================
# ===== MAIN VARIABLES ==================
# ======================================= 
variable "cluster_name" {
    type        = string
    default     = "farm-k8s-cluster"
    description = "Name of the Kubernetes cluster."
}

variable "nodepool_name" {
    type        = string
    default     = "farm-k8s-nodepool"
    description = "Name of the Kubernetes cluster."
}

variable "cluster_description" {
    type        = string
    default     = "my Kubernetes cluster at Cloud.ru"
    description = "Description of the Kubernetes cluster."
}

variable "k8s_version" {
    type        = string
    default     = "v1.33.2"
    description = "k8s version"
}
variable "ssh_user_key_id" {
    type        = string
    default     = "1130c22c-a92b-4e60-83b9-d47c826735b5"
    description = "SSH key id for user access"
}

variable "ssh_pub" {
    type        = string
    default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOWWxl+FQMJ7e69c5sIjDaDqoquFMRWJ7DCvOlzB1kDf jhinelia@Andreys-MacBook-Pro.local"
    description = "SSH key id for user access"
}