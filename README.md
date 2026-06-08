# ganajec

Documentación de la capa de autenticación (`auth`)

## Visión general

La implementación de autenticación (`auth`) en este proyecto sigue una arquitectura limpia con separación entre:

- `presentation`: UI y lógica de interacción (pantallas, widgets, ViewModel)
- `domain`: casos de uso y contratos de repositorio
- `data`: acceso a datos y modelos

Además, las cadenas de texto de esta capa están centralizadas en `lib/core/constants/app_strings.dart` para facilitar mantenimiento y traducción.

## Estructura principal de `auth`

### Carpetas clave

- `lib/features/auth/presentation`: contiene pantallas, widgets y `AuthViewModel`
- `lib/features/auth/domain`: contiene entidades, casos de uso y repositorios abstractos
- `lib/features/auth/data`: contiene modelos, datasource y repositorio concreto

## Flujo de login

1. `lib/core/router/app_router.dart` define la ruta `/login` que muestra `LoginScreen`.
2. `LoginScreen` usa un `Form` y `GlobalKey<FormState>` para validar:
   - correo electrónico
   - contraseña
3. Los campos usan validación con mensajes de `AppStrings`.
4. Cuando el formulario es válido, se llama a `_onLogin()`:
   - se obtiene `AuthViewModel` desde `Provider`
   - se ejecuta `vm.login(email: ..., password: ...)`
5. `AuthViewModel.login()` cambia el estado a `loading`, invoca `LoginUseCase`, guarda el usuario y actualiza el estado a `success` o `error`.
6. Si el login es exitoso, `LoginScreen` navega a `/home`.

## Flujo de registro

1. `app_router.dart` define la ruta `/register` que muestra `RegisterScreen`.
2. `RegisterScreen` usa un `Form` y valida:
   - nombre completo
   - correo electrónico
   - contraseña
   - confirmación de contraseña
   - selección de rol (`ganadero` por defecto)
3. Los mensajes de validación también vienen de `AppStrings`.
4. Al validar y enviar, `_onRegister()` llama a `vm.register(...)`.
5. `AuthViewModel.register()` cambia el estado a `loading`, ejecuta `RegisterUseCase` y actualiza el estado.
6. Si el registro es exitoso, también navega a `/home`.

## Componentes de pantalla: `login_components.dart` y `register_components.dart`

Estas dos clases separan la UI de los formularios del propio `LoginScreen` y `RegisterScreen`. Esto hace que la pantalla sea más limpia y facilita la reutilización y prueba de los campos.

### `login_components.dart`

- `LoginFormFields`
  - Define los campos de formulario de login.
  - Usa `AuthTextField` para el correo y la contraseña.
  - Valida con `AppStrings`:
    - correo requerido
    - correo válido
    - contraseña requerida
    - contraseña mínima de 6 caracteres
  - Incluye control de visibilidad de contraseña con `onTogglePassword`.
  - Añade el checkbox `Recuérdame` y un botón de "¿Olvidaste tu contraseña?".

- `LoginActions`
  - Muestra el error si `errorMessage` no es nulo usando `AuthErrorText`.
  - Renderiza el botón principal `AuthButton` con la etiqueta `AppStrings.loginButton`.
  - Tiene un botón secundario para ir a registro con `onGoRegister`.
  - Recibe `isLoading` para mostrar el estado de carga.

### `register_components.dart`

- `RegisterFormFields`
  - Define los campos de formulario de registro.
  - Usa `AuthTextField` para:
    - nombre completo
    - correo electrónico
    - contraseña
    - confirmar contraseña
  - Valida con `AppStrings`:
    - nombre requerido
    - correo requerido y válido
    - contraseña requerida y largo mínimo
    - confirmación igual a la contraseña
  - Permite alternar visibilidad de `password` y `confirm password`.

- `RegisterRoleSelector`
  - Muestra opciones de rol con `AuthRoleCard`.
  - Tiene un arreglo interno `_roles` con:
    - `ganadero`
    - `dueno`
  - Cada tarjeta está marcada como seleccionada si coincide con `selectedRole`.
  - Llama a `onRoleChanged` cuando el usuario elige un rol.

## Manejo de estados

`AuthViewModel` define:

- `AuthStatus.idle`
- `AuthStatus.loading`
- `AuthStatus.success`
- `AuthStatus.error`

Y expone:

- `status`
- `user`
- `errorMessage`
- `isLoading`

También tiene métodos:

- `login(...)`
- `register(...)`
- `logout()`
- `resetStatus()`

## Proveedores y dependency injection

La configuración de providers se hace en `lib/core/providers/auth_providers.dart`.

Se inicializa `AuthViewModel` así:

- `LoginUseCase(AuthRepositoryImpl(AuthRemoteDataSourceImpl()))`
- `RegisterUseCase(AuthRepositoryImpl(AuthRemoteDataSourceImpl()))`
- `LogoutUseCase(AuthRepositoryImpl(AuthRemoteDataSourceImpl()))`

Esto significa que el `ViewModel` no conoce detalles de red o almacenamiento, solo usa casos de uso.

## Capa de datos

### `AuthRemoteDataSourceImpl`

Actualmente es un mock que simula una llamada de red con `Future.delayed`.

- En `login(...)`, devuelve un `UserModel` con un id fijo y el email enviado.
- En `register(...)`, devuelve un `UserModel` con los datos de registro.

Para conectar a una API real, reemplaza el contenido de `AuthRemoteDataSourceImpl` con llamadas HTTP/Dio.

### `AuthRepositoryImpl`

Implementa `AuthRepository` y delega en el `AuthRemoteDataSource`:

- `login(email, password)`
- `register(name, email, password, role)`

## Strings constantes

Todas las cadenas de texto de la auth están en `lib/core/constants/app_strings.dart`.

Ejemplos:

- `AppStrings.loginTitle`
- `AppStrings.loginSubtitle`
- `AppStrings.emailLabel`
- `AppStrings.passwordLabel`
- `AppStrings.loginButton`
- `AppStrings.registerButton`
- `AppStrings.noAccount`
- `AppStrings.emailRequired`
- `AppStrings.passwordShort`
- `AppStrings.passwordsNoMatch`

### Por qué usar constantes

- Evita duplicar texto en varias pantallas.
- Facilita el cambio de redacción.
- Permite centralizar traducciones futuras.
- Mejora la coherencia de la UI.

## Cómo extender auth

1. Añade nuevas cadenas en `lib/core/constants/app_strings.dart`.
2. Usa esas constantes en los widgets de `presentation`.
3. Si necesitas una nueva acción, agrega un caso de uso en `domain/usecase`.
4. Implementa la lógica real en `data/datasources/auth_remote_ds.dart`.
5. Asegúrate de que `auth_providers.dart` provea las dependencias necesarias.

## Archivos importantes

- `lib/features/auth/presentation/screens/login/login_screen.dart`
- `lib/features/auth/presentation/screens/register/register_screen.dart`
- `lib/features/auth/presentation/viewmodels/auth_viewmodel.dart`
- `lib/features/auth/domain/usecase/login_usecase.dart`
- `lib/features/auth/domain/usecase/register_usecase.dart`
- `lib/features/auth/data/repositories/auth_repo_impl.dart`
- `lib/features/auth/data/datasources/auth_remote_ds.dart`
- `lib/core/constants/app_strings.dart`
- `lib/core/providers/auth_providers.dart`
- `lib/core/router/app_router.dart`

## Notas finales

- El flujo actual es local/mock, pero la estructura ya está preparada para integrar backend real.
- `AuthViewModel` gestiona estado y errores para la UI.
- Las validaciones de formulario usan `AppStrings` para los mensajes.
- La navegación entre login y registro se hace con `GoRouter`.
