#!/bin/sh

IP=$(kubectl get svc -A \
    -o jsonpath='{range .items[?(@.spec.type=="LoadBalancer")]}{.status.loadBalancer.ingress[0].ip}{"\n"}{end}' \
    | grep -E '^[0-9]+\.' | head -n1)

YOUR_LOAD_BALANCER_IP="${IP}.nip.io"

export YOUR_LOAD_BALANCER_IP

echo "Apply for gateway"
envsubst < gateway.yaml | kubectl apply -f -
echo "Apply for cert"
envsubst < cert.yaml | kubectl apply -f -
echo "Apply for httproute"
envsubst < httproute.yaml | kubectl apply -f -
echo "✅ DONE"
printf "🌍 Domain: https://%s\n" "$YOUR_LOAD_BALANCER_IP"