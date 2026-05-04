#!/bin/bash

# Configuración - CAMBIA ESTO
USER="quinti04"
NGINX_IMG="$USER/nginx-gsx:v1"
PYTHON_IMG="$USER/python-gsx:v1"
NGINX_TAG="nginx-gsx"
PYTHON_TAG="python-gsx"


echo "VERIFICACIÓN SEMANA 8"

# 1. Comprobar Dockerfiles
echo -e "\n[ ] Comprobando archivos"
if [ -f "./nginx-server/Dockerfile" ] && [ -f "./python-app/Dockerfile" ]; then
    echo "OK. Dockerfiles de nginx-server y python-app encontrados"
else
    echo "ERROR: Dockerfiles no encontrados."
fi

# 2. Verificar Builds Locales
echo -e "\n[ ] Verificando Imágenes Locales..."
if [[ "$(sudo docker images -q $NGINX_TAG 2> /dev/null)" != "" ]]; then
    echo "  - Imagen $NGINX_TAG: LOCALIZADA"
else
    echo "  - Imagen $NGINX_TAG: NO ENCONTRADA"
fi

if [[ "$(sudo docker images -q $PYTHON_TAG 2> /dev/null)" != "" ]]; then
    echo "  - Imagen $PYTHON_TAG: LOCALIZADA"
else
    echo "  - Imagen $PYTHON_TAG: NO ENCONTRADA"
fi

# 3. Comprobar Imágenes en Docker Hub (Simulando pull)
echo -e "\n[ ] Comprobando imágenes en Docker Hub..."
sudo docker pull $NGINX_IMG > /dev/null 2>&1 && echo "  - Nginx en Hub: OK" || echo "  - Nginx en Hub: FALLO"
sudo docker pull $PYTHON_IMG > /dev/null 2>&1 && echo "  - Python en Hub: OK" || echo "  - Python en Hub: FALLO"

# 4. Comprobar Ejecución y Puertos
echo -e "\n[ ] Comprobando conectividad local..."

# Limpiar posibles tests anteriores
sudo docker rm -f test-check-nginx test-check-python > /dev/null 2>&1

# Lanzar contenedores de prueba
sudo docker run -d -p 8080:80 --name test-check-nginx $NGINX_IMG > /dev/null
sudo docker run -d -p 8081:8000 --name test-check-python $PYTHON_IMG > /dev/null

# Esperar un segundo a que arranquen
sleep 2

# Test Nginx (Puerto 8080)
if curl -s localhost:8080 | grep -q "nginx"; then
    echo "  - Servicio Nginx (8080): FUNCIONA"
else
    echo "  - Servicio Nginx (8080): FALLO"
fi

# Test Python (Puerto 8081)
if curl -s localhost:8081 | grep -q "Hello from container"; then
    echo "  - Servicio Python (8081): FUNCIONA"
else
    echo "  - Servicio Python (8081): FALLO"
fi

# Limpieza final
sudo docker rm -f test-check-nginx test-check-python > /dev/null
echo -e "\nVERIFICACIÓN COMPLETADA"
