# Practica2-GSX_AngelinaR-DavidQ

# WEEK 8

#### Instalacion Docker:
Primero comprobamos si ya tenemos docker instalado:
```
docker --version
```

Si no lo tenemos, lo instalamos:
```
sudo apt update
sudo apt install docker.io -y
```

#### Arranque del servicio docker
Arrancamos el servicio:
```
sudo systemctl start docker
```

Lo ponemos en enable para que se arranque de forma automatica cada vez que se arranque la maquina:
```
sudo systemctl enable docer
```

Comprobamos el correcto funcionamiento ejecutando la siguiente prueba:
```
sudo docker run hello-world
```

Ademas tambien hay que instalar la herramienta curl.

## ------ Nginx Container ------

- Creamos la carpeta: Documents/gsx/practica2/nginx-server
- Dentro de esta carpeta creamos un Dockerfile.
- Construimos la imagen localmente: ```sudo docker build -t nginx-gsx .```
- Lo testeamos localmente: ```sudo docker run -p 80:80 nginx-gsx```
- Al hacer curl localhost, el contenedor responde con la página oficial "Welcome to nginx!".

### Explicacion
- Imagen base: Usamos nginx:latest porque es la que nos pide el enunciado, pero ademas porque es la imagen oficial mantenida, garantizando parches de seguridad actualizados y compatibilidad total con configuraciones estándar.
- Optamos por mantener la configuración por defecto para verificar la correcta conectividad del puerto 80 antes de aplicar personalizaciones.

## ------ Aplicación Python ------

- Creamos la carpeta: Documents/gsx/practica2/python-app
- Dentro de esa carpeta creamos un script que levanta un servidor HTTP en el puerto 8000 y responde "Hello from container..." y tambien un Dockerfile que use este script.
- Construimos la imagen localmente: ```sudo docker build -t python-gsx .```
- Lo testeamos localmente: ```sudo docker run -p 80:8000 python-gsx```
- Al hacer curl localhost, el contenedor responde con "Hello from container - GreenDevCorp Python App".

### Explicacion
- Imagen base: Se ha seleccioando python:3.9-slim porque a diferencia de la imagen completa de Python, que puede ser pesada, la versión slim reduce drásticamente el tamaño de la imagen, lo que acelera el despliegue y minimiza las vulnerabilidades.
- Se ha definido un directorio de trabajo (WORKDIR /app) para evitar ejecutar procesos en la raíz del sistema de archivos del contenedor.

## ------ Docker Hub ------
Hemos subido las imagenes a quinti04/nginx-gsx:v1 y quinti04/python-gsx:v1 primero haciendo para cada una:
- ```sudo docker tag nginx-gsx quinti04/nginx-gsx:v1```
- ```sudo docker tag python-gsx quinti04/python-gsx:v1```

Y despues haciendo:
- ```sudo docker push quinti04/nginx-gsx:v1```
- ```sudo docker push quinti04/python-gsx:v1```

Para comprobar que estan bien subidas hacemos docker pull y para comprobar que van bien, primero borramos borramos las imagenes locales haciendo ```sudo docker rmi quinti04/nginx-gsx:v1 quinti04/python-gsx:v1```, al hacer pull deberia salir un mensaje del estilo de ```Pulling from quinti04/...```. Despues hacemos docker run.


# WEEK 9

Comprobar si tenemos docker-compose instalado:
```
docker compose version
```

Si no lo tenemos, lo instalamos:
```
sudo apt update
sudo apt install docker-compose -y
```

1. Podemos ver que el docker-compose.yml tiene 2 servicios definidos entrando dentro del archivo mediante 'nano' por ejemplo.

2. Para comprobar que todos los servicios funcionan al hacer ```sudo docker compose up -d´´´, primero hay que ejecutar esta comanda para iniciar el docker compose, y luego haremos ```sudo docker compose ps``` y podremos observar que estan bien levantados.

3. Para comrpobar que los servicios se comunican entre ellos realizaremos la siguiente comanda:
```
sudo docker compose exec web-server curl http://python-app:8000
```
Nos intentamos comunicar desde el servicio de nginx hacia el de python a traves de su nombre tal cual y no por ips. El resultado que esperamos es una respuesta exitosa (codigo 200 OK) del servidor Python.

4. Para demostrar que los volumenes estan configurados y que por lo tanto los datos no se borran al destruir los contenedores haremos lo siguiente:
- Primero encender si no esta encendido: ```sudo docker compose up -d```
- Crear un dato: ```sudo docker compose exec python-app touch /app/data/salvado.txt```
- Destruir: ```sudo docker compose down```
- Reiniciar: ```sudo docker compose up -d```
- Verificar: ```sudo docker compose exec python-app ls /app/data/```
Lo que esperamos es ver que el archivo salvado.txt sigue existiendo.

5. Para ver que hemos usado variables globales y no hardcodeadas haremos lo siguiente:
- Verificar que el archivo .env esta bien creado dentro de la carpeta ~/docker-compose: ```cat .env```
- A continuación verificar que en el docker-compose.yml aparezcan símbolos de dólar como ${NGINX_PORT_EXT} en lugar de números fijos.

6. Dar un .env.example
- Para dar una plantilla de como crear un archivo .env, primero haremos lo siguiente: ```cp .env .env.example```. Luego podemos editar el archivo .env.example para quitar los valores reales/secretos y despues verificariamos que estos cambios se han aplicado.

7. Diagrama de arquitectura

[ ~/Documents/gsx/practica2/week9/ ]
-----------------------------------------------------------------------------
|  Directorio del Proyecto: ~/Documents/gsx/practica2/week9/docker-compose/ |
|  ----> [.env]                                                             |
|  ----> [docker-compose.yml]
|                                                                           |
|   [ DOCKER COMPOSE ]                                                      |
|   ---------------------------------------------------------------         |
|   |      RED VIRTUAL (gsx-network - Driver: Bridge)             |         |
|   |  (Aislamiento y Resolución de Nombres de Servicio)          |         |
|   |         ^                               ^                   |         |
|   |         |                               |                   |         |
|   |   +-----------+                   +-----------+             |         |
|   |   |  Service  |                   |  Service  |             |         |
|   |   |    WEB    | <---------------> |  BACKEND  |             |         |
|   |   |  (Nginx)  |                   |  (Python) |             |         |
|   |   +-----------+                   +-----------+             |         |
|   |         |                               |                   |         |
|   ----------|-------------------------------|--------------------         |
|             |                               |                             |
|   [ PUERTOS EXPUSTOS ]              [ VOLUMEN PERSISTENTE ]               |
|      (Host: 8080)                    (python_data: /app/data)             |
-----------------------------------------------------------------------------

Explicacion:
- Orquestación: Un único archivo docker-compose.yml coordina todo, permitiendo un despliegue reproducible y automatizado.
- Servicios: Se definen dos contenedores principales: un servidor web (Nginx) y un backend (Python).
- Networking: Los servicios operan en una red aislada (gsx-network), comunicándose entre sí por su nombre de servicio mediante el DNS interno de Docker.
- Configuración: Se utiliza un archivo .env para centralizar variables como puertos y versiones, evitando valores fijos (hardcoded) en el código.
- Persistencia: Un volumen gestionado garantiza que los datos críticos del backend sobrevivan a reinicios o paradas de los contenedores.


# WEEK 10

### ------ Deployment ------
Es un recurso que proporciona actualizaciones declarativas para los Pods y ReplicaSets. Se encarga de mantener el número deseado de réplicas en funcionamiento y gestiona los ciclos de vida de las aplicaciones, permitiendo actualizaciones progresivas sin tiempo de inactividad.

### ------ Service ------
Es una abstracción que define un conjunto lógico de Pods y una política para acceder a ellos. Los Pods son efímeros y sus direcciones IP cambian al reiniciarse, el Service proporciona una dirección IP estable y un nombre de DNS para que otros servicios puedan localizarlos.

### ------ ConfigMap ------
Es un objeto de la API de Kubernetes utilizado para almacenar datos no confidenciales en pares clave-valor. Permite desacoplar la configuración del entorno de las imágenes de los contenedores, lo que facilita la portabilidad de las aplicaciones entre desarrollo y producción sin cambiar el código.


- How do pods communicate?
Los Pods se comunican entre sí utilizando el Service Discovery interno del clúster. Kubernetes asigna un nombre de DNS a cada Service (ej. backend-service), permitiendo que el servidor web llegue al backend simplemente llamando a http://backend-service:8000 sin conocer la IP real de los Pods.

- How do external clients reach services?
Se utiliza un servicio de tipo NodePort para el servidor web. Esto expone un puerto específico en todas las IPs de los nodos del clúster, permitiendo que el tráfico externo sea redirigido desde el host hacia el Service y finalmente a los Pods.

### Scalling Behavior
El escalado en Kubernetes es declarativo y responde al cambio en el número de replicas definido en el Deployment:

    1. Scale Up: Al aumentar las réplicas el Control Plane detecta la discrepancia y crea nuevos Pods, programándolos en los nodos disponibles.
    
    2. Scale Down: Al reducir las réplicas, Kubernetes selecciona Pods para su terminación, asegurando un cierre ordenado hasta alcanzar el número exacto solicitado.

La resiliencia de Kubernetes hace que si un Pod se elimina manualmente o falla, Kubernetes lo detecta mediante su bucle de control y crea uno nuevo automáticamente para mantener siempre el número deseado de réplicas.


Primero comprobamos si ya tenemos minikube instalado:
```
minikube version
```

Si no lo tenemos, lo instalamos. Para ello tenemos que realizar los siguientes comandos:
```
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```
Importante luego borrar el primer archivo descargado ya que pesa mucho y no es necesario

Para acabar de hacer la instalacion tambien tenemo que descargar kubectl
```
sudo apt update
sudo apt install -y kubectl
```

Finalmente borramos el binario inneceario que pesa bastante ya que no nos hace mas falta:
```
rm minikube-linux-amd64
```

Ahora ya si podemos empezar el cluster

1. Ejecutar ```minikube start``` y confirmar con ```kubectl cluster-info```

2. Los manifest files se encuentran en la carpeta ~/week10/kubernetes

3. Primero ejecutamos ```kubectl apply -f kubernetes/``` y comprobamos con ```kubectl get pods```

4. Para comprorbarlo ejecutamos ```kubectl get services```

5. Ejecutamos ```kubectl exec -it <pod-name> -- bash``` donde '<pod-name>' es el nombre del pod de nginx que hemos obtenido antes (ej. nginx-deployment-79d68f94d-wdvvp) y una vez dentro de ese bash hacemos ```curl http://backend-service:8000``` y veremos que responde como esperamos con un mensaje de 'Hello from container...'.

6. Para escalar tenemos que ejecutar ```kubectl scale deployment nginx-deployment --replicas=3```. Despues hacemos ```kubectl get pods --watch``` para ver como se han creado nuevos pods. Por ultimo hacemos ```kubectl scale deployment nginx-deployment --replicas=1``` y volvemos a mirar los pods para comprobar que se han eliminado dos y no hemos quedado otra vez con 1.

7. Hacemos ```kubectl delete pod <pod-name>``` para forzar a borrar un pod y mostrar que kubernetes creara uno nuevo de forma inmediata para mantener el estado deseado, lo comprobamos otra vez con ```kubectl get pods --watch```.

8. Ejecutamos ```kubectl describe configmap gsx-config``` para enseñar que usamos un configmap para la configuracion de los puertos.


# WEEK 11

### ------ Herramienta IaC elegida: Terraform ------
Hemos elegido **Terraform** porque describe el estado final deseado y calcula automáticamente los pasos para llegar a él. Es idempotente: ejecutarlo dos veces sobre el mismo estado no hace nada.

### ------ Instalación de Terraform ------
Primero comprobamos si ya tenemos Terraform instalado:
```
terraform -v
```

Si no lo tenemos, lo instalamos:
```
wget -O /tmp/terraform.zip https://releases.hashicorp.com/terraform/1.7.5/terraform_1.7.5_linux_amd64.zip
unzip /tmp/terraform.zip -d /tmp/
sudo mv /tmp/terraform /usr/local/bin/
terraform -v
```

### ------ Estructura del código ------
Los archivos de Terraform se encuentran en `week11/terraform/`:
- `main.tf` — Define todos los recursos Kubernetes (ConfigMap, Deployments, Services)
- `variables.tf` — Parámetros configurables (usuario Docker Hub, tag de imagen, réplicas, puertos)
- `outputs.tf` — Información útil tras el despliegue (NodePort, nombre del servicio, imágenes desplegadas)

### ------ Despliegue con Terraform ------

1. Inicializar Terraform:
```
cd week11/terraform
terraform init
```

2. Ver qué se va a crear:
```
terraform plan
```

3. Aplicar (crear recursos en Minikube):
```
terraform apply
```

4. Verificar que todo está correcto:
```
kubectl get pods
kubectl get services
```

5. Para demostrar que la infraestructura es reproducible desde cero (destroy + apply):
```
terraform destroy
terraform apply
```

6. Para desplegar con un tag de imagen concreto (ej. SHA generado por CI):
```
terraform apply -var="image_tag=a1b2c3d4"
```

### ------ Variables ------
| Variable | Descripción | Valor por defecto |
|---|---|---|
| `dockerhub_user` | Usuario de Docker Hub | `quinti04` |
| `image_tag` | Tag de imagen a desplegar | `v1` |
| `backend_replicas` | Réplicas del backend Python | `1` |
| `nginx_replicas` | Réplicas del servidor Nginx | `1` |
| `backend_port` | Puerto del backend | `8000` |
| `nginx_port` | Puerto de Nginx | `80` |

### ------ CI/CD Pipeline (GitHub Actions) ------
El workflow se encuentra en `.github/workflows/ci.yml` y se dispara automáticamente en cada push a `main`.

**¿Qué hace el CI?**
1. Construye las imágenes Docker de Nginx y Python
2. Las sube a Docker Hub con el SHA corto del commit como tag (ej. `a1b2c3d4`) y también como `latest`
3. Valida el código Terraform (`fmt`, `init`, `validate`) sin tocar Minikube

**¿Por qué no despliega en Minikube desde GitHub Actions?**
GitHub Actions corre en servidores remotos y no tiene acceso a nuestro Minikube local. Por eso el CD (despliegue) se hace manualmente en local con `terraform apply`.

**Flujo completo:**
```
git push → CI verde (imágenes en Docker Hub) → terraform apply -var="image_tag=<sha>" → Minikube actualizado
```

### ------ ¿Por qué versionar la infraestructura? ------
Tener el código de infraestructura en Git significa que cualquier cambio queda registrado: quién lo hizo, cuándo y por qué. Si algo se rompe, se puede volver a un estado anterior. Además, cualquier miembro del equipo puede reproducir el entorno exacto desde cero sin depender de configuraciones manuales o de memoria.

### ------ ¿Cómo aseguramos que los cambios son seguros? ------
Siempre ejecutamos `terraform plan` antes de `terraform apply`. El plan muestra exactamente qué se va a crear, modificar o destruir sin tocar nada. Esto permite revisar los cambios antes de aplicarlos y detectar errores. Además, el CI valida el código Terraform en cada push, asegurando que el código es sintácticamente correcto antes de llegar a producción.

### ------ Verificación ------
Para verificar que todo funciona correctamente ejecutar el script:
```
./week11/check11.sh
```

El script comprueba:
- Pods en estado Running
- Services activos
- Nginx responde en http://192.168.49.2:30080
- Backend responde con "Hello from container - GreenDevCorp Python App"

# WEEK 12

## ------ Diseño de Red ------

### Diagrama de Arquitectura

<img width="1219" height="849" alt="diagramagsx drawio" src="https://github.com/user-attachments/assets/830e6dbf-99f0-494a-ab34-1333cc756ce5" />


### Plan CIDR

| Subred | Rango | IPs disponibles | Uso |
|---|---|---|---|
| 10.0.0.0/24 | DMZ | 254 | Nginx, load balancer, acceso externo |
| 10.0.1.0/24 | Development | 254 | Pods y servicios de desarrollo |
| 10.0.2.0/24 | Staging | 254 | Entorno de pruebas pre-producción |
| 10.0.3.0/24 | Production | 254 | Servicios en producción |
| 10.0.4.0/24 | Database | 254 | BBDDs, solo accesible desde producción |
| 10.0.10.0/24 | Partners | 254 | Acceso externo limitado, solo DMZ |

Usamos `10.0.0.0/16` para toda la organización, lo que deja margen para crecer sin rehacer el esquema. Cada entorno tiene su propio `/24` para un aislamiento claro entre desarrollo, staging y producción.

## ------ NetworkPolicies ------

Los manifests se encuentran en `week12/kubernetes/`. Implementan las siguientes reglas:

- **default-deny-all**: deniega todo el tráfico entrante y saliente por defecto
- **allow-dns**: permite consultas DNS (puerto 53) para todos los pods
- **allow-external-to-nginx**: permite tráfico externo hacia Nginx (puerto 80)
- **allow-nginx-to-backend**: permite que Nginx reciba tráfico del backend (puerto 8000)
- **allow-nginx-egress-to-backend**: permite que Nginx inicie conexiones hacia el backend

### Verificación

Para verificar que las políticas funcionan correctamente:
```
bash week12/check12.sh
```

El script comprueba:
- NetworkPolicies activas en el clúster
- Tráfico externo → Nginx: **permitido**
- Nginx → Backend: **permitido**
- Backend → Exterior: **bloqueado** (segmentación funciona)

### Fronteras de Seguridad

- El tráfico entre entornos (dev/staging/prod) está bloqueado por defecto
- Solo Nginx puede recibir tráfico externo
- El backend solo es accesible desde Nginx
- Los partners solo tienen acceso a la DMZ

## ------ Investigación ------

La investigación completa sobre DNS, DHCP, NTP, autenticación/autorización, LDAP, Active Directory, SSO y la recomendación de identidad para GreenDevCorp se encuentra en `week12/research.md`.
