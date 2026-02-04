# Envoy Gateway + cert-manager + nip.io (Auto HTTPS)

Этот репозиторий поднимает Kubernetes-кластер, настраивает:
- Envoy Gateway (Gateway API)
- cert-manager + Let’s Encrypt
- HTTPRoute
- автоматический домен вида `<LB_IP>.nip.io`
- HTTPS без ручного DNS
- Monitoring - Grafana + Loki + Prometheus
- UI - Portainer
- DB - Postgres

---

## 📋 Требования

- terraform
Скорее всего понадобится VPN


https://developer.hashicorp.com/terraform/install

- kubectl


https://kubernetes.io/docs/tasks/tools/

Для работы с Cloud Evolution понадобится:
- cloud provider


https://cloud.ru/docs/terraform-evolution/ug/topics/quickstart
- cloudlogin


https://cloud.ru/docs/kubernetes-evolution/ug/topics/guides__cluster__download-cloudlogin

---

## 🚀 Быстрый старт

### Создаем файл ```.env``` в папке ```terraform-evolution/```
```
CLOUDRU_KEY_ID=
CLOUDRU_SECRET_ID=
```
Ключ для доступа необходимо сгенерировать в ЛК cloudEvolution

https://console.cloud.ru/profile/apiKeys

### Создаем файл ```terraform.tfvars``` в папке ```terraform-evolution/```
```
auth_key_id = ""
auth_secret = ""
project_id = ""
customer_id = ""
```
Первые два ключа ```auth_key_id``` и ```auth_secret``` мы уже получили выше  
Другие два можно получить в ЛК Evolution:  
```project_id``` - В верхнем левом углу выбрать проект и скопировать его айди.  
```customer_id``` - Можно найти на странице с [личными данными](https://console.cloud.ru/profile/info)

### Выполнить настройку кластера и установку всех необходимых сервисов
```bash
chmod +x deploy.sh && ./deploy.sh
```
### Выполнить полное удаление кластера после завершения работ
```bash
chmod +x destroy.sh && ./destroy.sh
```

## Подробное пошаговое описание:

### 1️⃣ Поднять Kubernetes-кластер
```bash
terraform -chdir=terraform-evolution init
terraform -chdir=terraform-evolution apply -auto-approve
```

### 2️⃣ Получить конфигурационный файл для полключения и подключиться к кластеру
```bash
chmod +x ./scripts/kubeconfig.sh
./scripts/kubeconfig.sh
```

### 3️⃣ Деплой тестового сервиса (при необходимости)
```bash
kubectl apply -f whoami.yaml
```
### 4️⃣ Установить Gateway API CRDS
```bash
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.1/standard-install.yaml
```
### 5️⃣ Установить cert-manager
```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
```
Включить Gateway API:
```bash
kubectl -n cert-manager patch deploy cert-manager \
  --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--enable-gateway-api"}]'
```

По готовности подов(```kubectl get pods -n cert-manager```) создать ClusterIssuer:
```bash
kubectl apply -f ./cert-manager/issuer.yaml
```

### 6️⃣ Установить Envoy Gateway
```bash
kubectl apply --server-side -f https://github.com/envoyproxy/gateway/releases/download/v1.6.2/install.yaml
```
Создать GatewayClass:
```bash
kubectl apply -f ./gateway/gatewayclass.yaml
```

### 7️⃣ Создать Gateway с временным доменом
```bash
YOUR_LOAD_BALANCER_IP=example.com envsubst < ./gateway/gateway.yaml | kubectl apply -f -
```

### 8️⃣ Получить LoadBalancer IP и обновить домены
```bash
chmod +x ./scripts/getip.sh ./scripts/renewdomainnames.sh
./scripts/getip.sh
./scripts/renewdomainnames.sh
```

## ___☑️ Кластер настроен и готов к работе___

> ### 🧹 Удаление кластера ```terraform -chdir=terraform-evolution destroy -auto-approve``` (_применять с осторожностью_)

## Установка сервисов

### Обновляем репозитории

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add portainer https://portainer.github.io/k8s/
helm repo update
```
### Устанавливаем мониторинг

#### Loki
```bash
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
```
#### Grafana/Prometheus
```bash
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
```

По готовности подов ```kubectl get pods,svc -n monitoring``` можем получить пароль для входа в учетную запись ```admin``` Grafana
```bash
kubectl get secret -n monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode
```
### Устанавливаем Portainer

#### Portainer
```bash
helm upgrade --install portainer portainer/portainer \
  --namespace portainer \
  --create-namespace \
  --set service.type=ClusterIP \
  --set tls.force=false \
  --set image.tag=lts \
  --set ingress.enabled=false
```
### Обновляем доменные имена и получаем сертификаты
```bash
./scripts/renewdomainnames.sh
```

### Устанавливаем DB

#### PostgreSQL
...