#!/usr/bin/env bash
echo "🚀 Terraform destroy"
terraform -chdir=terraform-evolution destroy -auto-approve
echo "🎉 Destroying completed successfully"