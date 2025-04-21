# Custom OS image with Yocto and dlstreamer


## Instrucciones para correr el contenedor docker

### Para crear el contenedor:

```
docker compose up
```

### Para correr el contenedor con terminal interactiva:

```
docker compose run --rm dlstreamer
```

# Conclusiones

Se pudo integrar de forma satisfactoria OpenVno y GStreamer dentro del ecosistema de yocto, con lo cual se pudo realizar un pipeline dentro de la imagen con los elementos de Gstreamer usando un código python.

El uso de la herramienta de qemu para correr la imagen facilita la prueba de la misma una vez se haya terminado de cocinar.

La aplicacion completa se probó de forma satisfactoria dentro de un contenedor docker.

# Referencias:
[1] https://docs.openvino.ai/2024/get-started/install-openvino/install-openvino-yocto.html

[2] https://github.com/yoctoproject/poky

[3] https://gstreamer.freedesktop.org/

[4] https://dlstreamer.github.io/dev_guide/advanced_install/advanced_install_guide_index.html

[5] https://github.com/xavier2200/meta-myapp