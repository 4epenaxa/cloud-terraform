# Envoy Gateway + cert-manager + nip.io (Auto HTTPS)

Этот репозиторий поднимает Kubernetes-кластер, настраивает:
- Envoy Gateway (Gateway API)
- cert-manager + Let’s Encrypt
- HTTPRoute
- автоматический домен вида `<LB_IP>.nip.io`
- HTTPS без ручного DNS

---

## 📋 Требования

- terraform
- kubectl
- envsubst
- bash / sh
- доступ к Kubernetes (VPS / cloud)

---

## 🚀 Быстрый старт

### 1️⃣ Поднять Kubernetes-кластер
```bash
terraform apply -auto-approve
```

### 2️⃣ Подключиться к кластеру
```
chmod +x kubeconfig.sh
./kubeconfig.sh
```

### 3️⃣ Деплой тестового сервиса
```
kubectl apply -f whoami.yaml
```

### 4️⃣ Установить cert-manager
```
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
```
Включить Gateway API:
```
kubectl -n cert-manager patch deploy cert-manager \
  --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--enable-gateway-api"}]'
```

Создать ClusterIssuer:
```
kubectl apply -f issuer.yaml
```

### 5️⃣ Установить Envoy Gateway
```
kubectl apply --server-side -f https://github.com/envoyproxy/gateway/releases/download/v1.6.2/install.yaml
```
Создать GatewayClass:
```
kubectl apply -f gatewayclass.yaml
```

### 6️⃣ Создать Gateway с временным доменом
```
YOUR_LOAD_BALANCER_IP=example.com envsubst < gateway.yaml | kubectl apply -f -
```

### 7️⃣ Получить LoadBalancer IP и обновить домены
```
chmod +x getip.sh renewdomainnames.sh
./getip.sh
./renewdomainnames.sh
```

### 🧹 Удаление
```
terraform destroy -auto-approve
```