terraform {
  required_providers {
    cloudru = {
      source  = "cloud.ru/cloudru/cloud"
      version = "1.6.0"
    }
  }
}

provider "cloudru" {
    project_id  = var.project_id

    customer_id = var.customer_id
    auth_key_id = var.auth_key_id
    auth_secret = var.auth_secret

    iam_endpoint        = "iam.api.cloud.ru:443"
    k8s_endpoint        = "mk8s.api.cloud.ru:443"
    evolution_endpoint  = "https://compute.api.cloud.ru"
    # cloudplatform_endpoint = "organization.api.cloud.ru:443"
    # dbaas_endpoint = "dbaas.api.cloud.ru:443"
    # vcentermanager_endpoint = "https://console.cloud.ru/"
}