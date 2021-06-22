# Laboratorio opcional Docker-AWS.

Vamos a crear una imágen del proyecto para poder iniciar contenedores Docker a partir de ella.

## Descargar el directorio que contiene nuestro bundler de producción.

https://github.com/Lemoncode/master-frontend-lemoncode/tree/master/07-cloud/01-basic/01-production-bundle

## Añadir fichero Dockerfile.

Una vez tenemos copiado el proyecto, creamos un archivo en el directorio principal que llamaremos Dockerfile para crear nuestras imagenes custom.
Dentro del fichero Dockerfile añadimos la siguiente configuración:

- Al ser una aplicación Node debemos descargar su imágen oficial con las características mínimas (alpine) y versión 12. Esta imágen usa el sistema operativo Linux. 
Para ello escribimos en el fichero el siguiente código:
 `FROM node:12-alpine AS base`

- El siguiente paso será crear un directorio dentro del contenedor dónde se alojará nuestra aplicación en nuestro sistema operativo virtual.
Para poder ejecutar un comando dentro del contenedor iniciamos con RUN. Después simplemente escribimos los comandos correspondientes para crear un drectorio en Linux.
 `RUN mkdir -p /usr/app`

- Elegimos el directorio dónde vamos a trabajar con WORKDIR y la ruta dónde trabajaremos dentro del contenedor.
 `WORKDIR /usr/app` 

