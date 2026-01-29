#!/bin/sh
START_TIME=$(date +%s)
echo "🚀 Terraform apply"
terraform -chdir=terraform-evolution init
terraform -chdir=terraform-evolution apply -auto-approve

echo "🔐 Getting kubeconfig"
chmod +x kubeconfig.sh
./kubeconfig.sh

echo "📦 Deploy whoami"
kubectl apply -f whoami.yaml

echo "🔒 Install cert-manager"
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml

kubectl -n cert-manager patch deploy cert-manager \
  --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--enable-gateway-api"}]'

echo "⏳ Timeout starts"
kubectl wait --for=condition=Ready pods \
  --all \
  -n cert-manager \
  --timeout=120s

echo "⏳ Timeout ends"
kubectl apply -f issuer.yaml

echo "🌐 Install Envoy Gateway"
kubectl apply --server-side -f https://github.com/envoyproxy/gateway/releases/download/v1.6.2/install.yaml
kubectl apply -f gatewayclass.yaml

echo "⏳ Create Gateway with temporary domain"
YOUR_LOAD_BALANCER_IP=example.com envsubst < gateway.yaml | kubectl apply -f -

echo "🔍 Waiting for LoadBalancer IP"
chmod +x getip.sh
./getip.sh

# echo "📊 Installing monitoring via Helm"
chmod +x deploy-m.sh deploy-ui.sh
./deploy-m.sh
./deploy-ui.sh

echo "🔁 Renew domain names"
chmod +x renewdomainnames.sh
./renewdomainnames.sh

END_TIME=$(date +%s)
ELAPSED_TIME=$((END_TIME - START_TIME))


echo "⏳ Кластер развернут и готов к работе"
MINUTES=$((ELAPSED_TIME / 60))
SECONDS_REMAINDER=$(($ELAPSED_TIME % 60))

echo "Время выполнения скрипта: ${MINUTES} минут и ${SECONDS_REMAINDER} секунд"