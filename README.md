# Laboratorio opcional Docker-AWS.

Vamos a crear una imágen del proyecto para poder iniciar contenedores Docker a partir de ella.

## Descargar el directorio que contiene nuestro bundler de producción.

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

`node_modules

.vscode

dist

.editorconfig

.env

.env.example

.gitignore

package-lock.json

README.md`

## Continuamos la configuración de Dockerfile.

- Dentro del fichero Dockerfile damos la orden para instalar las dependencias dentro del contenedor.
  
  `RUN npm install`
  
- Le decimos que haga el build para que compile el proyecto creando la carpeta dist.

  `RUN npm run build`

## Creamos la imágen.
Escribimos el siguiente comando en el terminal (bash):
  `docker build -t my-laboratory-app:1`
Con ducker build damos crear la imágen y el tag -t sirve para darle el nombre que queramos (my-app). La versión se indica después 
de los dos puntos (:1). 

## Creamos el contenedor.

Escribimos el siguiente comando en el terminal de nuevo.

  `docker run -it my-laboratory-app:1 sh`
  
Estamos dando la orden de crear el contenedor a partir de la imágen que indicamos junto a la versión. Además, con el comando `sh` abrimos la consola bash dentro de nuestro
contendor creado. De esta manera podemos comprobar que se han creado los ficheros correctamente.

## Creamos el servidor web.

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

## Agregamos package.json al servidor web.

Escribimos `cd server` en el terminal para mover nuestro directorio a esa carpeta y trabajar en ella. 
Y a continuación el comando para crear el fichero package.json `npm init -y`.

## Añadimos express como dependencia de producción.

Sin salir del directorio server instalamos express como dependencia escribiendo el siguiente código en el terminal:

`npm install express --save`

Veremos que además de instalar express como dependencia de producción en nuestro fichero server/package.json, estamos creando la carpeta node_modules correspondiente.

## Comprobamos que el servidor express fucniona en local.

Compilamos el proyecto para crear la carpeta dist en local. Es necesario mover el directorio de la carpeta server al directorio principal del proyecto.
Para ello escribimos `cd ..` en el terminal.
Y a continuación el comando para hacer el compilado, `npm run build`.
Por último, para ejecutar el fichero index.js de nuestra carpeta server Node nos proporciona un comando para levantar el proyecto desde local `node server`.
Veremos que la consola nos informa con el siguiente texto: `App running on http://localhost:8081`.
Si abrimos el portal http://localhost:8081 en nuestro explorador veremos el proyecto levantado en local.

