import 'package:flutter/material.dart';

class PoliticaPrivacidadScreen extends StatelessWidget {
  const PoliticaPrivacidadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAF7),
        elevation: 0,
        title: const Text(
          'Política de Privacidad',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        leading: const BackButton(color: Color(0xFF1A1A1A)),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 8, 24, 48),
        child: _PoliticaContent(),
      ),
    );
  }
}

class _PoliticaContent extends StatelessWidget {
  const _PoliticaContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5EF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFA5D6A7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🐄  GANAJEC', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1D7A55))),
              const SizedBox(height: 4),
              const Text('Política de Privacidad', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1D7A55))),
              const SizedBox(height: 8),
              Text(
                'Última actualización: ${_fechaActual()}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF4A8C68)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        _seccion('1. Responsable del tratamiento', '''
GANAJEC es una aplicación móvil desarrollada y operada de manera independiente. Al usar esta aplicación, aceptas las prácticas descritas en esta Política de Privacidad.

Para cualquier asunto relacionado con tus datos personales, puedes contactarnos a través de los medios indicados al final de este documento.'''),

        _seccion('2. Datos que recopilamos', '''
Recopilamos únicamente los datos necesarios para brindarte el servicio:

• Datos de cuenta: nombre completo, correo electrónico y contraseña (almacenada de forma cifrada).
• Datos del rancho: nombre del rancho, municipio y estado.
• Datos del ganado: nombre, número de arete, raza, categoría, peso, edad, propósito y fecha de registro de cada animal.
• Datos de salud animal: síntomas registrados, temperatura corporal, frecuencia respiratoria y resultados de predicciones generadas por inteligencia artificial.
• Datos de uso: historial de predicciones y alertas de salud generadas.
• Datos técnicos: token de sesión almacenado localmente en tu dispositivo.'''),

        _seccion('3. Finalidad del tratamiento', '''
Utilizamos tus datos exclusivamente para:

• Crear y gestionar tu cuenta de usuario.
• Permitirte registrar y dar seguimiento a tu ganado.
• Generar predicciones de enfermedades mediante inteligencia artificial a partir de los síntomas que ingresas.
• Enviar alertas de salud relacionadas con los animales de tu rancho.
• Facilitar la gestión de ganaderos y veterinarios asociados a tu rancho.
• Mejorar la precisión del modelo de predicción de enfermedades.'''),

        _seccion('4. Base legal del tratamiento', '''
El tratamiento de tus datos se realiza con base en:

• Tu consentimiento expreso al crear una cuenta y aceptar esta política.
• La ejecución del contrato de servicio que surge al registrarte en GANAJEC.
• El interés legítimo de mejorar la seguridad y funcionalidad de la aplicación.'''),

        _seccion('5. Compartición de datos', '''
GANAJEC no vende, alquila ni comparte tus datos personales con terceros con fines comerciales.

Tus datos únicamente pueden ser accedidos por:

• El servidor de GANAJEC que procesa las solicitudes de la aplicación.
• Otros usuarios de tu misma organización (por ejemplo, el dueño del rancho puede ver los datos del ganado registrado por sus ganaderos, dentro de los límites del sistema de roles).

No compartimos tus datos con servicios de analítica de terceros, redes publicitarias ni plataformas externas.'''),

        _seccion('6. Almacenamiento y seguridad', '''
• Tus datos se almacenan en servidores protegidos con acceso restringido.
• Las contraseñas se almacenan cifradas y nunca en texto plano.
• La comunicación entre la app y el servidor se realiza mediante HTTPS.
• El token de sesión se guarda localmente en tu dispositivo usando almacenamiento seguro y se elimina al cerrar sesión.

Si bien implementamos medidas de seguridad razonables, ningún sistema es completamente invulnerable. Te recomendamos usar una contraseña segura y no compartirla.'''),

        _seccion('7. Retención de datos', '''
Conservamos tus datos mientras tu cuenta esté activa. Si deseas eliminar tu cuenta y todos los datos asociados, puedes solicitarlo a través de los medios de contacto indicados al final de esta política.

Los registros de salud animal pueden ser conservados de forma anonimizada para mejorar el modelo de predicción, sin que puedan asociarse a tu identidad.'''),

        _seccion('8. Tus derechos (Derechos ARCO)', '''
De conformidad con la Ley Federal de Protección de Datos Personales en Posesión de los Particulares (LFPDPPP) y su reglamento, tienes derecho a:

• Acceso: conocer qué datos tuyos tenemos y cómo los usamos.
• Rectificación: corregir datos incorrectos o desactualizados.
• Cancelación: solicitar la eliminación de tus datos personales.
• Oposición: oponerte al tratamiento de tus datos para fines específicos.

Para ejercer cualquiera de estos derechos, contáctanos mediante los medios indicados al final de este documento. Responderemos en un plazo máximo de 20 días hábiles.'''),

        _seccion('9. Menores de edad', '''
GANAJEC no está dirigida a menores de 18 años. No recopilamos intencionalmente datos de menores. Si eres padre o tutor y crees que tu hijo ha proporcionado datos personales, contáctanos para eliminarlos.'''),

        _seccion('10. Cambios a esta política', '''
Podemos actualizar esta Política de Privacidad cuando sea necesario. Cuando lo hagamos, actualizaremos la fecha de "última actualización" al inicio de este documento.

Te notificaremos de cambios significativos a través de la aplicación. El uso continuo de GANAJEC después de la notificación implica tu aceptación de la política actualizada.'''),

        _seccion('11. Contacto', '''
Si tienes preguntas, solicitudes o comentarios sobre esta Política de Privacidad o el tratamiento de tus datos, puedes contactarnos:

📧  Correo electrónico: privacidad@ganajec.app
📱  A través de la sección de soporte dentro de la aplicación

Haremos nuestro mejor esfuerzo para responderte en el menor tiempo posible.'''),

        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3EE),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE8E5DC)),
          ),
          child: const Text(
            'Al usar GANAJEC, confirmas que has leído y aceptado esta Política de Privacidad.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF888880),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _seccion(String titulo, String contenido) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            contenido,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4A4A4A),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFFE8E5DC)),
        ],
      ),
    );
  }

  String _fechaActual() {
    final now = DateTime.now();
    const meses = [
      '', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${now.day} de ${meses[now.month]} de ${now.year}';
  }
}
