#!/bin/bash
set -e
START_TIME=$(date +%s)
echo "🚀 Terraform apply"
terraform -chdir=terraform-evolution init
terraform -chdir=terraform-evolution apply -auto-approve

echo "🔐 Getting kubeconfig"
source ./scripts/kubeconfig.sh

echo "📦 Deploy whoami"
kubectl apply -f whoami.yaml

echo "📦 Deploy Gateway API CRDS"
# TODO: добавить файл локально в репу
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.1/standard-install.yaml

echo "🔒 Install cert-manager"
# TODO: добавить файл локально в репу
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
# TODO: добавить конфиг в скачанный выше файл
kubectl -n cert-manager patch deploy cert-manager \
  --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--enable-gateway-api"}]'

# ждем готовности подов
echo "⏳ Timeout starts"
kubectl wait --for=condition=Ready pods \
  --all \
  -n cert-manager \
  --timeout=200s

echo "⏳ Timeout ends"
kubectl apply -f ./cert-manager/issuer.yaml

echo "🌐 Install Envoy Gateway"
kubectl apply --server-side -f https://github.com/envoyproxy/gateway/releases/download/v1.6.2/install.yaml
kubectl apply -f ./gateway/gatewayclass.yaml

echo "⏳ Create Gateway with temporary domain"
YOUR_LOAD_BALANCER_IP=example.com envsubst < ./gateway/gateway.yaml | kubectl apply -f -

echo "🔍 Waiting for LoadBalancer IP"
chmod +x ./scripts/getip.sh
./scripts/getip.sh

echo "📊 Installing repos"
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add portainer https://portainer.github.io/k8s/
helm repo update
echo "📊 repos updated"

source ./scripts/deploy-m.sh
source ./scripts/deploy-ui.sh
source ./scripts/deploy-db.sh

echo "🔁 Renew domain names"
source ./scripts/renewdomainnames.sh

END_TIME=$(date +%s)
ELAPSED_TIME=$((END_TIME - START_TIME))


echo "⏳ Кластер развернут и готов к работе"
MINUTES=$((ELAPSED_TIME / 60))
SECONDS_REMAINDER=$(($ELAPSED_TIME % 60))

echo "Время выполнения скрипта: ${MINUTES}:${SECONDS_REMAINDER} мин"
# ./backupS3/velero.sh


# Выводим код завершения последней команды и добавляем логику на случай ошибки
last_command_status=$?
if [ $last_command_status != 0 ]; then
  echo "Ошибка при выполнении предыдущей команды. Код ошибки: $last_command_status"
  exit 1
fi