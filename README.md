# Laboratorio opcional Docker-AWS.

Vamos a crear una imágen del proyecto para poder iniciar contenedores Docker a partir de ella. Es importante tener isntalado Docker en nuestra máquina además
de estar logeado.

## Descargar el directorio que contiene el bundler de producción.

https://github.com/Lemoncode/master-frontend-lemoncode/tree/master/07-cloud/01-basic/01-production-bundle

## Añadir fichero Dockerfile.

Una vez tenemos copiado el proyecto, creamos un archivo en el directorio principal que llamaremos Dockerfile para crear nuestras imagenes custom.
Dentro del fichero Dockerfile añadimos la siguiente configuración:

- Al ser una aplicación Node debemos descargar su imágen oficial con las características mínimas (alpine) y versión 12. Esta imágen usa el sistema operativo Linux. 
Inicializamos con FROM y continuamos con la imágen y su versión.

  `FROM node:12-alpine `

- El siguiente paso será crear un directorio dentro del contenedor dónde se alojará nuestra aplicación en nuestro sistema operativo virtual.
Para poder ejecutar un comando dentro del contenedor iniciamos con RUN. Después simplemente escribimos los comandos correspondientes para crear un drectorio en Linux.

  `RUN mkdir -p /usr/app`

- Elegimos el directorio dónde vamos a trabajar con WORKDIR y la ruta dónde trabajaremos dentro del contenedor (/usr/app).

  `WORKDIR /usr/app` 
 
- Necesitamos tener acceso a todos los ficheros del proyecto para poder hacer la build dentro del contenedor, para ello damos la orden de copiar todo el contenido del proyecto a nuestro directorio principal dentro del contenedor (/usr/app). Con el comando COPY damos la orden de copiar y con ./ estamos dándole tanto para el orígen como para el destino los directorios raíz de ambos.

  `COPY ./ ./`
  
## Añadir fichero .dockerignore.

En este paso vamos a dejar un momento el fichero Dockerfile para crear un fichero nuevo llamado .dockerignore en el directorio raiz del proyecto. Sirve para decirle a Docker que ignore los ficheros que no necesitamos en nuestro contenedor. De esta manera, cuando le damos la orden de copiar en el paso anterior, le estamos pasando las pautas a seguir para omitirlos. Así quedaría nuestro fichero .dockerignore:

node_modules

.vscode

dist

.editorconfig

.env

.env.example

.gitignore

package-lock.json

README.md

## Continuamos la configuración de Dockerfile.

- Dentro del fichero Dockerfile damos la orden para instalar las dependencias dentro del contenedor.
  
  `RUN npm install`
  
- Le decimos que haga el build para que compile el proyecto creando la carpeta dist.

  `RUN npm run build`

## Crear la imágen.
Escribimos el siguiente comando en el terminal (bash):
  `docker build -t my-laboratory-app:1`
Con ducker build damos crear la imágen y el tag -t sirve para darle el nombre que queramos (my-app). La versión se indica después 
de los dos puntos (:1). 

## Crear contenedor.

Escribimos el siguiente comando en el terminal de nuevo.

  `docker run -it my-laboratory-app:1 sh`
  
Estamos dando la orden de crear el contenedor a partir de la imágen que indicamos junto a la versión. Además, con el comando `sh` abrimos la consola bash dentro de nuestro
contendor creado. De esta manera podemos comprobar que se han creado los ficheros correctamente.

## Crear servidor web.

Para poder usar los ficheros de nuestro contenedor my-laboratory-app es necesario crear un servidor web para servir nuestros ficheros estáticos.
En este paso instalaremos nuestro servidor Node, para ello, creamos una carpeta nueva en nuestro directorio raíz y la llamaremos "server".
Dentro de server añadimos un fichero que nombramos como index.js y lo configuramos de la siguiente forma:

const express = require('express');   

const path = require('path');              

const app = express();

const staticFilesPath = path.resolve(__dirname, '../dist');

app.use('/', express.static(staticFilesPath));

const PORT = process.env.PORT || 8081;

app.listen(PORT, () => {
  console.log(`App running on http://localhost:${PORT}`);
});



Estamos indicando que usamos express y el directorio de nuestros ficheros estáticos, en este caso la carpeta dist. Y lo servimos en el puerto que nos llegue por entorno o predeterminadamente en el 8081.

## Agregar package.json al servidor web.

Escribimos `cd server` en el terminal para mover nuestro directorio a esa carpeta y trabajar en ella. 
Y a continuación el comando para crear el fichero package.json `npm init -y`.

## Añadir express como dependencia de producción.

Sin salir del directorio server instalamos express como dependencia escribiendo el siguiente código en el terminal:

`npm install express --save`

Veremos que además de instalar express como dependencia de producción en nuestro fichero server/package.json, estamos creando la carpeta node_modules correspondiente.

## Comprobar que el servidor express funciona en local.

Compilamos el proyecto para crear la carpeta dist en local. Para ello es necesario mover el directorio de la carpeta server al directorio principal del proyecto.
Escribimos `cd ..` en el terminal para movernos del directorio server al principal y a continuación el comando para hacer el compilado, `npm run build`.

Para ejecutar el fichero index.js de nuestra carpeta server, Node nos proporciona un comando para levantar el proyecto desde local `node server`.
Veremos que la consola nos informa con el siguiente texto: `App running on http://localhost:8081`. 

Abriendo http://localhost:8081 en nuestro explorador veremos el proyecto levantado en local.

## Crear servidor express dentro del contenedor.

Volver al archivo Dockerfile y añadir los siguientes comandos:

`RUN cd server` 

Le decimos a nuestro container que mueva el directorio de trabajo a la carpeta server.

`RUN npm install`

Dentro de la carpeta server realizamos la instalación de dependencias de nuestro servidor.

`ENTRYPOINT [ "node", "server" ]`

En este caso en vez de RUN usamos el comando ENTRYPOINT para arrancar el servidor, ¿por qué? El comando RUN se ejecuta justo cuando se cree la imágen, y nosotros queremos 
levantar diferentes contenedores a partir de esa imágen. Por lo tanto queremos que se ejecute sólo cuando se levante el/los contenedor/es.

Le damos el punto de entrada con el término `"node"` y la ubicación `"server"` refiriendonos a la carpeta. Hay que tener presente que este paso se ejecuta en el WORKDIR, directorio principal de nuestra aplicación dentro del container (/usr/app).
Si escribimos en la consola (bash) el comando `docker build -t my-laboratory-app:1 .` veremos cómo sea crea el contenedor y ejecuta el servidor.

Para comprobar que se ha levantado el servidor dentro del contenedor correctamente escribimos `docker run my-laboratory-app:1`, la consola mostrará el mensaje `App running on http://localhost:8081` indicandonos que se ha levantado correctamente. ¿Por qué no puedo ver la página (ERR_CONNECTION_REFUSED)? Es debido a que no tenemos acceso desde nuestra página.

## Exponer puerto de acceso.

Volver al fichero Dockerfile y añadir el siguiente código a continuación de `RUN npm install`:

`ENV PORT=8083`

Declaramos un puerto en la variable de entorno.

`EXPOSE port 8083`

Y lo exponemos.

## Comprobar cambios en la compilación.
 
Necesitamos parar el contenedor y crear uno nuevo. Escribir en la consola (bash) `docker stop` + primeros 4 valores del código del contenedor. Para ver estos códigos
es necesario escribir en consola `docker ps -a` dónde apareceran tanto los contenedores que estén arrancados como los parados.

Una vez parado el contenedor escribir de nuevo en la consola `docker build -t my-laboratory-app:1 .` para sobreescribir la versión de nuestro contenedor.
De nuevo levantamos la imágen creando un nuevo contenedor en la consola con `docker run`, con la diferencia que ahora debemos añadir la configuración de puertos al invocarlo.
Para ello necesitamos pasarle en primer lugar el puerto del contenedor que queremos exponer, en este caso el 8080. Y para terminar el puerto que hemos expuesto desde local en el 
fichero Dockerfile (8083).

Además podemos añadir el tag `--rm` justo antes de la configuración del puerto para que se elimine automáticamente el contenedor al pararse.

Asi quedaría el comando:  

`docker run --rm -p 8080:8083 my-laboratory-app:1`

Para comprobarlo escribimos `http://localhost:8080/` en nuestro explorador. Además si escribimos en la consola `docker ps` veremos el contenedor levantado con la información
de los puertos, ID, state, etc.

Escribiendo `docker images` en la consola apareceran las imagenes sin uso con el tag <none>. Si queremos eliminar dichas imagenes escribimos en consola `docker image prune`.

Viendo el tamaño que ocupa la imágen (362MB) necesitamos eliminar los ficheros de node_modules y demás que no necesitemos para quedarnos sólo con los ficheros estáticos de nuestro proyecto.

## Quitar peso a la imágen.
 
En este paso vamos a dividir la creación de nuestra imágen en fases, de esta manera podemos elegir el momento para realizar las acciones que más nos convega y borrar los ficheros creados en fases anteriores quitando peso a nuestro proyecto.

Empezamos siempre ejecutando los tres primeros pasos, arrancar desde la imágen de node, crear directorio y mover el directorio de trabajo al que acabamos de crear.
Para ello vamos al fichero `Dockerfile` de nuevo y modificamos el primer paso `FROM` para que quede así:
  
  `FROM node:12-alpine AS base`
  
  `RUN mkdir -p /usr/app`
  
  `WORKDIR /usr/app`

Creamos una fase nueva que se llamará build-front, aqui será donde ejecutaremos los pasos ya descritos para copiar los ficheros del proyecto al contenedor, instalar node_modules y hacer la build. Así quedaría:
  
  `FROM base AS build-front`
  
  `COPY ./ ./`
  
  `RUN npm install`
  
  `RUN npm run build`

Añadimos la fase de despliegue:

  `FROM base AS release`

Para poder copiar el resultado de la fase anterior (necesitamos la carpeta this de la fase `build-front`) le pasamos el nombre de la fase dónde hemos creado nuestros ficheros
estáticos (build-front), la ruta donde se encuentra la carpeta que queremos copiar (/usr/app/dist) y el destino, la carpeta public (./public):
  
  `COPY --from=build-front /usr/app/dist ./public`
  
Al ser una nueva fase tenemos el contenedor vacío, por lo que necesitamos la parte del server. Copiar el fichero package.json de server (de la fase base) al directorio raíz:
  
  `COPY ./server/package.json ./`
  
Además necesitaremos el fichero index.js, dónde se encuentra el servidor express:
  
  `COPY ./server/index.js ./`
  

Instalamos las dependencias pero indicamos que sólo las de producción:
  
  `RUN npm install --only=production`
  
## Crear variable de entorno. Al cambiar la ruta de nuestro proyecto a la carpeta public necesitamos ir al fichero de nuestro servidor express (/server/index.js) y alimentar
mediante una variable de entorno la ruta a la carpeta que teniamos predefinidia ('../dist').
  
Para ello vamos a línea dónde hemos creado la ruta de ficheros estáticos (staticFilesPath) y sustituimos `'../dist'` por `process.env`.
  

  

