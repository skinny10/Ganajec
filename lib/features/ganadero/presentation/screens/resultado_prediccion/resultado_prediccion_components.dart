import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/animal.dart';
import 'package:ganajec/share/domain/entities/prediccion.dart';

// ─── Helpers de datos ─────────────────────────────────────────────────────────

class AlternativaDiag {
  final String nombre;
  final String desc;
  final double probabilidad;
  const AlternativaDiag(this.nombre, this.desc, this.probabilidad);
}

/// Severidad: usa el campo que manda la API; fallback en confianza.
String severidadLabel(Prediccion p) {
  if (p.severidad == 'alta') return 'alta';
  if (p.severidad == 'media') return 'moderada';
  if (p.severidad == 'baja') return 'leve';
  // fallback si el campo viene vacío
  if (p.confianza >= 0.7) return 'alta';
  if (p.confianza >= 0.4) return 'moderada';
  return 'leve';
}

/// Subtítulo descriptivo para cada enfermedad detectada por el modelo.
String subtituloDe(String enfermedad) {
  final e = enfermedad.toLowerCase();
  if (e.contains('mastitis'))
    return 'Inflamación de la glándula mamaria. Se asocia a secreción anormal, calor en la ubre y baja producción.';
  if (e.contains('acetonemia') || e.contains('cetosis'))
    return 'Deficiencia energética posparto. El hígado produce cuerpos cetónicos en exceso al no cubrir la demanda.';
  if (e.contains('carbón') || e.contains('pierna negra'))
    return 'Infección bacteriana grave por Clostridium. Causa hinchazón musculosa con gas y crepitación al tacto.';
  if (e.contains('timpanismo') || e.contains('meteorismo'))
    return 'Acumulación excesiva de gas en el rumen. Puede ser life-threatening si no se trata de inmediato.';
  if (e.contains('difteria del becerro') || e.contains('difteria'))
    return 'Infección necrótica de la boca y laringe en becerros jóvenes. Produce salivación excesiva y dificultad para comer.';
  if (e.contains('neumonía del becerro') || e.contains('neumonía'))
    return 'Infección respiratoria en becerros. Alta mortalidad si no se trata. Causa fiebre, tos y dificultad respiratoria.';
  if (e.contains('coccidiosis'))
    return 'Infección parasitaria intestinal, frecuente en terneros. Produce diarrea con sangre y pérdida de peso rápida.';
  if (e.contains('criptosporidiosis'))
    return 'Parasitosis por Cryptosporidium en becerros neonatos. Diarrea acuosa intensa y deshidratación grave.';
  if (e.contains('abomaso') || e.contains('desplazamiento'))
    return 'El abomaso se desplaza de su posición normal. Común en vacas lecheras tras el parto.';
  if (e.contains('hígado graso'))
    return 'Acumulación de grasa en el hígado por balance energético negativo. Reduce inmunidad y producción.';
  if (e.contains('fiebre de pasto') || e.contains('enfisema pulmonar'))
    return 'Reacción pulmonar aguda al cambiar a pastos frescos ricos en triptófano. Dificultad respiratoria severa.';
  if (e.contains('fiebre aftosa') || e.contains('aftosa'))
    return 'Enfermedad viral altamente contagiosa. Produce ampollas en boca, patas y ubre. Notificación obligatoria.';
  if (e.contains('pudrición de pezuña') || e.contains('podal'))
    return 'Infección bacteriana entre las pezuñas. Causa cojera intensa y puede extenderse al tejido profundo.';
  if (e.contains('parásitos gastrointestinales') || e.contains('parásitos'))
    return 'Infestación por nematodos intestinales. Pérdida de peso gradual, diarrea y anemia en casos severos.';
  if (e.contains('rinotraqueítis') || e.contains('ibr'))
    return 'Herpesvirus bovino-1 (BoHV-1). Afecta vías respiratorias y puede causar aborto en vacas gestantes.';
  if (e.contains('listeriosis'))
    return 'Infección bacteriana por Listeria. Afecta el sistema nervioso causando circling disease y pérdida de equilibrio.';
  if (e.contains('fasciola') || e.contains('distomatosis'))
    return 'Trematodo hepático. Daño crónico al hígado, anemia, pérdida de peso y edema submandibular.';
  if (e.contains('enteritis necrótica'))
    return 'Infección intestinal por Clostridium perfringens. Diarrea hemorrágica aguda de alta mortalidad.';
  if (e.contains('diarrea del destete'))
    return 'Diarrea asociada al proceso de destete. Causa deshidratación y retraso en el crecimiento.';
  if (e.contains('hierba cana') || e.contains('ragwort'))
    return 'Intoxicación crónica por alcaloides de pirrolizidina. Daño hepático acumulativo e irreversible.';
  if (e.contains('valle del rift'))
    return 'Enfermedad viral zoonótica transmitida por mosquitos. Fiebre alta, abortos y alta mortalidad neonatal.';
  if (e.contains('acidosis ruminal'))
    return 'Caída del pH ruminal por exceso de carbohidratos fermentables. Destruye la flora ruminal.';
  if (e.contains('schmallenberg'))
    return 'Orthobunyavirus transmitido por mosquitos. Malformaciones congénitas y abortos en ganado gestante.';
  if (e.contains('reticulitis') || e.contains('enfermedad del clavo'))
    return 'Cuerpo extraño metálico en la retícula que perfora la pared gástrica. Causa dolor abdominal crónico.';
  if (e.contains('tripanosomosis'))
    return 'Infección por Trypanosoma vía tábanos. Anemia progresiva, fiebre recurrente y pérdida de peso.';
  if (e.contains('actinobacilosis') || e.contains('lengua de madera'))
    return 'Infección bacteriana de la lengua y ganglios. Provoca dificultad para comer y salivación excesiva.';
  return 'El análisis no detectó patologías con alta probabilidad. Continúa la observación normal.';
}

/// Diagnósticos alternativos a considerar para cada enfermedad.
List<AlternativaDiag> alternativasDe(String enfermedad) {
  final e = enfermedad.toLowerCase();
  if (e.contains('mastitis'))
    return [
      const AlternativaDiag('Fiebre de leche', 'Hipocalcemia postparto. Considerar si parió recientemente.', 0.35),
      const AlternativaDiag('Desplazamiento de abomaso', 'Común en vacas lecheras de alta producción.', 0.18),
    ];
  if (e.contains('acetonemia') || e.contains('cetosis'))
    return [
      const AlternativaDiag('Hígado graso', 'Complicación frecuente de la cetosis. Mismos signos clínicos.', 0.40),
      const AlternativaDiag('Desplazamiento de abomaso', 'Puede coexistir con cetosis en el periparto.', 0.22),
    ];
  if (e.contains('timpanismo') || e.contains('meteorismo'))
    return [
      const AlternativaDiag('Obstrucción esofágica', 'El gas no puede expulsarse si hay cuerpo extraño en esófago.', 0.28),
      const AlternativaDiag('Reticulitis traumática', 'Dolor que limita eructación y acumula gas.', 0.15),
    ];
  if (e.contains('neumonía del becerro') || e.contains('neumonía'))
    return [
      const AlternativaDiag('IBR (Rinotraqueítis)', 'Mismos signos respiratorios; requiere diagnóstico viral.', 0.32),
      const AlternativaDiag('Fiebre de pasto', 'En adultos con dificultad respiratoria aguda.', 0.12),
    ];
  if (e.contains('coccidiosis'))
    return [
      const AlternativaDiag('Criptosporidiosis', 'Diarrea similar en neonatos; identificar por laboratorio.', 0.38),
      const AlternativaDiag('Enteritis necrótica', 'Diarrea hemorrágica más severa.', 0.20),
    ];
  if (e.contains('parásitos gastrointestinales') || e.contains('parásitos'))
    return [
      const AlternativaDiag('Fasciola hepática', 'Pérdida de peso similar con afección hepática predominante.', 0.30),
      const AlternativaDiag('Tripanosomosis', 'Anemia progresiva por hemoparásitos.', 0.18),
    ];
  if (e.contains('abomaso') || e.contains('desplazamiento'))
    return [
      const AlternativaDiag('Reticulitis traumática', 'Dolor abdominal similar; historia de cuerpo extraño.', 0.28),
      const AlternativaDiag('Cetosis', 'Frecuentemente coexistente en el período de transición.', 0.22),
    ];
  if (e.contains('fiebre aftosa') || e.contains('aftosa'))
    return [
      const AlternativaDiag('Estomatitis vesicular', 'Lesiones similares; diferenciación por laboratorio.', 0.25),
      const AlternativaDiag('Actinobacilosis', 'Lesiones orales sin vesículas en patas.', 0.12),
    ];
  if (e.contains('pudrición de pezuña') || e.contains('podal'))
    return [
      const AlternativaDiag('Fiebre aftosa', 'También causa lesiones en patas; revisar boca.', 0.22),
      const AlternativaDiag('Artritis séptica', 'Inflamación articular sin lesión interdigital.', 0.15),
    ];
  if (e.contains('rinotraqueítis') || e.contains('ibr'))
    return [
      const AlternativaDiag('Neumonía bacteriana', 'Signos respiratorios similares; cultivo para diferenciar.', 0.30),
      const AlternativaDiag('Virus Schmallenberg', 'Si hay abortos asociados al brote.', 0.14),
    ];
  if (e.contains('fasciola') || e.contains('distomatosis'))
    return [
      const AlternativaDiag('Parásitos gastrointestinales', 'Pérdida de peso y anemia superpuesta.', 0.35),
      const AlternativaDiag('Tripanosomosis', 'Anemia crónica de origen hemoparasitario.', 0.18),
    ];
  if (e.contains('reticulitis') || e.contains('enfermedad del clavo'))
    return [
      const AlternativaDiag('Timpanismo crónico', 'Gas acumulado secundario a dolor que inhibe eructación.', 0.25),
      const AlternativaDiag('Desplazamiento de abomaso', 'Dolor abdominal de origen diferente.', 0.20),
    ];
  if (e.contains('acidosis ruminal'))
    return [
      const AlternativaDiag('Timpanismo espumoso', 'Frecuente en pasturas ricas; afecta misma área.', 0.30),
      const AlternativaDiag('Enterotoxemia', 'Toxinas bacterianas asociadas a exceso de concentrado.', 0.18),
    ];
  return [];
}

/// Pasos de acción recomendados para cada enfermedad detectada.
List<String> pasosDe(String enfermedad, String animalNombre) {
  final e = enfermedad.toLowerCase();
  if (e.contains('mastitis'))
    return [
      'Separa a $animalNombre del hato para reducir estrés y facilitar el manejo.',
      'Revisa la ubre cuarto por cuarto: calor, endurecimiento o secreción anormal.',
      'Contacta a un veterinario hoy. La mastitis severa requiere antibióticos y tratamiento intramamario.',
      'Registra la producción de cada cuarto por separado.',
    ];
  if (e.contains('acetonemia') || e.contains('cetosis'))
    return [
      'Ofrece a $animalNombre propilenglicol oral (250–400 ml) como fuente de glucosa inmediata.',
      'Aumenta la energía en la dieta: maíz molido, melaza o granos fermentables.',
      'Llama al veterinario si no mejora en 24 h; puede requerir suero glucosado IV.',
      'Verifica la condición corporal: animales muy gordos al parto son de alto riesgo.',
    ];
  if (e.contains('carbón') || e.contains('pierna negra'))
    return [
      'Aísla a $animalNombre inmediatamente — el carbón es altamente letal y contagioso.',
      'Llama al veterinario de urgencia. El tratamiento con penicilina debe ser inmediato.',
      'No muevas el cadáver si el animal muere; notifica a las autoridades sanitarias.',
      'Vacuna al resto del hato con vacuna antidosificada como medida preventiva.',
    ];
  if (e.contains('timpanismo') || e.contains('meteorismo'))
    return [
      'Saca a $animalNombre del pastizal y ponlo en movimiento suave de inmediato.',
      'Si el vientre izquierdo está muy inflado, llama al veterinario — puede requerir trúcar.',
      'Administra aceite mineral (500 ml) vía oral para romper la espuma si es timpanismo espumoso.',
      'Revisa el tipo de forraje: evita leguminosas húmedas o pastos de crecimiento rápido.',
    ];
  if (e.contains('neumonía del becerro') || e.contains('neumonía'))
    return [
      'Aísla al becerro en un lugar seco, sin corrientes de aire y bien ventilado.',
      'Llama al veterinario — la neumonía bacteriana requiere antibióticos de espectro amplio.',
      'Asegura hidratación: electrolitos orales si no puede mamar.',
      'Revisa el resto de la camada; la neumonía se propaga rápidamente en terneros.',
    ];
  if (e.contains('coccidiosis'))
    return [
      'Aísla a $animalNombre para evitar contagio fecal-oral en el hato.',
      'Contacta al veterinario para tratamiento con sulfonamidas o amprolium.',
      'Asegura hidratación adecuada; la diarrea causa deshidratación rápida.',
      'Limpia y desinfecta las instalaciones — los ooquistes son resistentes en el ambiente.',
    ];
  if (e.contains('criptosporidiosis'))
    return [
      'Aísla al becerro y extrema la higiene — el parásito es zoonótico.',
      'Proporciona electrolitos orales para contrarrestar la deshidratación.',
      'Consulta al veterinario; no hay tratamiento específico aprobado, el manejo es de soporte.',
      'Revisa el calostrado del neonato — la inmunidad materna es la mejor protección.',
    ];
  if (e.contains('abomaso') || e.contains('desplazamiento'))
    return [
      'Llama al veterinario — el desplazamiento de abomaso requiere corrección quirúrgica o manual.',
      'No fuerces la alimentación hasta que el animal sea evaluado.',
      'El veterinario puede intentar volteo del animal como maniobra conservadora inicial.',
      'Tras la corrección, monitorea la producción de leche y el consumo de alimento.',
    ];
  if (e.contains('hígado graso'))
    return [
      'Aumenta gradualmente la energía de $animalNombre con propilenglicol oral.',
      'Ofrece alimentos palatables en pequeñas cantidades frecuentes para estimular el apetito.',
      'El veterinario puede recomendar suero glucosado IV en casos severos.',
      'Controla el nivel de condición corporal: ajusta la dieta en el período seco.',
    ];
  if (e.contains('fiebre de pasto') || e.contains('enfisema pulmonar'))
    return [
      'Retira a $animalNombre del potrero nuevo de inmediato.',
      'Llama al veterinario de urgencia — el enfisema puede ser fatal en horas.',
      'El tratamiento con dexametasona o antihistamínicos debe ser rápido.',
      'Realiza cambios de potrero de forma gradual para prevenir recurrencia.',
    ];
  if (e.contains('fiebre aftosa') || e.contains('aftosa'))
    return [
      'ALERTA: la fiebre aftosa es de declaración obligatoria. Notifica a SENASICA de inmediato.',
      'Aísla a $animalNombre y restringe el movimiento de todo el hato.',
      'No traslades animales, vehículos ni personas sin desinfección rigurosa.',
      'El veterinario tomará muestras para confirmación de laboratorio oficial.',
    ];
  if (e.contains('pudrición de pezuña') || e.contains('podal'))
    return [
      'Saca a $animalNombre de terrenos fangosos o húmedos.',
      'Limpia la zona interdigital y aplica spray antibacterial o sulfato de cobre.',
      'Consulta al veterinario para antibioticoterapia sistémica si hay fiebre.',
      'Revisa y corrige el fondo del corral: la humedad excesiva favorece la pudrición.',
    ];
  if (e.contains('parásitos gastrointestinales') || e.contains('parásitos'))
    return [
      'Consulta al veterinario para realizar conteo de huevos en heces (método McMaster).',
      'Aplica antihelmíntico adecuado según el resultado del coprológico.',
      'Rota los potreros para interrumpir el ciclo parasitario en el pasto.',
      'Mejora la nutrición de $animalNombre para fortalecer su respuesta inmune.',
    ];
  if (e.contains('rinotraqueítis') || e.contains('ibr'))
    return [
      'Aísla a $animalNombre — el IBR se propaga rápido por aerosoles.',
      'Llama al veterinario para tratamiento de soporte y antibióticos preventivos.',
      'Si hay vacas gestantes en el hato, monitoréalas por posible aborto.',
      'Vacuna el hato contra BoHV-1 si no están protegidos.',
    ];
  if (e.contains('listeriosis'))
    return [
      'Llama al veterinario de urgencia — la listeriosis neurológica es de progresión rápida.',
      'Proporciona penicilina a dosis alta de forma inmediata bajo prescripción veterinaria.',
      'Aísla a $animalNombre y protégelo de golpes o caídas por la pérdida de equilibrio.',
      'Revisa el ensilado: Listeria prolifera en silos mal fermentados o contaminados.',
    ];
  if (e.contains('fasciola') || e.contains('distomatosis'))
    return [
      'Consulta al veterinario para tratamiento con triclabendazol o closantel.',
      'Identifica y drena zonas pantanosas del potrero donde sobrevive el caracol huésped.',
      'Realiza coprológico para confirmar huevos de Fasciola antes del tratamiento.',
      'Aplica un programa de desparasitación estratégica según la época de lluvias.',
    ];
  if (e.contains('enteritis necrótica'))
    return [
      'Llama al veterinario de urgencia — la enteritis necrótica tiene alta mortalidad.',
      'El tratamiento con penicilina o antitoxinas clostridiales debe ser inmediato.',
      'Aísla a $animalNombre y desinfecta el área con cal viva.',
      'Vacuna al hato con toxoide clostridial para prevenir futuros casos.',
    ];
  if (e.contains('diarrea del destete'))
    return [
      'Proporciona electrolitos orales para prevenir la deshidratación.',
      'Mantén a $animalNombre en un ambiente limpio, seco y sin estrés adicional.',
      'Realiza el destete gradualmente si es posible para reducir el impacto.',
      'Consulta al veterinario si la diarrea persiste más de 48 h o aparece sangre.',
    ];
  if (e.contains('hierba cana') || e.contains('ragwort'))
    return [
      'Retira a $animalNombre del potrero con hierba cana de inmediato.',
      'Llama al veterinario — el daño hepático puede ser irreversible; evalúa enzimas hepáticas.',
      'El tratamiento es de soporte: no existe antídoto específico para los alcaloides.',
      'Identifica y erradica la planta del potrero con herbicida o extracción manual.',
    ];
  if (e.contains('valle del rift'))
    return [
      'ALERTA: la Fiebre del Valle del Rift es zoonótica. Usa protección personal al manejar a $animalNombre.',
      'Notifica a las autoridades sanitarias de inmediato — es de declaración obligatoria.',
      'Aísla al animal y controla los vectores (mosquitos) en el entorno.',
      'El veterinario tomará muestras para confirmación serológica urgente.',
    ];
  if (e.contains('acidosis ruminal'))
    return [
      'Retira el alimento concentrado de $animalNombre de inmediato.',
      'Llama al veterinario — puede requerir bicarbonato IV y lavado ruminal.',
      'Ofrece bicarbonato de sodio libre (buffer) y forraje de buena calidad.',
      'Revisa la dieta: los cambios bruscos a concentrado son la principal causa.',
    ];
  if (e.contains('schmallenberg'))
    return [
      'No existe tratamiento específico — el manejo es de soporte.',
      'Monitorea a las hembras gestantes por posibles malformaciones en las crías.',
      'Notifica al veterinario y a las autoridades sanitarias si confirmas el diagnóstico.',
      'Controla mosquitos y tábanos vectores con insecticidas en el área.',
    ];
  if (e.contains('reticulitis') || e.contains('enfermedad del clavo'))
    return [
      'Llama al veterinario — se necesita diagnóstico con imán y radiografía o ultrasonido.',
      'Administra un imán ruminal preventivo-terapéutico bajo indicación veterinaria.',
      'Evita que $animalNombre haga esfuerzos: el cuerpo extraño puede perforar más profundo.',
      'Instala imanes en comederos y revisa el entorno por materiales metálicos.',
    ];
  if (e.contains('tripanosomosis'))
    return [
      'Llama al veterinario para diagnóstico por frotis de sangre y tratamiento con berenil.',
      'Controla los tábanos vectores con insecticidas en el potrero y en el animal.',
      'Aísla a $animalNombre si está muy débil para facilitar el manejo.',
      'Revisa el hato completo — la tripanosomosis puede afectar a varios animales.',
    ];
  if (e.contains('actinobacilosis') || e.contains('lengua de madera'))
    return [
      'Llama al veterinario — el tratamiento con yoduro de potasio o penicilina es efectivo si se inicia pronto.',
      'Ofrece a $animalNombre alimentos blandos o molidos para facilitar la masticación.',
      'Drena los abscesos bajo supervisión veterinaria y aplica antiséptico local.',
      'Evita forrajes con aristas que dañen la mucosa oral y faciliten la infección.',
    ];
  return [
    'Continúa con la observación normal del animal.',
    'Mantén registros diarios de producción y temperatura.',
    'Repite el análisis si observas cambios en los próximos días.',
  ];
}


String _tiempoRelativo(DateTime fecha) {
  final diff = DateTime.now().difference(fecha);
  if (diff.inSeconds < 60) return 'hace ${diff.inSeconds} seg';
  if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
  return 'hace ${diff.inHours} h';
}

// ─── Helpers de color por severidad (reciben ColorScheme) ────────────────────

Color _heroBg(String sev, ColorScheme cs) => sev == 'alta'
    ? cs.errorContainer
    : sev == 'moderada'
        ? cs.secondaryContainer
        : cs.tertiaryContainer;

Color _heroBorder(String sev, ColorScheme cs) => sev == 'alta'
    ? cs.error.withOpacity(0.3)
    : sev == 'moderada'
        ? cs.secondary.withOpacity(0.3)
        : cs.tertiary.withOpacity(0.3);

Color _heroAccent(String sev, ColorScheme cs) => sev == 'alta'
    ? cs.error
    : sev == 'moderada'
        ? cs.secondary
        : cs.tertiary;

Color _heroTextColor(String sev, ColorScheme cs) => sev == 'alta'
    ? cs.onErrorContainer
    : sev == 'moderada'
        ? cs.onSecondaryContainer
        : cs.onTertiaryContainer;

// ─── Hero del resultado ───────────────────────────────────────────────────────

class ResultadoHeroCard extends StatefulWidget {
  final Prediccion prediccion;

  const ResultadoHeroCard({super.key, required this.prediccion});

  @override
  State<ResultadoHeroCard> createState() => _ResultadoHeroCardState();
}

class _ResultadoHeroCardState extends State<ResultadoHeroCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 0.4).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final p = widget.prediccion;
    final sev = severidadLabel(p);
    final accent = _heroAccent(sev, cs);
    final sevTexto = sev == 'alta'
        ? 'Severidad alta'
        : sev == 'moderada'
            ? 'Severidad moderada'
            : 'Severidad leve';

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        color: _heroBg(sev, cs),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _heroBorder(sev, cs)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  FadeTransition(
                    opacity: _pulseAnim,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    sevTexto,
                    style: tt.labelSmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: accent,
                    ),
                  ),
                ],
              ),
              Text(
                _tiempoRelativo(p.fecha),
                style: tt.labelSmall?.copyWith(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w300,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            p.enfermedad,
            style: tt.headlineSmall?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
              letterSpacing: -1,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtituloDe(p.enfermedad),
            style: tt.bodySmall?.copyWith(
              fontSize: 13,
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w300,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Confianza del modelo',
                style: tt.labelSmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: accent,
                ),
              ),
              Text(
                '${(p.confianza * 100).toStringAsFixed(0)}%',
                style: tt.bodyLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: accent,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 8,
              color: accent.withOpacity(0.15),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: p.confianza),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOut,
                builder: (_, value, __) => FractionallySizedBox(
                  widthFactor: value,
                  alignment: Alignment.centerLeft,
                  child: Container(color: accent),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Fila del animal ──────────────────────────────────────────────────────────

class ResultadoAnimalRow extends StatelessWidget {
  final Animal animal;
  final Prediccion prediccion;
  final double temperatura;
  final double litrosLeche;

  const ResultadoAnimalRow({
    super.key,
    required this.animal,
    required this.prediccion,
    required this.temperatura,
    required this.litrosLeche,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: cs.errorContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('🐄', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${animal.nombre} — ${animal.raza}',
                  style: tt.bodySmall?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${animal.idExterno} · Temp: ${temperatura.toStringAsFixed(1)}°C · Leche: ${litrosLeche.toStringAsFixed(0)} L',
                  style: tt.labelSmall?.copyWith(
                    fontSize: 11,
                    color: cs.outline,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _tiempoRelativo(prediccion.fecha),
            style: tt.labelSmall?.copyWith(
              fontSize: 10.5,
              color: cs.outline,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sección de síntomas detectados ──────────────────────────────────────────

class ResultadoSintomasSection extends StatelessWidget {
  final List<String> formulario;
  final List<String> nlp;

  const ResultadoSintomasSection({
    super.key,
    required this.formulario,
    required this.nlp,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            ...formulario.map((s) => _SintTag(label: s, isNLP: false)),
            ...nlp.map((s) => _SintTag(label: s, isNLP: true)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _Leyenda(
              color: cs.surfaceContainerLow,
              borderColor: cs.outlineVariant,
              label: 'Formulario',
            ),
            const SizedBox(width: 10),
            _Leyenda(
              color: cs.secondaryContainer,
              borderColor: cs.secondary.withOpacity(0.5),
              label: 'Extraído por NLP',
            ),
          ],
        ),
      ],
    );
  }
}

class _SintTag extends StatelessWidget {
  final String label;
  final bool isNLP;

  const _SintTag({required this.label, required this.isNLP});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isNLP ? cs.secondaryContainer : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isNLP ? cs.secondary.withOpacity(0.5) : cs.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              fontSize: 11.5,
              fontWeight: FontWeight.w400,
              color: isNLP ? cs.onSecondaryContainer : cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isNLP ? '· NLP' : '· form',
            style: tt.labelSmall?.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: isNLP
                  ? cs.onSecondaryContainer.withOpacity(0.7)
                  : cs.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _Leyenda extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final String label;

  const _Leyenda({
    required this.color,
    required this.borderColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: tt.labelSmall?.copyWith(
            fontSize: 10,
            color: cs.outline,
          ),
        ),
      ],
    );
  }
}

// ─── Caja NLP ─────────────────────────────────────────────────────────────────

class ResultadoNLPBox extends StatelessWidget {
  final String descripcion;
  final double concordancia;

  const ResultadoNLPBox({
    super.key,
    required this.descripcion,
    this.concordancia = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    if (descripcion.trim().isEmpty) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final preview = descripcion.length > 80
        ? '${descripcion.substring(0, 80)}…'
        : descripcion;

    final pct = (concordancia * 100).round();
    final Color concordColor = pct >= 70
        ? const Color(0xFF2E7D32)
        : pct >= 40
            ? const Color(0xFFF57F17)
            : cs.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: cs.secondary.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🧠', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: tt.bodySmall?.copyWith(
                      fontSize: 11.5,
                      color: cs.onSecondaryContainer,
                      fontWeight: FontWeight.w300,
                      height: 1.6,
                    ),
                    children: [
                      const TextSpan(text: 'El módulo NLP procesó: '),
                      TextSpan(
                        text: '"$preview"',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: cs.onSecondaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const TextSpan(
                        text: ' — extrayendo señales clínicas adicionales.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (concordancia > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: concordancia.clamp(0.0, 1.0),
                      backgroundColor: cs.secondary.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(concordColor),
                      minHeight: 5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$pct% concordancia NLP',
                  style: tt.labelSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: concordColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Alternativas de diagnóstico ──────────────────────────────────────────────

class ResultadoAlternativas extends StatelessWidget {
  final List<AlternativaDiag> alternativas;

  const ResultadoAlternativas({super.key, required this.alternativas});

  @override
  Widget build(BuildContext context) {
    if (alternativas.isEmpty) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: List.generate(alternativas.length, (i) {
        final alt = alternativas[i];
        return Container(
          margin: i < alternativas.length - 1
              ? const EdgeInsets.only(bottom: 8)
              : EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              Text(
                '${i + 2}',
                style: tt.labelMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cs.outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alt.nombre,
                      style: tt.bodySmall?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      alt.desc,
                      style: tt.labelSmall?.copyWith(
                        fontSize: 11,
                        color: cs.outline,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: Container(
                        height: 3,
                        color: cs.outlineVariant,
                        child: FractionallySizedBox(
                          widthFactor: alt.probabilidad,
                          alignment: Alignment.centerLeft,
                          child: Container(color: cs.outline),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(alt.probabilidad * 100).toStringAsFixed(0)}%',
                style: tt.bodyMedium?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ─── Tarjeta de recomendación ────────────────────────────────────────────────

class ResultadoRecomendacion extends StatelessWidget {
  final List<String> pasos;
  final String severidad;

  const ResultadoRecomendacion({
    super.key,
    required this.pasos,
    required this.severidad,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final accent    = _heroAccent(severidad, cs);
    final bg        = _heroBg(severidad, cs);
    final border    = _heroBorder(severidad, cs);
    final textColor = _heroTextColor(severidad, cs);
    final titulo = severidad == 'alta'
        ? 'Acción inmediata recomendada'
        : severidad == 'moderada'
            ? 'Monitoreo recomendado'
            : 'Observación preventiva';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                severidad == 'alta' ? '🚨' : severidad == 'moderada' ? '⚠️' : '✅',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: tt.labelMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...List.generate(pasos.length, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: tt.labelSmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: cs.surface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    pasos[i],
                    style: tt.bodySmall?.copyWith(
                      fontSize: 12,
                      color: textColor,
                      fontWeight: FontWeight.w300,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// ─── Disclaimer ───────────────────────────────────────────────────────────────

class ResultadoDisclaimer extends StatelessWidget {
  const ResultadoDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ℹ️', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 9),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: tt.labelSmall?.copyWith(
                  fontSize: 11,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w300,
                  height: 1.6,
                ),
                children: [
                  const TextSpan(text: 'Este resultado es un '),
                  TextSpan(
                    text: 'soporte predictivo preliminar',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const TextSpan(
                    text:
                        ', no un diagnóstico clínico definitivo. Confirma siempre con un médico veterinario certificado antes de iniciar cualquier tratamiento.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Título de sección ────────────────────────────────────────────────────────

class ResultadoSecTitle extends StatelessWidget {
  final String title;
  const ResultadoSecTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: tt.titleSmall?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: cs.onSurface,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}
