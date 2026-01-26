#!/bin/sh

INTERVAL=5
ELAPSED=0
DOMAIN=""

while :; do
  IP=$(kubectl get svc -A \
    -o jsonpath='{range .items[?(@.spec.type=="LoadBalancer")]}{.status.loadBalancer.ingress[0].ip}{"\n"}{end}' \
    | grep -E '^[0-9]+\.' | head -n1)

  if [ -n "$IP" ]; then
    DOMAIN="${IP}.nip.io"
    printf "\r\033[2K✔ LoadBalancer IP: %s\n" "$IP"
    printf "✔ Domain: %s\n" "$DOMAIN"
    exit 0
  fi

  ELAPSED=$((ELAPSED + INTERVAL))

  # blinking "pending"
  printf "\r\033[5mPending %ss\033[0m" "$ELAPSED"
  sleep $INTERVAL
done