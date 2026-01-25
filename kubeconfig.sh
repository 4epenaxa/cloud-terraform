#!/bin/bash

# Interactive script to update CLOUDRU credentials in kubeconfig

KUBECONFIG_FILE="${1:-temp.yaml}"

terraform output -json kubeconfig | jq -r '.raw' | base64 --decode > $KUBECONFIG_FILE

echo "Updating Cloud.ru credentials in kubeconfig"
echo "Kubeconfig file: $KUBECONFIG_FILE"
echo ""

# Load credentials from .env file
ENV_FILE="${2:-.env}"

if [ ! -f "$ENV_FILE" ]; then
    echo "Error: .env file not found at $ENV_FILE"
    echo "Usage: $0 [kubeconfig_path] [env_file_path]"
    echo "Example: $0 ~/.kube/config .env"
    exit 1
fi

echo "Loading credentials from $ENV_FILE"

# Source the .env file
set -a
source "$ENV_FILE"
set +a

if [ -z "$CLOUDRU_KEY_ID" ] || [ -z "$CLOUDRU_SECRET_ID" ]; then
    echo "Error: CLOUDRU_KEY_ID and CLOUDRU_SECRET_ID must be set in $ENV_FILE"
    exit 1
fi

KEY_ID="$CLOUDRU_KEY_ID"
SECRET_ID="$CLOUDRU_SECRET_ID"

# Create backup
# cp "$KUBECONFIG_FILE" "$KUBECONFIG_FILE.backup.$(date +%Y%m%d_%H%M%S)"
# echo "Backup created"

# Update the values using awk
awk -v key_id="$KEY_ID" -v secret_id="$SECRET_ID" '
{
    if ($0 ~ /name: CLOUDRU_KEY_ID/) {
        print $0
        getline
        if ($0 ~ /value:/) {
            sub(/value:.*/, "value: \"" key_id "\"")
        }
    }
    else if ($0 ~ /name: CLOUDRU_SECRET_ID/) {
        print $0
        getline
        if ($0 ~ /value:/) {
            sub(/value:.*/, "value: \"" secret_id "\"")
        }
    }
    print $0
}
' "$KUBECONFIG_FILE" > "$KUBECONFIG_FILE.tmp"

mv "$KUBECONFIG_FILE.tmp" ~/.kube/config

echo "Credentials updated successfully!"
echo "You can now use kubectl with your cluster."

kubectl cluster-info

echo "Cluster connected and ready for work""