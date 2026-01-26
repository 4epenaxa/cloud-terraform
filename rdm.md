<!-- надо добавить файл terraform.tfvars с правильными кредами 
auth_key_id = "35c2ec6fce1f7805ded91d5bea385b"
auth_secret = "c6c08faa4e2166be942b0a33ba0746"
project_id = "1e4b06b-6141-4167-a01c-c9013957d24" 
customer_id = "7ef2d5b-7670-465f-9453-bfb5dfbb41e" -->
<!-- 
поднимем кластер -->
terraform apply -auto-approve

<!-- .env надо добавить с правильными кредами
CLOUDRU_KEY_ID=35c2ec6fce78057cded91d5bea385b
CLOUDRU_SECRET_ID=c6c08faa4166beec942b0a33ba0746 -->

<!-- получаем креды от кластера и подключаемся -->
chmod +x kubeconfig.sh && ./kubeconfig.sh

<!-- 1. whoami -->
kubectl apply -f whoami.yaml

<!-- 2. cert-manager -->
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml

kubectl -n cert-manager patch deploy cert-manager --type=json -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--enable-gateway-api"}]'


kubectl apply -f issuer.yaml

<!-- 3. gateway -->
kubectl apply --server-side -f https://github.com/envoyproxy/gateway/releases/download/v1.6.2/install.yaml

kubectl apply -f gatewayclass.yaml

YOUR_LOAD_BALANCER_IP=example.com envsubst < gateway.yaml | kubectl apply -f -

<!-- 4. httproute + gateway + certs -->

chmod +x getip.sh && ./getip.sh

chmod +x renewdomainnames.sh && ./renewdomainnames.sh

<!-- ✅ готово -->


kubectl create namespace monitoring
helm search repo loki
helm install loki grafana/loki --version 6.29.0 --namespace monitoring \
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

kubectl get pods,svc -n monitoring
helm search repo prometheus-comunity
helm install prometheus prometheus-community/kube-prometheus-stack --version 70.7.0 \
  --namespace monitoring \
  --set "grafana.additionalDataSources[0].name=Loki" \
  --set "grafana.additionalDataSources[0].type=loki" \
  --set "grafana.additionalDataSources[0].url=http://loki-gateway.monitoring.svc.cluster.local" \
  --set "grafana.additionalDataSources[0].access=proxy"

kubectl get pods,svc -n monitoring

kubectl get secret -n monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode

#prom-operator

kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80