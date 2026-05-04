# Practica2-GSX_AngelinaR-DavidQ

#### Instalacion Docker:
Primero comprobamos si ya tenemos docker instalado:
bash'''
docker --version
'''

Si no lo tenemos, lo instalamos:
bash'''
sudo apt update
sudo apt install docker.io -y
'''

#### Arranque del servicio docker
Arrancamos el servicio:
bash'''
sudo systemctl start docker
'''

Lo ponemos en enable para que se arranque de forma automatica cada vez que se arranque la maquina:
bash'''
sudo systemctl enable docer
'''

Comprobamos el correcto funcionamiento ejecutando la siguiente prueba:
bash'''
sudo docker run hello-world
'''

Ademas tambien hay que instalar la herramienta curl.

## ------ Nginx Container ------

- Creamos la carpeta: Documents/gsx/practica2/nginx-server
- Dentro de esta carpeta creamos un Dockerfile.
- Construimos la imagen localmente: sudo docker build -t nginx-gsx .
- Lo testeamos localmente: sudo docker run -p 80:80 nginx-gsx
- Al hacer curl localhost, el contenedor responde con la página oficial "Welcome to nginx!".

### Explicacion
- Imagen base: Usamos nginx:latest porque es la que nos pide el enunciado, pero ademas porque es la imagen oficial mantenida, garantizando parches de seguridad actualizados y compatibilidad total con configuraciones estándar.
- Optamos por mantener la configuración por defecto para verificar la correcta conectividad del puerto 80 antes de aplicar personalizaciones.

## ------ Aplicación Python ------

- Creamos la carpeta: Documents/gsx/practica2/python-app
- Dentro de esa carpeta creamos un script que levanta un servidor HTTP en el puerto 8000 y responde "Hello from container..." y tambien un Dockerfile que use este script.
- Construimos la imagen localmente: sudo docker build -t python-gsx .
- Lo testeamos localmente: sudo docker run -p 80:8000 python-gsx
- Al hacer curl localhost, el contenedor responde con "Hello from container - GreenDevCorp Python App".

### Explicacion
- Imagen base: Se ha seleccioando python:3.9-slim porque a diferencia de la imagen completa de Python, que puede ser pesada, la versión slim reduce drásticamente el tamaño de la imagen, lo que acelera el despliegue y minimiza las vulnerabilidades.
- Se ha definido un directorio de trabajo (WORKDIR /app) para evitar ejecutar procesos en la raíz del sistema de archivos del contenedor.

## ------ Docker Hub ------
Hemos subido las imagenes a quinti04/nginx-gsx:v1 y quinti04/python-gsx:v1 primero haciendo para cada una:
- sudo docker tag nginx-gsx quinti04/nginx-gsx:v1
- sudo docker tag python-gsx quinti04/python-gsx:v1

Y despues haciendo:
- sudo docker push quinti04/nginx-gsx:v1
- sudo docker push quinti04/python-gsx:v1

Para comprobar que estan bien subidas hacemos docker pull y para comprobar que van bien, primero borramos borramos las imagenes locales haciendo bash'''sudo docker rmi quinti04/nginx-gsx:v1 quinti04/python-gsx:v1''', al hacer pull deberia salir un mensaje del estilo de bash'''Pulling from quinti04/...'''. Despues hacemos docker run.
