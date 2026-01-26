#!/usr/bin/env bash

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