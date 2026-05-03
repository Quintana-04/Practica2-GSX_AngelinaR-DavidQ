# Practica2-GSX_AngelinaR-DavidQ

Instalacion Docker:
sudo apt install docker.io -y

Ademas tambien hay que instalar la herramienta curl.

## ------ Nginx Container ------

- Creamos la carpeta: Documents/gsx/practica2/nginx-server
- Dentro de esta carpeta creamos un Dockerfile.
- Construimos la imagen localmente: sudo docker build -t nginx-gsx .
- Lo testeamos localmente: sudo docker run -p 80:80 nginx-gsx
- Al hacer curl localhost, el contenedor responde con la página oficial "Welcome to nginx!".

## ------ Aplicación Python ------

- Creamos la carpeta: Documents/gsx/practica2/python-app
- Dentro de esa carpeta creamos un script que levanta un servidor HTTP en el puerto 8000 y responde "Hello from container..." y tambien un Dockerfile que use este script.
- Construimos la imagen localmente: sudo docker build -t python-gsx .
- Lo testeamos localmente: sudo docker run -p 80:8000 python-gsx
- Al hacer curl localhost, el contenedor responde con "Hello from container - GreenDevCorp Python App".
