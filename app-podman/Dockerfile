# Imagen base: Nginx sobre Alpine (ligera)
FROM docker.io/library/nginx:alpine

# Herramientas para generar durante el build el certificado y las credenciales
RUN apk add --no-cache openssl apache2-utils && mkdir -p /etc/nginx/certs

# Certificado x.509 autofirmado (autocontenido, sin nada externo)
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/certs/server.key \
    -out    /etc/nginx/certs/server.crt \
    -subj   "/C=ES/ST=Espana/L=Malaga/O=UNIR/CN=cp2.unir.local" \
    -addext "subjectAltName=DNS:cp2.unir.local"

# Credenciales de la autenticación básica (usuario / contraseña)
ARG WEB_USER=alumno
ARG WEB_PASS=unir2026
RUN htpasswd -cb /etc/nginx/.htpasswd $WEB_USER $WEB_PASS

# Configuración de Nginx (HTTPS + auth) y contenido web
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY html/      /usr/share/nginx/html/

# La app escucha en HTTPS
EXPOSE 443