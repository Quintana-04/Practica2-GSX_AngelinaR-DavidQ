# Usamos una imagen oficial de Python en versión ligera (slim)
FROM python:3.9-slim

# Directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiamos nuestro script al contenedor
COPY app.py .

# Informamos que la app usa el puerto 8000
EXPOSE 8000

# Comando para arrancar la app al iniciar el contenedor
CMD ["python3", "app.py"]
