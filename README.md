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

Ahora ya si podemos empezar el cluster

