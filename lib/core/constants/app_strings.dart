class AppStrings {
  AppStrings._();

  static const String appName = 'GANAJEC';

  // Auth — títulos
  static const String loginTitle = 'Bienvenido';
  static const String loginSubtitle = 'Ingresa tus credenciales para acceder al sistema';
  static const String registerTitle = 'Únete a GANAJEC';
  static const String registerSubtitle = 'Comienza a monitorear la salud de tu ganado hoy mismo.';

  // Auth — labels de campos
  static const String emailLabel = 'Correo electrónico';
  static const String passwordLabel = 'Contraseña';
  static const String nameLabel = 'Nombre completo';
  static const String confirmPasswordLabel = 'Confirmar contraseña';

  // Auth — botones
  static const String loginButton = 'Iniciar sesión';
  static const String registerButton = 'Crear cuenta';

  // Auth — navegación
  static const String noAccount = '¿No tienes cuenta? Regístrate';
  static const String hasAccount = '¿Ya tienes cuenta? Inicia sesión';

  // Auth — validaciones
  static const String emailRequired = 'El correo es requerido';
  static const String emailInvalid = 'Correo no válido';
  static const String passwordRequired = 'La contraseña es requerida';
  static const String passwordShort = 'Mínimo 6 caracteres';
  static const String nameRequired = 'El nombre es requerido';
  static const String passwordsNoMatch = 'Las contraseñas no coinciden';
}