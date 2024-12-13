# Dog API Flutter App

Este proyecto es una aplicación en Flutter que permite buscar imágenes de perros según su raza. Utiliza la API de [Dog CEO](https://dog.ceo/dog-api/) para obtener las razas de perros y sus imágenes aleatorias.

## Características

- Muestra una lista desplegable con las razas de perros.
- Permite seleccionar una raza y mostrar una imagen aleatoria del perro seleccionado.
- Maneja errores al cargar las imágenes y muestra un mensaje adecuado si no se puede obtener la imagen.

## Actividades

### Actividad 1: Obtener una imagen de un perro por raza

Se utiliza el endpoint de la API de Dog CEO para obtener una imagen aleatoria de un perro según la raza seleccionada. Se muestra la imagen en la interfaz de usuario.

- **Endpoint para obtener la imagen aleatoria de un perro por raza**:
https://dog.ceo/api/breed/<raza>/images/random

markdown
Copiar código
Donde `<raza>` es el nombre de la raza seleccionada.

### Actividad 2: Listar todas las razas de perros

La aplicación realiza una llamada a la API para obtener la lista de todas las razas de perros y mostrarlas en un menú desplegable.

- **Endpoint para obtener la lista de razas**:
https://dog.ceo/api/breeds/list/all

## Captura de la aplicación
![Captura Pokemon](img/pokemonapp1.png)
![Captura Pokemon](img/pokemonapp.png)
![Captura ApiDog](img/dogap1.png)
![Captura ApiDog](img/dogapi.png)


## Requisitos

Para ejecutar esta aplicación, necesitas tener instalado:

- [Flutter](https://flutter.dev/docs/get-started/install)
- [Dart](https://dart.dev/get-dart)

## Autor
Erick Caiza
Francisco Caero