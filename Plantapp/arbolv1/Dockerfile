FROM cirrusci/flutter:latest

# Establecer el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copia el proyecto completo al contenedor
COPY . .

# Prepara los paquetes de Flutter que se guardan en pub get, instala las dependencias necesarias
RUN flutter pub get

# Correr el proyecto
CMD ["flutter", "run"]
