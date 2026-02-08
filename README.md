# Cloud Evolution - Terraform Managed Kubernetes Cluster + services

Этот репозиторий поднимает Kubernetes-кластер, настраивает:
- Envoy Gateway (Gateway API)
- cert-manager + Let’s Encrypt
- HTTPRoute для сервисов
- автоматический домен вида `<LB_IP>.nip.io`
- HTTPS
- Monitoring - Grafana + Loki + Prometheus
- UI - Portainer
- DB - Postgres


---

## 📋 Требования

Пакеты необходимые для работы с любым кластером k8s  
- Terraform  https://developer.hashicorp.com/terraform/install  
- Kubectl https://kubernetes.io/docs/tasks/tools/  
- Helm https://github.com/helm/helm/releases/tag/v4.1.0  

Для работы с Cloud Evolution понадобится:
- Cloud provider https://cloud.ru/docs/terraform-evolution/ug/topics/quickstart  
- Cloudlogin https://cloud.ru/docs/kubernetes-evolution/ug/topics/guides__cluster__download-cloudlogin  

---

## 🚀 Быстрый старт

### 1. Создаем файл ```.env``` в папке ```terraform-evolution/```
```
CLOUDRU_KEY_ID=
CLOUDRU_SECRET_ID=
```
Ключ для доступа необходимо сгенерировать в ЛК cloudEvolution

https://console.cloud.ru/profile/apiKeys

### 2. Создаем файл ```terraform.tfvars``` в папке ```terraform-evolution/```
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

### 3. Указываем свою почту в ```cert-manager/issuer.yaml```

### 4. Выполняем настройку кластера и установку всех необходимых сервисов
```bash
chmod +x deploy.sh && ./deploy.sh
```

---
### Выполнить полное удаление кластера после завершения работ
### (___использовать с осторожностью___)
```bash
chmod +x destroy.sh && ./destroy.sh
```

--- 
См. [Manual.md](Manual.md) для пошаговой инструкции.
---
## TODO / Планируемые доработки 🚀

Ниже перечислены задачи и улучшения, которые планируются для следующих версий проекта:

- [ ] Вендоринг зависимостей  
- [ ] Бэкап кластера на S3  
- [ ] Добавить поддержку разных сред установки  
      *Цель: добавить совместимость с Windows/WSL*
- [ ] Улучшить систему логирования, улучишь Manual.md  
      *Цель: сделать отладку и мониторинг выполнения скриптов более наглядными.*
