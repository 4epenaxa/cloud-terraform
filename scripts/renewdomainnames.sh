IP=$(kubectl get svc -A \
    -o jsonpath='{range .items[?(@.spec.type=="LoadBalancer")]}{.status.loadBalancer.ingress[0].ip}{"\n"}{end}' \
    | grep -E '^[0-9]+\.' | head -n1)
YOUR_LOAD_BALANCER_IP="${IP}.nip.io"
export YOUR_LOAD_BALANCER_IP

echo "⚠️ Apply for gateway"
envsubst < ./gateway/gateway.yaml | kubectl apply -f -

echo "⚠️ Apply for main-httproute"
envsubst < ./gateway/httprouts/httproute.yaml | kubectl apply -f -
echo "⚠️ Apply for monitoring-httproute"
envsubst < ./gateway/httprouts/httproute-monitoring.yaml | kubectl apply -f -
echo "⚠️ Apply for portainer-httproute"
envsubst < ./gateway/httprouts/httproute-portainer.yaml | kubectl apply -f -
kubectl rollout restart deployment portainer -n portainer
# rollout так как портайнер просит перезапуса изза долгого времени ожидания

echo "⚠️ Apply for cert"
envsubst < ./cert-manager/cert.yaml | kubectl apply -f -

echo "✅ DONE"
printf "🌍 Domain: https://%s\n" "$YOUR_LOAD_BALANCER_IP"
printf "🌍 Monitoring: https://monitoring.%s/\n" "$YOUR_LOAD_BALANCER_IP"
printf "🌍 Portainer: https://portainer.%s/\n" "$YOUR_LOAD_BALANCER_IP"