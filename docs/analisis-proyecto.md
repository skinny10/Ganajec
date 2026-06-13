# Análisis del Proyecto — GanaVet AI

## 1. Ramas Git

| Rama | Descripción |
|------|-------------|
| `master` | Principal |
| `remotes/origin/rancher` | Rama remota para el rol de ganadero (ranch hand) |

Solo existe la rama `master` en local.

---

## 2. Estructura Completa de `lib/`

```
lib/
├── main.dart
├── app.dart                              # MultiProvider + MaterialApp.router
├── core/
│   ├── constants/app_strings.dart
│   ├── providers/
│   │   ├── auth_providers.dart           # DI del módulo auth
│   │   └── ganadero_providers.dart       # DI del módulo ganadero
│   ├── router/app_router.dart            # Config GoRouter
│   └── theme/
│       ├── app_theme.dart                # Tema light/dark + inputs/buttons
│       ├── theme.dart                    # MaterialTheme (color schemes)
│       └── util.dart                     # Google Fonts helper
├── features/
│   ├── auth/                             # Clean Architecture
│   │   ├── data/
│   │   │   ├── datasources/auth_remote_ds.dart
│   │   │   ├── models/user_model.dart
│   │   │   └── repositories/auth_repo_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/user.dart        # {id, name, email, role}
│   │   │   ├── repositories/auth_repository.dart
│   │   │   └── usecase/ (login, logout, register)
│   │   └── presentation/
│   │       ├── screens/login/ (login_screen, login_components)
│   │       ├── screens/register/ (register_screen, register_components)
│   │       ├── viewmodels/auth_viewmodel.dart
│   │       └── widgets/ (auth_button, auth_error_text, auth_role_card, auth_text_field)
│   └── ganadero/                         # Clean Architecture
│       ├── data/
│       │   ├── datasource/ganadero_remote_ds.dart
│       │   └── models/ (alerta_model, animal_model, historial_productivo_model, prediccion_model)
│       ├── domain/
│       │   ├── repositories/ganadero_repository.dart
│       │   └── usecase/ (crear_animal, get_alertas, get_animales, get_predicciones)
│       └── presentation/
│           ├── screens/home/ (home_screen, home_components)
│           ├── screens/registro_bovino/ (registro_bovino_screen, registro_bovino_components)
│           ├── viewmodels/ (home_viewmodel, registro_bovino_viewmodel)
│           └── widgets/ (alerta_banner, animal_list_tile, prediccion_tile, resumen_card)
└── share/
    └── domain/entities/ (alerta, animal, historial_productivo, prediccion, rancho)
```

---

## 3. Rutas (GoRouter)

| Ruta | Pantalla | Creada |
|------|----------|--------|
| `/login` | `LoginScreen` | ✅ |
| `/register` | `RegisterScreen` | ✅ |
| `/home` | `HomeScreen` (ganadero) | ✅ |
| `/registro-bovino` | `RegistroBovinoScreen` | ✅ |
| *Dashboard dueño* | ❌ No existe aún |

La app inicia en `/login` y no hay **redirect por rol** — cualquier usuario logueado ve el mismo `HomeScreen`.

---

## 4. Colores (MaterialTheme)

Basados en semillas **marrón/café** (`#805611`) con tonos tierra:

| Variable | Light | Dark |
|----------|-------|------|
| `primary` | `#805611` (ocre) | `#F6BC6F` (dorado) |
| `primaryContainer` | `#FFDDB5` | `#633F00` |
| `secondary` | `#705B40` | `#DEC2A2` |
| `tertiary` | `#52643F` (verde) | `#B9CDA0` |
| `error` | `#BA1A1A` | `#FFB4AB` |
| `surface` | `#FFF8F4` | `#18120B` |
| Botón primario | `#4A2C0A` fijo (hardcoded) | — |

Usa **Roboto** para cuerpo y **Montserrat** para títulos (Google Fonts).

---

## 5. Lo que ya está construido

- **Auth completo**: Login/Register con selección de rol, 3 use cases, repo remoto
- **Entidad `User`** con campo `role` (string) — soporta múltiples roles
- **HomeScreen del ganadero**: resumen, alertas, mi hato, predicciones, bottom nav con 5 tabs
- **Registro de bovino**: formulario completo
- **Entity `Rancho`**: `{id, nombre, municipio, estado, duenoId, creadoEn}`
- **Tema**: light + dark mode con Material Design 3
- **DevicePreview** habilitado en desarrollo

---

## 6. Lo que necesitas saber antes de crear la rama del dashboard del dueño

1. **Rama sugerida**: `feature/dashboard-dueno` (basada en `master`)
2. **Rol de dueño (`owner`)**: El `User.role` ya existe como string, pero **no hay lógica de ruteo por rol** — deberás agregar un redirect en `app_router.dart` que lleve al `/home` original o a un nuevo `/dashboard-dueno` según `role`.
3. **HomeScreen actual** está hardcodeado para ganadero (nombre "Juan Pérez", tabs específicos). El dueño necesita su propio dashboard con:
   - Resumen de múltiples ranchos (tiene `duenoId` en `Rancho`)
   - KPIs globales (animales totales, alertas, predicciones)
   - Lista de ranchos con acceso rápido
4. **Ya existe `Rancho`** en `share/domain/entities/` — puedes reusarlo.
5. **No hay endpoint/API** para dashboard de dueño aún (solo existe `GanaderoRemoteDataSource`). Necesitarás crear un nuevo feature `dueño/` o extender el existente.
6. **Estilo**: Respeta los colores del tema (`colorScheme.primary`, etc.) y no hardcodees colores como el `#4A2C0A` del botón.
7. **Patrón**: Sigue la misma Clean Architecture del feature `ganadero` → `data/`, `domain/`, `presentation/`.
8. **Providers**: Agrégate al `MultiProvider` en `app.dart` y crea tu propio archivo de providers.
