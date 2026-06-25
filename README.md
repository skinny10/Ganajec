# GANAJEC — GanaVet AI

Plataforma móvil de predicción de enfermedades bovinas construida con Flutter.

---

## Stack tecnológico

| Capa            | Tecnología                                  |
| --------------- | ------------------------------------------- |
| Lenguaje        | Dart 3.x                                    |
| Framework       | Flutter                                     |
| Estado          | Provider + ChangeNotifier                   |
| Navegación      | GoRouter (declarativa, 2.0)                 |
| HTTP            | Dio (única instancia)                       |
| Almacenamiento  | shared_preferences                          |
| Gráficas        | fl_chart                                    |
| Fuentes         | Google Fonts (Roboto + Montserrat)          |
| Dev             | device_preview                              |

---

## Arquitectura

El proyecto sigue una **Clean Architecture** con 3 capas por feature:

```
presentation  →  domain  →  data
    UI/VM          usecases/entities     DTOs/datasources/repos
```

Cada funcionalidad vive dentro de `lib/features/<feature>/` con sus propias 3 subcapas. Las entidades compartidas entre features están en `lib/share/`.

---

## Estructura de directorios

```
lib/
├── main.dart                         # Punto de entrada, inicializa TokenStorage
├── app.dart                          # Widget raíz: MultiProvider + MaterialApp.router
│
├── core/                             # Infraestructura compartida
│   ├── constants/
│   │   ├── api_constants.dart        # URLs y endpoints de la API
│   │   └── app_strings.dart          # Textos centralizados (UI labels, validaciones)
│   ├── network/
│   │   ├── api_client.dart           # Instancia singleton de Dio
│   │   ├── auth_interceptor.dart     # Interceptor para adjuntar token JWT
│   │   └── token_storage.dart        # Read/write de token con SharedPreferences
│   ├── providers/
│   │   ├── auth_providers.dart       # Providers del feature auth
│   │   └── ganadero_providers.dart   # Providers del feature ganadero
│   ├── router/
│   │   ├── app_router.dart           # Definición de rutas con GoRouter
│   │   └── home_refresh_observer.dart # Observer para refrescar home al navegar
│   └── theme/
│       ├── app_theme.dart            # Tema light/dark con estilos globales
│       ├── theme.dart                # Esquemas de color generados (Material 3)
│       └── util.dart                 # Utilidades de tipografía
│
├── features/
│   ├── auth/                         # Autenticación (login, register, logout)
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_ds.dart       # Mock API de auth
│   │   │   ├── models/
│   │   │   │   └── user_model.dart            # DTO de usuario
│   │   │   └── repositories/
│   │   │       └── auth_repo_impl.dart        # Implementación del repositorio
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart                  # Entidad Usuario
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart       # Contrato abstracto
│   │   │   └── usecase/
│   │   │       ├── login_usecase.dart
│   │   │       ├── logout_usecase.dart
│   │   │       └── register_usecase.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── login/
│   │       │   │   ├── login_screen.dart
│   │       │   │   └── login_components.dart  # Form fields + botones de login
│   │       │   └── register/
│   │       │       ├── register_screen.dart
│   │       │       └── register_components.dart # Form fields + selector de rol
│   │       ├── viewmodels/
│   │       │   └── auth_viewmodel.dart        # Estado: idle/loading/success/error
│   │       └── widgets/
│   │           ├── auth_button.dart
│   │           ├── auth_error_text.dart
│   │           ├── auth_role_card.dart
│   │           └── auth_text_field.dart
│   │
│   ├── ganadero/                    # Funcionalidad principal (ganadero/ dueño)
│   │   ├── data/
│   │   │   ├── datasource/
│   │   │   │   └── ganadero_remote_ds.dart    # Mock API de bovinos
│   │   │   ├── models/
│   │   │   │   ├── alerta_model.dart
│   │   │   │   ├── animal_model.dart
│   │   │   │   ├── historial_item_model.dart
│   │   │   │   ├── historial_productivo_model.dart
│   │   │   │   └── prediccion_model.dart
│   │   │   └── repositories/
│   │   │       └── ganadero_repo_impl.dart
│   │   ├── domain/
│   │   │   ├── repositories/
│   │   │   │   └── ganadero_repository.dart
│   │   │   └── usecase/                      # 13 casos de uso
│   │   │       ├── actualizar_animal_usecase.dart
│   │   │       ├── crear_animal_usecase.dart
│   │   │       ├── eliminar_animal_usecase.dart
│   │   │       ├── get_alertas_usecase.dart
│   │   │       ├── get_animales_usecase.dart
│   │   │       ├── get_historial_animal_usecase.dart
│   │   │       ├── get_historial_ganadero_usecase.dart
│   │   │       ├── get_predicciones_animal_usecase.dart
│   │   │       ├── get_predicciones_usecase.dart
│   │   │       ├── marcar_alerta_leida_usecase.dart
│   │   │       ├── marcar_todas_alertas_leidas_usecase.dart
│   │   │       └── registrar_sintomas_usecase.dart
│   │   └── presentation/
│   │       ├── screens/                      # 16 pantallas
│   │       │   ├── alertas/
│   │       │   │   ├── alertas_screen.dart
│   │       │   │   └── alertas_components.dart
│   │       │   ├── cambiar_contrasena/
│   │       │   │   └── cambiar_contrasena_screen.dart
│   │       │   ├── colegas/
│   │       │   │   └── colegas_screen.dart
│   │       │   ├── detalle_bovino/
│   │       │   │   ├── detalle_bovino_screen.dart
│   │       │   │   └── detalle_bovino_components.dart
│   │       │   ├── editar_bovino/
│   │       │   │   ├── editar_bovino_screen.dart
│   │       │   │   └── editar_bovino_components.dart
│   │       │   ├── editar_perfil/
│   │       │   │   └── editar_perfil_screen.dart
│   │       │   ├── editar_rancho/
│   │       │   │   └── editar_rancho_screen.dart
│   │       │   ├── historial/
│   │       │   │   ├── historial_screen.dart
│   │       │   │   └── historial_components.dart
│   │       │   ├── historial_dueno/
│   │       │   │   └── historial_dueno_screen.dart
│   │       │   ├── home/
│   │       │   │   ├── home_screen.dart
│   │       │   │   └── home_components.dart
│   │       │   ├── mis_ganaderos/
│   │       │   │   └── mis_ganaderos_screen.dart
│   │       │   ├── perfil/
│   │       │   │   ├── perfil_screen.dart
│   │       │   │   └── perfil_components.dart
│   │       │   ├── rancho_dashboard/
│   │       │   │   └── rancho_dashboard_screen.dart
│   │       │   ├── registrar_ganadero/
│   │       │   │   └── registrar_ganadero_screen.dart
│   │       │   ├── registrar_sintomas/
│   │       │   │   ├── registrar_sintomas_screen.dart
│   │       │   │   └── registrar_sintomas_components.dart
│   │       │   ├── registro_bovino/
│   │       │   │   ├── registro_bovino_screen.dart
│   │       │   │   └── registro_bovino_components.dart
│   │       │   └── resultado_prediccion/
│   │       │       ├── resultado_prediccion_screen.dart
│   │       │       ├── resultado_prediccion_components.dart
│   │       │       └── resultado_prediccion_args.dart
│   │       ├── viewmodels/                   # 17 ViewModels
│   │       │   ├── alertas_viewmodel.dart
│   │       │   ├── cambiar_contrasena_viewmodel.dart
│   │       │   ├── colegas_viewmodel.dart
│   │       │   ├── detalle_bovino_viewmodel.dart
│   │       │   ├── editar_bovino_viewmodel.dart
│   │       │   ├── editar_perfil_viewmodel.dart
│   │       │   ├── editar_rancho_viewmodel.dart
│   │       │   ├── historial_dueno_viewmodel.dart
│   │       │   ├── historial_viewmodel.dart
│   │       │   ├── home_viewmodel.dart
│   │       │   ├── mis_ganaderos_viewmodel.dart
│   │       │   ├── perfil_viewmodel.dart
│   │       │   ├── rancho_dashboard_viewmodel.dart
│   │       │   ├── rancho_modal_viewmodel.dart
│   │       │   ├── registrar_ganadero_viewmodel.dart
│   │       │   ├── registrar_sintomas_viewmodel.dart
│   │       │   └── registro_bovino_viewmodel.dart
│   │       └── widgets/                      # Widgets reutilizables
│   │           ├── alerta_banner.dart
│   │           ├── animal_list_tile.dart
│   │           ├── prediccion_tile.dart
│   │           ├── rancho_modal.dart
│   │           └── resumen_card.dart
│   │
│   └── suscripcion/                # Planes y suscripciones
│       ├── data/
│       │   ├── datasource/
│       │   │   └── suscripcion_remote_ds.dart
│       │   ├── models/
│       │   │   └── suscripcion_model.dart
│       │   └── repositories/
│       │       └── suscripcion_repo_impl.dart
│       ├── domain/
│       │   ├── repositories/
│       │   │   └── suscripcion_repository.dart
│       │   └── usecase/
│       │       ├── get_planes_usecase.dart
│       │       ├── get_suscripcion_usecase.dart
│       │       └── suscribirse_usecase.dart
│       └── presentation/
│           ├── screens/
│           │   ├── elegir_plan/
│           │   │   ├── elegir_plan_screen.dart
│           │   │   └── elegir_plan_components.dart
│           │   └── mi_plan/
│           │       ├── mi_plan_screen.dart
│           │       └── mi_plan_components.dart
│           └── viewmodels/
│               ├── elegir_plan_viewmodel.dart
│               └── mi_plan_viewmodel.dart
│
└── share/                          # Entidades y contratos compartidos
    └── domain/
        ├── entities/
        │   ├── alerta.dart
        │   ├── animal.dart
        │   ├── historial_item.dart
        │   ├── historial_productivo.dart
        │   ├── plan.dart
        │   ├── prediccion.dart
        │   ├── rancho.dart
        │   ├── registro_sintomas.dart
        │   └── suscripcion_info.dart
        └── repositories/
            └── animal_repository.dart

assets/
└── images/
    ├── fondo.png
    ├── footer.png
    ├── icon.png
    └── vaca.png
```

---

## Features

### Auth (`lib/features/auth/`)
- Login, registro y logout con estados idle/loading/success/error.
- Validación de formularios con mensajes desde `AppStrings`.
- Roles: `ganadero` y `dueno`.
- Datasource mock (reemplazable por API real).

### Ganadero (`lib/features/ganadero/`)
- **Home**: resumen del rancho con cards de bovinos, alertas y KPIs.
- **Registro de bovinos**: formulario con nombre, arete, categoría, propósito, raza, edad, peso.
- **Detalle de bovino**: info del animal, historial productivo y predicciones.
- **Editar/Eliminar bovino**: modificar datos o eliminar un animal.
- **Registro de síntomas**: formulario para reportar síntomas y obtener predicción.
- **Resultado de predicción**: visualización del diagnóstico generado por IA.
- **Alertas**: listado de notificaciones con marcado de leídas.
- **Historial**: registro histórico de actividad del rancho.
- **Perfil**: configuración de usuario, cambio de contraseña.
- **Dashboard de rancho**: vista ejecutiva para dueños con KPIs globales.
- **Gestión de ganaderos**: dueños pueden registrar y gestionar ganaderos.

### Suscripción (`lib/features/suscripcion/`)
- Planes: básico, premium, enterprise.
- Vista del plan actual y selector para cambiar/cancelar plan.

---

## Convenciones

- **Separación de UI y lógica**: cada pantalla tiene un archivo `*_components.dart` para los widgets del formulario.
- **Textos centralizados**: todas las cadenas visibles al usuario están en `core/constants/app_strings.dart`.
- **Estados de ViewModel**: cada ViewModel expone un enum con `idle`, `loading`, `success`, `error`.
- **Inyección de dependencias manual**: los providers se construyen en `auth_providers.dart` y `ganadero_providers.dart` y se inyectan via `MultiProvider` en `app.dart`.
- **Navegación**: GoRouter con rutas definidas en `AppRoutes` (constantes) y construidas en `AppRouter.router`. Los parámetros se pasan vía `state.extra`.
- **Mocks**: los datasources (`*_remote_ds.dart`) actualmente retornan datos mock con `Future.delayed`. Para conectar a backend real se reemplaza la implementación interna.

---

## Cómo empezar

```bash
# Dependencias
flutter pub get

# Ejecutar en modo debug
flutter run
```

Para más información sobre el flujo de autenticación, registro de bovinos y predicción, revisa la documentación en las carpetas `lib/features/auth/` y `lib/features/ganadero/`.
