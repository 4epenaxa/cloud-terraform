#!/bin/sh

echo "🚀 Terraform apply"
terraform apply -auto-approve

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

kubectl wait --for=condition=Ready pods \
  --all \
  -n cert-manager \
  --timeout=20s
kubectl apply -f issuer.yaml

echo "🌐 Install Envoy Gateway"
kubectl apply --server-side -f https://github.com/envoyproxy/gateway/releases/download/v1.6.2/install.yaml
kubectl apply -f gatewayclass.yaml

echo "⏳ Create Gateway with temporary domain"
YOUR_LOAD_BALANCER_IP=example.com envsubst < gateway.yaml | kubectl apply -f -

echo "🔍 Waiting for LoadBalancer IP"
chmod +x getip.sh
./getip.sh

echo "🔁 Renew domain names"
chmod +x renewdomainnames.sh
./renewdomainnames.sh