#!/usr/bin/env bash
set -euo pipefail
### ====== ПОДКЛЮЧАЕМ ENV ======
set -a
[ -f .env ] && source .env
set +a
### ====== НАСТРОЙКИ ======
KUBECONFIG_PATH="$HOME/.kube/config"
TMP_KUBECONFIG="./kube.yaml"

### ====== ПРОВЕРКИ ======
for cmd in terraform jq kubectl helm base64 cloudlogin; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "❌ Command not found: $cmd"
    exit 1
  }
done

echo "🚀 Terraform apply"
# terraform init
terraform apply -auto-approve

echo "📦 Extract kubeconfig from terraform output"
terraform output -json kubeconfig \
  | jq -r '.raw' \
  | base64 --decode > "$TMP_KUBECONFIG"

echo "🔐 Inject secrets into kubeconfig"

docker run --rm -i -v "$PWD":/workdir -e CLOUDRU_KEY_ID -e CLOUDRU_SECRET_ID mikefarah/yq \
  eval '.users[].user.exec.env[] |= (select(.name=="CLOUDRU_KEY_ID") .value = strenv(CLOUDRU_KEY_ID)) |
        .users[].user.exec.env[] |= (select(.name=="CLOUDRU_SECRET_ID") .value = strenv(CLOUDRU_SECRET_ID))' \
        /workdir/kube.yaml > /tmp/kube.yaml && mv /tmp/kube.yaml kube.yaml
unset CLOUDRU_KEY_ID
unset CLOUDRU_SECRET_ID

echo "📁 Install kubeconfig"
mkdir -p "$HOME/.kube"
mv "$TMP_KUBECONFIG" "$KUBECONFIG_PATH"

echo "🔌 Checking cluster access"
kubectl cluster-info
echo "🎉 Deployment k8s cluster completed successfully"
echo "📊 Installing monitoring via Helm"
kubectl create namespace farm-monitoring
helm upgrade --install monitoring ./monitoring


echo "⏳ Waiting for pods to be ready"
kubectl wait --for=condition=Ready pod \
  --all \
  --all-namespaces \
  --timeout=300s
echo "🎉 Monitoring installed successfully"

echo "📊 Portainer install"
kubectl create namespace portainer
kubectl apply -n portainer -f https://raw.githubusercontent.com/portainer/k8s/master/deploy/manifests/portainer/portainer-lb.yaml
echo "🎉 Portainer installed successfully"
echo "⏳ Waiting for all pods to be ready"
kubectl wait --for=condition=Ready pod \
  --all \
  --all-namespaces \
  --timeout=300s
echo "✅ Get external IP for Grafana loadBalancer"
kubectl get svc grafana -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
echo ":3000"
echo "✅ Get external IP for Portainer loadBalancer"
kubectl get svc -n portainer portainer -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
echo ":9000"