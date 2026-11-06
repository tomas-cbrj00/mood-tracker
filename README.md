# Mood — aplicación móvil

Prototipo funcional en Flutter para registrar el estado de ánimo y acompañar
el autocuidado con actividades breves. La interfaz toma como referencia el
[diseño de Figma](https://www.figma.com/design/aG5plTvtxxSFyPWDCG3ZPj/Aplicacion-Movil-mood?node-id=12-598).

## Ejecutar

```powershell
flutter pub get
flutter run
```

Para una vista previa en el navegador:

```powershell
flutter run -d chrome
```

## Comprobar

```powershell
flutter analyze
flutter test
```

## Alcance actual

- Perfil local con nombre.
- Registro de ánimo con nota opcional.
- Actividades de autocuidado, incluida respiración guiada con temporizador.
- Historial con resumen visual de los últimos siete días.
- Datos almacenados en el dispositivo mediante `shared_preferences`.

El documento de avance está en [`docs/avance_proyecto.md`](docs/avance_proyecto.md).
