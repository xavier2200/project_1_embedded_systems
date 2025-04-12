# Tutorial para crear las receta para cocinar imagen personalizada usando yocto

### Recetas:

 - Clonamos el repo de poky y usamos la version deseada con el siguiente comando:

``` git clone https://git.yoctoproject.org/git/poky && git checkout -t origin/scarthgap -b my-scarthgap```

- Clonamos los repos que contienen las capas dentro del repo de Poky:

``` git clone https://git.yoctoproject.org/meta-intel```

```git clone https://git.openembedded.org/meta-openembedded```

```git clone https://github.com/kraj/meta-clang.git```

- Ahora dentro de cada uno de los repositorios clonados hay que cambiarlos a la version de yocto que se est'a usando usamos el commando:

```git checkout -t origin/scarthgap -b my-scarthgap```

- La imagen corrio bien pero no tiene los paquetes:
![image](./figuras/error_no_packages.png)

- Ese error no tiene sentido porque el comando se corre en el host machine se puede observar que corre con exito
![image](./figuras/pack_host.png)