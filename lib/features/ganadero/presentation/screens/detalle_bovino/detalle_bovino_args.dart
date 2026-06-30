import 'package:ganajec/share/domain/entities/animal.dart';

class DetalleBovinoArgs {
  final Animal animal;
  /// Cuando es true: oculta el botón editar y el CTA "Registrar síntomas".
  final bool soloLectura;

  const DetalleBovinoArgs({
    required this.animal,
    this.soloLectura = false,
  });
}
