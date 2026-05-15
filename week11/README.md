# Week 11 – Infrastructure as Code & CI/CD

## Herramienta elegida: Terraform

Hemos elegido **Terraform** (enfoque declarativo) porque:
- Describes el estado final deseado y Terraform calcula los pasos para llegar a él.
- Es idempotente: ejecutarlo dos veces sobre el mismo estado no hace nada.
- Tiene soporte nativo para el proveedor de Kubernetes, lo que encaja bien con lo construido en Week 10.
- Alternativa considerada: Ansible (procedural) — más orientado a tareas secuenciales y configuración de sistemas operativos.

---

## Estructura

```
week11/
├── terraform/
│   ├── main.tf        # Recursos Kubernetes (deployments, services, configmap)
│   ├── variables.tf   # Parámetros configurables
│   └── outputs.tf     # Información útil tras el despliegue
└── .github/
    └── workflows/
        └── ci.yml     # Pipeline de CI (GitHub Actions)
```

---

## Variables

| Variable | Descripción | Valor por defecto |
|---|---|---|
| `dockerhub_user` | Usuario de Docker Hub | `quinti04` |
| `image_tag` | Tag de imagen a desplegar | `latest` |
| `backend_replicas` | Réplicas del backend Python | `1` |
| `nginx_replicas` | Réplicas del servidor Nginx | `1` |
| `backend_port` | Puerto del backend | `8000` |
| `nginx_port` | Puerto de Nginx | `80` |

Para usar un tag concreto (por ejemplo, el SHA generado por CI):
```bash
terraform apply -var="image_tag=a1b2c3d4"
```

---

## Cómo desplegar desde cero

### Requisitos previos
- Minikube instalado y en marcha
- Terraform instalado (`terraform -v`)
- `kubectl` configurado apuntando a minikube

```bash
minikube start
```

### 1. Inicializar Terraform
```bash
cd week11/terraform
terraform init
```

### 2. Ver qué se va a crear
```bash
terraform plan
```

### 3. Aplicar (crear recursos en Minikube)
```bash
terraform apply
```

### 4. Verificar
```bash
kubectl get pods
kubectl get services
minikube service web-service --url   # URL de acceso externo
```

### 5. Destruir (limpiar todo)
```bash
terraform destroy
```

---

## Flujo CI/CD

### CI en GitHub Actions (automático al hacer push a main)
1. Checkout del código.
2. Build de las dos imágenes Docker (`nginx-gsx` y `python-gsx`).
3. Tag con el **SHA corto del commit** (8 caracteres) + `latest`.
4. Push a Docker Hub.
5. Validación de Terraform: `fmt -check` → `init -backend=false` → `validate`.

> GitHub Actions **no despliega en Minikube** porque no tiene acceso a nuestra máquina local.

### CD local (manual, tras CI verde)

```bash
# 1. Anotar el tag generado por CI (ver output del workflow o docker hub)
IMAGE_TAG=<sha-corto>   # ejemplo: a1b2c3d4

# 2. Aplicar con ese tag
cd week11/terraform
terraform apply -var="image_tag=$IMAGE_TAG"

# 3. Verificar que los pods usan la nueva imagen
kubectl get pods
kubectl describe pod <pod-name> | grep Image
```

---

## Outputs de Terraform

Tras `terraform apply`, se muestran:

| Output | Descripción |
|---|---|
| `nginx_nodeport` | Puerto NodePort para acceder a Nginx desde fuera del cluster (30080) |
| `backend_service_name` | Nombre DNS interno del servicio backend |
| `image_deployed` | Imagen completa desplegada para cada servicio |
