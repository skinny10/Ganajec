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

  // Registro bovino
  static const String registrarBovino = 'Registrar bovino';
  static const String registraTuBovino = 'Registra tu bovino';
  static const String nombreAnimal = 'NOMBRE DEL ANIMAL';
  static const String nombreAnimalHint = 'Ej. Lupita, Canela, Estrella';
  static const String idArete = 'ID / NÚMERO DE ARETE (OPCIONAL)';
  static const String idAreteHint = 'Ej. ID-0021';
  static const String idAreteHelper = 'Si no tiene, el sistema generará uno automáticamente.';
  static const String categoriaAnimal = 'CATEGORÍA DEL ANIMAL';
  static const String proposito = 'PROPÓSITO';
  static const String raza = 'RAZA';
  static const String seleccionaRaza = 'Selecciona la raza';
  static const String edadAnios = 'EDAD (AÑOS)';
  static const String edadHint = 'Ej. 4';
  static const String pesoKg = 'PESO (KG)';
  static const String pesoHint = 'Ej. 480';
  static const String agregarDatosOpcionales = 'Agregar datos opcionales';
  static const String cancelar = 'Cancelar';
  static const String siguiente = 'Siguiente';
  static const String nombreRequerido = 'El nombre es requerido';
  static const String edadInvalida = 'Edad no válida';
  static const String pesoInvalido = 'Peso no válido';
  static const String razaRequerida = 'Selecciona una raza';
  static const String categoriaRequerida = 'Selecciona una categoría';
}