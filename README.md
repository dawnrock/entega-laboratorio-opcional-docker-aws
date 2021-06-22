# Laboratorio opcional Docker-AWS.

Vamos a crear una imágen del proyecto para poder iniciar contenedores Docker a partir de ella.

## Descargar el directorio que contiene nuestro bundler de producción.

https://github.com/Lemoncode/master-frontend-lemoncode/tree/master/07-cloud/01-basic/01-production-bundle

## Añadir fichero Dockerfile.

Una vez tenemos copiado el proyecto, creamos un archivo en el directorio principal que llamaremos Dockerfile para crear nuestras imagenes custom.
Dentro del fichero Dockerfile añadimos la siguiente configuración:

- Al ser una aplicación Node debemos descargar su imágen oficial con las características mínimas (alpine) y versión 12. Esta imágen usa el sistema operativo Linux. 
Para ello escribimos en el fichero Dockerfile el siguiente código:

  `FROM node:12-alpine AS base`

- El siguiente paso será crear un directorio dentro del contenedor dónde se alojará nuestra aplicación en nuestro sistema operativo virtual.
Para poder ejecutar un comando dentro del contenedor iniciamos con RUN. Después simplemente escribimos los comandos correspondientes para crear un drectorio en Linux.

  `RUN mkdir -p /usr/app`

- Elegimos el directorio dónde vamos a trabajar con WORKDIR y la ruta dónde trabajaremos dentro del contenedor (/usr/app).

  `WORKDIR /usr/app` 
 
- Necesitamos tener acceso a todos los ficheros del proyecto para poder hacer la build dentro del contenedor, para ello damos la orden de copiar todo el contenido del proyecto a nuestro directorio principal dentro del contenedor (/usr/app).
  `COPY ./ ./`
  
## Añadir fichero .dockerignore.

En este paso vamos a dejar un momento el fichero Dockerfile para crear un fichero nuevo llamado .dockerignore en el directorio raiz del proyecto. Sirve para decirle a Docker que ignore los ficheros que no necesitamos en nuestro contenedor. De esta manera, cuando le damos la orden de copiar en el paso anterior, le estamos pasando las pautas a seguir para omitirlos. Así quedaría nuestro fichero .dockerignore:

`
node_modules

.vscode
dist
.editorconfig
.env
.env.example
.gitignore
package-lock.json
README.md
`

## Continuamos la configuración de Dockerfile.

- Damos la orden para instalar las dependencias dentro del contenedor.
  
  `RUN npm install`

