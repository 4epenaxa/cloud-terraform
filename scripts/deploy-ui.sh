echo "📊 Portainer install"
kubectl create namespace portainer
helm upgrade --install portainer portainer/portainer \
  --namespace portainer \
  --create-namespace \
  --set service.type=ClusterIP \
  --set tls.force=false \
  --set image.tag=lts \
  --set ingress.enabled=false

echo "🎉 Portainer installed successfully"
