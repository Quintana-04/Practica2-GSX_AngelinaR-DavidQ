# Runbook Operacional — GreenDevCorp Infrastructure

## 1. Descripción de Componentes

### Nginx (web-server)
- **Qué hace**: Servidor web y punto de entrada externo. Recibe tráfico HTTP en el puerto 80 y lo sirve directamente o lo redirige al backend.
- **Imagen**: `quinti04/nginx-gsx:v1`
- **Puerto**: 80 (interno) / 30080 (NodePort externo)
- **Dependencias**: ninguna para arrancar; se comunica con el backend para servir contenido dinámico.
- **Cómo se despliega**: Definido en `week11/terraform/main.tf` como `kubernetes_deployment.nginx`. También disponible como manifest en `week10/kubernetes/nginx-deployment.yaml`.
- **Configuración**: Puerto leído del ConfigMap `gsx-config`.

### Backend Python (backend)
- **Qué hace**: Servidor HTTP simple que responde a peticiones con "Hello from container - GreenDevCorp Python App".
- **Imagen**: `quinti04/python-gsx:v1`
- **Puerto**: 8000
- **Dependencias**: ninguna externa; solo necesita el ConfigMap `gsx-config` para leer el puerto.
- **Cómo se despliega**: Definido en `week11/terraform/main.tf` como `kubernetes_deployment.backend`. También disponible como manifest en `week10/kubernetes/backend-deployment.yaml`.
- **Configuración**: Variable `APP_PORT` leída del ConfigMap `gsx-config`.

### ConfigMap (gsx-config)
- **Qué hace**: Almacena configuración no sensible (puertos) para desacoplarla de las imágenes.
- **Claves**: `nginx_port=80`, `python_port=8000`

### NetworkPolicies
- **Qué hacen**: Controlan el tráfico de red entre pods. Ver `week12/kubernetes/` para los manifests.
- **Resumen**: default-deny-all + reglas explícitas para DNS, acceso externo a nginx y comunicación nginx↔backend.

---

## 2. Quick Start — Desplegar desde cero

### Requisitos previos
- Docker instalado y corriendo
- Minikube instalado
- Terraform instalado
- kubectl instalado

### Pasos

1. Arrancar el clúster:
```
minikube start --memory=2500mb --cni=kindnet --driver=docker
```

2. Verificar que el nodo está Ready:
```
kubectl get nodes
```

3. Desplegar infraestructura con Terraform:
```
cd week11/terraform
terraform init
terraform apply -auto-approve
```

4. Aplicar NetworkPolicies:
```
kubectl apply -f week12/kubernetes/
```

5. Verificar que todo funciona:
```
kubectl get pods
kubectl get services
bash week12/check12.sh
```

6. Acceder a Nginx desde el host:
```
curl http://192.168.49.2:30080
```

---

## 3. Operaciones Comunes

### Desplegar una nueva versión

1. Hacer cambios en el código de la aplicación
2. Hacer push a GitHub — el CI construye y sube la nueva imagen con el SHA del commit
3. Desplegar localmente con el nuevo tag:
```
cd week11/terraform
terraform apply -var="image_tag=<sha_del_commit>"
```

### Escalar un servicio
```
kubectl scale deployment nginx-deployment --replicas=3
kubectl get pods --watch
kubectl scale deployment nginx-deployment --replicas=1
```

### Ver logs de un servicio
```

# Seguir logs en tiempo real
### Reiniciar un deployment
```

### Volver a una versión anterior
```
kubectl rollout undo deployment nginx-deployment
kubectl rollout undo deployment backend-deployment
```

### Destruir toda la infraestructura
```
cd week11/terraform
terraform destroy -auto-approve
```

---

## 4. Troubleshooting Guide

### Pod en estado Pending
**Síntoma**: `kubectl get pods` muestra un pod en `Pending`.

**Diagnóstico**:
```
kubectl describe pod <pod-name>
```
Mirar la sección `Events` al final.

**Causas comunes**:
- Nodo NotReady → `kubectl get nodes`. Si NotReady, reiniciar minikube: `minikube stop && minikube start`
- Recursos insuficientes → reducir memoria asignada a otros procesos
- ImagePullBackOff → ver siguiente sección

### Pod en estado ImagePullBackOff
**Síntoma**: `kubectl get pods` muestra `ImagePullBackOff` o `ErrImagePull`.

**Diagnóstico**:
```
kubectl describe pod <pod-name> | grep -A5 Events
```

**Causas comunes**:
- Imagen no existe en Docker Hub → verificar que el tag existe: `docker pull quinti04/nginx-gsx:v1`
- Sin conexión a internet desde minikube → problema de red en la VM

### Servicio no responde (curl timeout)
**Síntoma**: `curl http://192.168.49.2:30080` no responde.

**Diagnóstico**:
```
kubectl get pods          # pods en Running?
kubectl get services      # NodePort configurado?
minikube status           # minikube corriendo?
```

**Solución**:
```
```
kubectl rollout restart deployment nginx-deployment
# Si minikube no corre
minikube start --memory=2500mb --cni=kindnet --driver=docker
kubectl rollout restart deployment backend-deployment
kubectl logs -l app=backend -f
```

# Si los pods no están Running
cd week11/terraform && terraform apply -auto-approve

# Ver logs de nginx
# Ver logs del backend
kubectl logs -l app=backend

```

### Nginx no llega al backend (exit code 28)
**Síntoma**: `kubectl exec nginx-pod -- curl http://backend-service:8000` da timeout.


**Diagnóstico**:
```
kubectl get networkpolicies
kubectl describe networkpolicy allow-nginx-to-backend
```

**Causa**: El `podSelector` de la NetworkPolicy tiene el selector incorrecto.

**Solución**: Verificar que `allow-nginx-to-backend` tiene `podSelector: app=backend` (Ingress) y que `allow-nginx-egress-to-backend` tiene `podSelector: app=web-server` (Egress). Reaplicar:
```
kubectl apply -f week12/kubernetes/
```

### NetworkPolicies bloqueando tráfico legítimo
**Síntoma**: Un servicio que debería funcionar da timeout.

**Diagnóstico**:
```
kubectl get networkpolicies
kubectl describe networkpolicy <policy-name>
```

**Solución**: Revisar que existe una política de Ingress en el pod destino Y una política de Egress en el pod origen para el mismo puerto. Ambas son necesarias con `default-deny-all` activo.

### Minikube NotReady / CNI no inicializado
**Síntoma**: `kubectl get nodes` muestra `NotReady` con mensaje `NetworkPluginNotReady`.

**Solución**:
```
minikube delete
minikube start --memory=2500mb --cni=kindnet --driver=docker
```

---

## 5. Links a Documentación

- Semana 8 (Docker): `README.md` → sección WEEK 8
- Semana 9 (Docker Compose): `README.md` → sección WEEK 9
- Semana 10 (Kubernetes): `README.md` → sección WEEK 10 + `week10/kubernetes/`
- Semana 11 (Terraform + CI/CD): `README.md` → sección WEEK 11 + `week11/terraform/`
- Semana 12 (Red + Identidad): `week12/research.md` + `week12/kubernetes/`
- Diagrama de red: `README.md` sección week 12 el único diagram que hay

