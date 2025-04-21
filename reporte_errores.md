# Registro de Errores y Soluciones

## Errores relacionados con Docker

### Error 1: Comando `omz_downloader` no encontrado
**Error:**
```
ERROR [dlstreamer 6/6] RUN mkdir models && cd models && omz_downloader --name person-vehicle-bike-detection-2004 --precisions FP32
/bin/bash: line 1: omz_downloader: command not found
```

**Solución:** 
El error ocurre porque el utilitario `omz_downloader` no estaba disponible en la imagen base. Aseguramos que la versión correcta de la imagen base de Intel dlstreamer fuera utilizada y corrigimos la sintaxis de la instalación de modelos.

### Error 2: Error de sintaxis en Dockerfile
**Error:**
```
syntax error: unexpected end of file
```

**Solución:** 
Corregimos un error de sintaxis en el comando RUN para descargar múltiples modelos, asegurando que cada comando esté separado por `&&` y eliminando cualquier `&&` sobrante al final.

### Error 3: Error de variable de entorno XDG_RUNTIME_DIR
**Error:**
```
error: XDG_RUNTIME_DIR not set in the environment
```

**Solución:** 
Agregamos la variable de entorno a docker-compose.yaml:

```yaml
environment:
  - XDG_RUNTIME_DIR=/tmp
  - DISPLAY=${DISPLAY}
```

### Error 4: Error de modelo no encontrado
**Error:**
```
module gvaclassify1 reported: 'model' does not exist
```

**Solución:** 
Verificamos las rutas de los modelos y aseguramos que los modelos existieran en las ubicaciones correctas dentro del contenedor:

```python
MODELS_PATH="/home/dlstreamer/models"
DETECTION_MODEL=f"{MODELS_PATH}/intel/{MODEL_1}/FP32/{MODEL_1}.xml"
```

### Error 5: Error tipográfico en docker-compose.yaml
**Error:**
```
validating compose.yaml: services.dlstreamer Additional property enviroment is not allowed
```

**Solución:** 
Corregimos el error ortográfico, cambiando `enviroment` por `environment`.

### Error 6: Error de visualización en entorno no-Jupyter
**Error:**
```
AttributeError: 'NoneType' object has no attribute 'update'
```

**Solución:** 
Modificamos el código para no depender de widgets de Jupyter cuando se ejecuta en una terminal, utilizando un enfoque basado en threads con OpenCV.

### Error 7: Error de OpenCV sin soporte GUI
**Error:**
```
OpenCV(4.7.0) /home/dlstreamer/opencv/modules/highgui/src/window.cpp:1255: error: (-2:Unspecified error) The function is not implemented. Rebuild the library with Windows, GTK+ 2.x or Cocoa support.
```

**Solución:** 
Adaptamos el código para funcionar sin ventanas GUI, dado que OpenCV fue compilado sin soporte para interfaces gráficas.

### Error 8: Error de plugins GStreamer faltantes
**Error:**
```
GStreamer warning: your GStreamer installation is missing a required plugin
```

**Solución:** 
Instalamos los plugins necesarios de GStreamer:

```bash
apt-get update && apt-get install -y gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav
```

### Error 9: Error de fuente de video (v4l2src0)
**Error:**
```
module v4l2src0 reported: Internal data stream error
```

**Solución:** 
El pipeline estaba intentando usar una cámara (v4l2src) cuando debería usar una fuente de URL. Creamos un pipeline simplificado para pruebas y verificamos la accesibilidad de las fuentes de video.

## Errores relacionados con Yocto

### Error 2: Falta de imagen initramfs para ISO
**Error reportado:**
```
WARNING: core-image-minimal-1.0-r0 do_bootimg: ISO image will not be created. /home/xavier/project_1_yocto/build/tmp/deploy/images/qemux86-64/core-image-minimal-initramfs-qemux86-64.cpio.gz is invalid.
```

**Solución:**
La construcción está intentando crear una imagen ISO que incluye un initramfs, pero el archivo initramfs está faltando o es inválido.

**Comandos para corregir:**
```bash
# Limpiar ambas imágenes
bitbake -c cleanall core-image-minimal
bitbake -c cleanall core-image-minimal-initramfs

# Reconstruir ambas
bitbake core-image-minimal-initramfs
bitbake core-image-minimal
```

### Error 3: Problemas con GStreamer en QEMU (X11)
**Error reportado:**
```
root@qemux86-64:~# gst-launch-1.0 videotestsrc ! videoconvert ! autovideosink
** (gst-plugin-scanner:358): CRITICAL **: 19:51:23.496: Couldn't g_module_open libpython. Reason: /usr/lib/libpython3.12.so: cannot open shared object file: No such file or directory
Setting pipeline to PAUSED ...
error: XDG_RUNTIME_DIR is invalid or not set in the environment.
error: XDG_RUNTIME_DIR is invalid or not set in the environment.
Pipeline is PREROLLING ...
WARNING: from element /GstPipeline:pipeline0/GstAutoVideoSink:autovideosink0: Could not initialise Xv output
Additional debug info:
/usr/src/debug/gstreamer1.0-plugins-base/1.22.12/sys/xvimage/xvimagesink.c(1944): gst_xv_image_sink_open (): /GstXvImageSink:autovideosink0-actual-sink-xvimage:
Could not open display (null)
```

**Solución:**
Problemas con X11 forwarding en SSH y falta de librerías Python.

**Correcciones:**
- Configurar variables de entorno:
```bash
export XDG_RUNTIME_DIR=/tmp
export DISPLAY=:0
```

- Añadir a local.conf para soporte X11:
```
IMAGE_INSTALL:append = " openssh openssh-sshd openssh-sftp openssh-sftp-server xauth"
```

### Error 4: Configuración automática de X11 Forwarding
**Error reportado:**
Solicitud para configurar automáticamente X11 forwarding en sshd_config

**Solución:**
Crear un archivo bbappend para openssh.

**Implementación:**

1. Crear estructura de directorios:
```bash
mkdir -p meta-custom/recipes-connectivity/openssh/
```

2. Crear archivo bbappend:
```bash
touch meta-custom/recipes-connectivity/openssh/openssh_%.bbappend
```

3. Editar el archivo con:
```
do_install_append() {
    sed -i 's/#X11Forwarding no/X11Forwarding yes/' ${D}${sysconfdir}/ssh/sshd_config
    sed -i 's/#X11DisplayOffset 10/X11DisplayOffset 10/' ${D}${sysconfdir}/ssh/sshd_config
    sed -i 's/#X11UseLocalhost yes/X11UseLocalhost no/' ${D}${sysconfdir}/ssh/sshd_config
}
```

### Error 5: PACKAGECONFIG inválido para openssh
**Error reportado:**
```
WARNING: openssh-9.6p1-r0 do_configure: QA Issue: openssh: invalid PACKAGECONFIG: x11 [invalid-packageconfig]
```

**Solución:**
La opción PACKAGECONFIG "x11" no existe para openssh en la versión actual. Se debe usar el enfoque bbappend en su lugar.

### Error 6: Instalación de dlstreamer
**Error reportado:**
Solicitud para instalar dlstreamer

**Solución:**
Crear una capa y receta personalizada para dlstreamer.

**Pasos:**

1. Crear capa personalizada:
```bash
bitbake-layers create-layer ../meta-dlstreamer
bitbake-layers add-layer ../meta-dlstreamer
```

2. Crear estructura de receta:
```bash
mkdir -p ../meta-dlstreamer/recipes-multimedia/dlstreamer
```

3. Crear archivo de receta:
```bash
touch ../meta-dlstreamer/recipes-multimedia/dlstreamer/dlstreamer_1.0.bb
```

4. Contenido de la receta:
```
SUMMARY = "Deep Learning Streamer (DL Streamer)"
DESCRIPTION = "Intel Deep Learning Streamer is a streaming media analytics framework based on GStreamer"
HOMEPAGE = "https://github.com/openvinotoolkit/dlstreamer"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=f39eac9f4573be5b012e8313831e72e9"

SRC_URI = "git://github.com/openvinotoolkit/dlstreamer.git;protocol=https;branch=master"
SRCREV = "${AUTOREV}"

S = "${WORKDIR}/git"

DEPENDS = "gstreamer1.0 gstreamer1.0-plugins-base openvino opencv"

inherit cmake pkgconfig

EXTRA_OECMAKE = "-DBUILD_SHARED_LIBS=ON -DBUILD_TESTS=OFF"

FILES:${PN} += "${libdir}/gstreamer-1.0/*.so"
FILES:${PN}-dev += "${libdir}/gstreamer-1.0/*.la"
FILES:${PN}-dbg += "${libdir}/gstreamer-1.0/.debug"
```

5. Actualizar local.conf:
```
IMAGE_INSTALL:append = " dlstreamer"
```

6. Construir:
```bash
bitbake dlstreamer
bitbake core-image-minimal
```

## Errores específicos al compilar DLStreamer en Yocto

### Error 7: Línea malformada en la receta de DLStreamer
**Error reportado:**
```bitbake
SRC_URI = SRC_URI = "file://dlstreamer"
```

**Solución:**
Corregir la duplicación en la línea:
```bitbake
SRC_URI = "file://dlstreamer"
```

### Error 8: CMakeLists.txt no encontrado
**Error reportado:**
```text
CMake Error: The source directory ".../dlstreamer/1.0/git" does not appear to contain CMakeLists.txt.
```

**Solución:**
Al usar código local en lugar de Git, es necesario corregir la ruta de origen:

```bitbake
# Cambiar esto:
S = "${WORKDIR}/git"

# Por esto:
S = "${WORKDIR}/dlstreamer"
```

**Importante:** Asegurar que el código fuente esté en la ubicación correcta:
```
meta-myapp/recipes-example/dlstreamer/dlstreamer/CMakeLists.txt
```

### Error 9: OpenCV no encontrado
**Error reportado:**
```text
Could not find a package configuration file provided by "OpenCV"
```

**Soluciones:**

**Opción A:** Incluir OpenCV en la receta
```bitbake
DEPENDS = "gstreamer1.0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good cmake python3 opencv"
```

**Nota:** Verificar que `meta-openembedded/meta-oe` esté incluido en `bblayers.conf`.

**Opción B:** Desactivar el uso de OpenCV
```bitbake
EXTRA_OECMAKE = "    -DCMAKE_INSTALL_PREFIX=${prefix}     -DCMAKE_BUILD_TYPE=Release     -DBUILD_PYTHON_BINDINGS=OFF     -DENABLE_OPENCV=OFF "
```

### Consejos adicionales para la compilación de DLStreamer

- Revisar la receta con `cat -n` para detectar errores de sintaxis.
- Verificar que los archivos `CMakeLists.txt` estén presentes en `${S}`.
- Para calcular el `md5sum` de `LICENSE`:
  ```bash
  md5sum meta-myapp/recipes-example/dlstreamer/dlstreamer/LICENSE
  ```

- Comando para compilar:
  ```bash
  bitbake dlstreamer
  ```

Al final no se logró compilar DLstreamer