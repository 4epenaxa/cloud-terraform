#!/usr/bin/env bash

echo "📊 Installing loki"
helm upgrade --install loki grafana/loki \
    --version 6.29.0 \
    --namespace monitoring \
    --create-namespace \
    --set deploymentMode=SingleBinary \
    --set loki.auth_enabled=false \
    --set singleBinary.replicas=1 \
    --set write.replicas=0 \
    --set read.replicas=0 \
    --set backend.replicas=0 \
    --set loki.commonConfig.replication_factor=1 \
    --set loki.storage.type=filesystem \
    --set loki.storage.filesystem.directory=/var/loki/chunks \
    --set loki.useTestSchema=true \
    --set chunksCache.enabled=false \
    --set resultsCache.enabled=false \
    --set test.enabled=false
echo "✅ LOKI DONE"
echo "📊 Installing grafana"

helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
    --namespace monitoring \
    --create-namespace \
    --version 70.7.0 \
    --set grafana.enabled=true \
    --set grafana.adminUser=admin \
    --set grafana.adminPassword=admin \
    --set grafana.additionalDataSources[0].name=Loki \
    --set grafana.additionalDataSources[0].type=loki \
    --set grafana.additionalDataSources[0].url=http://loki-gateway.monitoring.svc.cluster.local \
    --set grafana.additionalDataSources[0].access=proxy

# kubectl patch configmap prometheus-grafana -n monitoring --type merge -p "{
#   \"data\": {
#     \"grafana.ini\": \"[analytics]\ncheck_for_updates = true\n[grafana_net]\nurl = https://grafana.net\n[log]\nmode = console\n[paths]\ndata = /var/lib/grafana/\nlogs = /var/log/grafana\nplugins = /var/lib/grafana/plugins\nprovisioning = /etc/grafana/provisioning\n[server]\nroot_url = https://${IP}.nip.io/monitoring/\nserve_from_sub_path = true\ndomain = ''\"
#   }
# }"
# kubectl rollout restart deployment prometheus-grafana -n monitoring

echo "✅ GRAFANA + LOKI"