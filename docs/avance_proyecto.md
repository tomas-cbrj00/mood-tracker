# Avance del proyecto: Mood

## Resumen

Mood es un prototipo móvil para apoyar el reconocimiento cotidiano de las
emociones. La aplicación permite registrar cómo se siente la persona, acompañar
el registro con una nota privada y consultar su evolución. La interfaz sigue
como referencia visual el [prototipo de Figma](https://www.figma.com/design/aG5plTvtxxSFyPWDCG3ZPj/Aplicacion-Movil-mood?node-id=12-598).

## Objetivo del avance

Contar con una primera versión ejecutable que permita recorrer los flujos
principales de la aplicación y conservar los datos entre aperturas en el mismo
dispositivo.

## Requisitos funcionales implementados

1. Crear un perfil local indicando el nombre de la persona.
2. Elegir entre cinco estados de ánimo y guardar un registro con fecha y hora.
3. Añadir una nota opcional de hasta 240 caracteres al registro.
4. Consultar el historial de registros y una gráfica resumen de los últimos
   siete días.
5. Realizar actividades de autocuidado: respiración guiada de tres minutos,
   diario de gratitud, pausa sin pantalla e hidratación.
6. Consultar las actividades completadas recientemente.
7. Eliminar el perfil y los registros guardados desde la pantalla de perfil.

## Requisitos no funcionales considerados

- Interfaz en español, adaptable a pantallas móviles y a una vista previa web.
- Navegación inferior entre Inicio, Actividades, Historial y Perfil.
- Persistencia local; la versión actual no envía notas ni datos personales a
  un servidor.
- Mensajes visibles cuando falla la lectura o escritura de los datos.

## Flujo principal

1. La persona escribe su nombre y crea el perfil local.
2. En Inicio elige cómo se siente y, si desea, escribe una nota.
3. La aplicación guarda el registro y confirma la acción.
4. En Historial puede consultar los registros y el resumen semanal.
5. En Actividades puede completar ejercicios y revisar las actividades recientes.

## Diseño técnico

- **Tecnología:** Flutter y Dart.
- **Estructura:** `lib/main.dart` inicializa la persistencia; `lib/mood_app.dart`
  contiene las pantallas y navegación; `lib/models/mood_entry.dart` define los
  estados y registros de ánimo; `lib/data/mood_repository.dart` centraliza el
  acceso a datos.
- **Persistencia:** `shared_preferences` con registros serializados en JSON.
- **Plataformas configuradas:** Android y web (la web se usa como vista previa
  para desarrollo).

## Estado y siguientes pasos

La primera versión funcional está implementada y cuenta con pruebas de widget
para el alta del perfil y el registro de ánimo con consulta en el historial.
También se generaron compilaciones de vista previa web y un APK Android de
depuración en `build/app/outputs/flutter-apk/app-debug.apk`.

Como siguiente etapa se recomienda validar la interfaz con el equipo y en un
dispositivo Android, agregar edición/borrado individual de registros y definir
si el proyecto requiere autenticación o sincronización con un servidor.

## Ejecución y validación

Desde la carpeta del proyecto:

```powershell
flutter pub get
flutter run
flutter run -d chrome
flutter analyze
flutter test
flutter build apk --debug
```

La construcción para Android requiere tener aceptadas las licencias del SDK de
Android (`flutter doctor --android-licenses`) y un dispositivo o emulador
disponible.
