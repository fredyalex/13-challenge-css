# Usa una imagen base de Node.js (más ligera)
FROM node:lts-alpine

# Instala live-server globalmente
RUN npm install -g live-server

# Crea un directorio de trabajo para tu aplicación
WORKDIR /app

# Copia los archivos de tu carpeta 'public' al contenedor
COPY . /app/

# Expone el puerto que usará live-server
EXPOSE 8080

# Comando para ejecutar live-server
# --host=0.0.0.0 permite que sea accesible desde fuera del contenedor
# --open automáticamente abrirá el navegador al iniciar
# --port=8080 define el puerto de escucha
CMD [ "live-server", "--host=0.0.0.0", "--port=8080" ]