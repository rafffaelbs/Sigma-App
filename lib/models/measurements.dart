// ==========================================
// 1. CORE HELPER CLASSES
// ==========================================

/// The smallest unit of data (The Leaf Node)
class MeasurementValue {
  double value;
  String measurementUnit;
  String imageUrl;
  String timestamp;
  String environmentImageUrl;
  String equipment;
  double? latitude;
  double? longitude;

  bool get isFilled {
    bool hasValue = value > 0.0;
    bool hasImage = imageUrl.trim().isNotEmpty && imageUrl != 'null';
    return hasValue && hasImage;
  }

  MeasurementValue({
    this.value = 0.0,
    this.measurementUnit = "",
    this.imageUrl = "",
    this.timestamp = "",
    this.environmentImageUrl = "",
    this.equipment = "",
    this.latitude,
    this.longitude,
  });

  factory MeasurementValue.fromJson(Map<String, dynamic> json) {
    return MeasurementValue(
      value: (json['value'] ?? 0.0).toDouble(),
      measurementUnit: json['measurmentUnit'] ?? "",
      imageUrl: json['imageUrl'] ?? "",
      environmentImageUrl: json['environmentImageUrl'] ?? "",
      equipment: json['equipment'] ?? "",
      timestamp: json['timestamp'] ?? "",
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'measurmentUnit': measurementUnit,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
      'environmentImageUrl': environmentImageUrl,
      'equipment': equipment,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

/// Helper for standard A/B/C/Reserva structures
class PhaseGroup {
  MeasurementValue faseA;
  MeasurementValue faseB;
  MeasurementValue faseC;
  MeasurementValue? faseReserva;
  MeasurementValue? auxiliar; // Added for TTR/Auxiliar
  String equipamento;
  bool get isFilled {
    // We assume an equipment is "done" when its 3 main phases are filled.
    // (Reserva and Auxiliar are optional)
    return faseA.isFilled && faseB.isFilled && faseC.isFilled;
  }

  PhaseGroup({
    required this.faseA,
    required this.faseB,
    required this.faseC,
    this.faseReserva,
    this.auxiliar,
    this.equipamento = "",
  });

  factory PhaseGroup.fromJson(Map<String, dynamic> json) {
    // Helper to find keys like "Fase A" or "Fase A - ..."
    MeasurementValue find(String keyStart) {
      // Direct match
      if (json.containsKey(keyStart))
        return MeasurementValue.fromJson(json[keyStart]);
      // Fuzzy match for keys like "Fase A - H1-H2..."
      for (var k in json.keys) {
        if (k.startsWith(keyStart)) return MeasurementValue.fromJson(json[k]);
      }
      return MeasurementValue();
    }

    return PhaseGroup(
      faseA: find("Fase A"),
      faseB: find("Fase B"),
      faseC: find("Fase C"),
      faseReserva: json.keys.any((k) => k.startsWith("Fase Reserva"))
          ? find("Fase Reserva")
          : null,
      auxiliar: json.keys.any((k) => k.startsWith("Auxiliar"))
          ? find("Auxiliar")
          : null,
      equipamento: json['Equipamento'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'Fase A': faseA.toJson(),
      'Fase B': faseB.toJson(),
      'Fase C': faseC.toJson(),
      'Equipamento': equipamento,
    };

    if (faseReserva != null) {
      data['Fase Reserva'] = faseReserva!.toJson();
    }
    if (auxiliar != null) {
      data['Auxiliar'] = auxiliar!.toJson();
    }
    return data;
  }
}

/// Helper for dynamic groups (Windings, Grounding, Step Voltage)
/// Handles: "H1-H3", "Passo 1m", "Malha D=18/40", etc.
class DynamicGroup {
  Map<String, MeasurementValue> readings;
  String equipment;
  bool get isFilled {
    if (readings.isEmpty) return false;
    // It's done if EVERY reading inside the group is filled
    return readings.values.every((reading) => reading.isFilled);
  }

  DynamicGroup({required this.readings, this.equipment = ""});

  factory DynamicGroup.fromJson(Map<String, dynamic> json) {
    var map = <String, MeasurementValue>{};
    var eq = "";

    json.forEach((key, value) {
      if (key == "Equipamento") {
        eq = value.toString();
      } else if (value is Map<String, dynamic>) {
        map[key] = MeasurementValue.fromJson(value);
      }
    });

    return DynamicGroup(readings: map, equipment: eq);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    // Convert all the dynamic readings back to JSON
    readings.forEach((key, value) {
      data[key] = value.toJson();
    });

    data['Equipamento'] = equipment;
    return data;
  }
}

// ==========================================
// 2. INSTRUMENT CLASSES
// ==========================================

class Megohmetro {
  DynamicGroup? transformador;
  PhaseGroup? transformadorCorrente;
  Map<String, PhaseGroup> terminacaoMufla;
  Map<String, PhaseGroup> paraRaios;
  Map<String, PhaseGroup> seccionadora;
  Map<String, PhaseGroup> disjuntorReligador;

  Megohmetro({
    this.transformador,
    this.transformadorCorrente,

    Map<String, PhaseGroup>? terminacaoMufla,
    Map<String, PhaseGroup>? paraRaios,
    Map<String, PhaseGroup>? seccionadora,
    Map<String, PhaseGroup>? disjuntorReligador,
  }) : terminacaoMufla = terminacaoMufla ?? {},
       paraRaios = paraRaios ?? {},
       seccionadora = seccionadora ?? {},
       disjuntorReligador = disjuntorReligador ?? {};

  factory Megohmetro.fromJson(Map<String, dynamic> json) {
    return Megohmetro(
      transformador: json['Transformador'] != null
          ? DynamicGroup.fromJson(json['Transformador'])
          : null,
      terminacaoMufla: _parseMapPhase(json['Terminacao Mufla']),
      paraRaios: _parseMapPhase(json['Para Raios']),
      seccionadora: _parseMapPhase(json['Seccionadora']),
      disjuntorReligador: _parseMapPhase(json['Disjuntor Religador']),
      transformadorCorrente: json['Transformador Corrente'] != null
          ? PhaseGroup.fromJson(json['Transformador Corrente'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    // Only add objects if they are NOT null
    if (transformador != null) {
      data['Transformador'] = transformador!.toJson();
    }
    if (transformadorCorrente != null) {
      data['Transformador Corrente'] = transformadorCorrente!.toJson();
    }

    // Only add maps if they are NOT empty
    if (terminacaoMufla.isNotEmpty) {
      data['Terminacao Mufla'] = terminacaoMufla.map(
        (k, v) => MapEntry(k, v.toJson()),
      );
    }
    if (paraRaios.isNotEmpty) {
      data['Para Raios'] = paraRaios.map((k, v) => MapEntry(k, v.toJson()));
    }
    if (seccionadora.isNotEmpty) {
      data['Seccionadora'] = seccionadora.map(
        (k, v) => MapEntry(k, v.toJson()),
      );
    }
    if (disjuntorReligador.isNotEmpty) {
      data['Disjuntor Religador'] = disjuntorReligador.map(
        (k, v) => MapEntry(k, v.toJson()),
      );
    }

    return data;
  }

  InspectionProgress getProgress() {
    int total = 0;
    int completed = 0;

    void countMap(Map<String, dynamic> map) {
      for (var eq in map.values) {
        total++;
        if ((eq is PhaseGroup && eq.isFullyComplete) ||
            (eq is DynamicGroup && eq.isFullyComplete)) {
          completed++;
        }
      }
    }

    if (transformador != null && transformador!.readings.isNotEmpty) {
      total++;
      if (transformador!.isFullyComplete) completed++;
    }

    countMap(terminacaoMufla);
    countMap(paraRaios);
    countMap(seccionadora);
    countMap(disjuntorReligador);

    // SAFELY CHECK THE NULLABLE TRANSFORMADOR DE CORRENTE
    if (transformadorCorrente != null) {
      total++;
      if (transformadorCorrente!.isFullyComplete) completed++;
    }

    return InspectionProgress(completed: completed, total: total);
  }
}

class Microohmimetro {
  Map<String, DynamicGroup> transformador;
  Map<String, DynamicGroup> continuidadeMalha;
  Map<String, PhaseGroup> seccionadora;
  Map<String, PhaseGroup> disjuntorReligador;

  Microohmimetro({
    Map<String, DynamicGroup>? transformador,
    Map<String, DynamicGroup>? continuidadeMalha,
    Map<String, PhaseGroup>? seccionadora,
    Map<String, PhaseGroup>? disjuntorReligador,
  }) : transformador = transformador ?? {},
       continuidadeMalha = continuidadeMalha ?? {},
       seccionadora = seccionadora ?? {},
       disjuntorReligador = disjuntorReligador ?? {};

  factory Microohmimetro.fromJson(Map<String, dynamic> json) {
    return Microohmimetro(
      transformador: _parseMapDynamic(json['Transformador']),
      continuidadeMalha: _parseMapDynamic(json['Continuidade Malha']),
      seccionadora: _parseMapPhase(json['Seccionadora']),
      disjuntorReligador: _parseMapPhase(json['Disjuntor Religador']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (transformador.isNotEmpty) {
      data['Transformador'] = transformador.map(
        (k, v) => MapEntry(k, v.toJson()),
      );
    }
    if (continuidadeMalha.isNotEmpty) {
      data['Continuidade Malha'] = continuidadeMalha.map(
        (k, v) => MapEntry(k, v.toJson()),
      );
    }
    if (seccionadora.isNotEmpty) {
      data['Seccionadora'] = seccionadora.map(
        (k, v) => MapEntry(k, v.toJson()),
      );
    }
    if (disjuntorReligador.isNotEmpty) {
      data['Disjuntor Religador'] = disjuntorReligador.map(
        (k, v) => MapEntry(k, v.toJson()),
      );
    }

    return data;
  }

  InspectionProgress getProgress() {
    int total = 0;
    int completed = 0;

    void countMap(Map<String, dynamic> map) {
      for (var eq in map.values) {
        total++;
        if ((eq is PhaseGroup && eq.isFullyComplete) ||
            (eq is DynamicGroup && eq.isFullyComplete)) {
          completed++;
        }
      }
    }

    countMap(transformador);
    countMap(continuidadeMalha);
    countMap(seccionadora);
    countMap(disjuntorReligador);

    return InspectionProgress(completed: completed, total: total);
  }
}

class Ttr {
  Map<String, DynamicGroup> transformador;
  PhaseGroup? transformadorPotencial;
  PhaseGroup? transformadorCorrente;

  Ttr({
    this.transformadorPotencial,
    this.transformadorCorrente,
    Map<String, DynamicGroup>? transformador,
  }) : transformador = transformador ?? {};

  factory Ttr.fromJson(Map<String, dynamic> json) {
    return Ttr(
      transformador: _parseMapDynamic(json['Transformador']),
      // SAFELY PARSE ONLY IF THEY EXIST IN JSON
      transformadorPotencial: json['Transformador de Potencial'] != null
          ? PhaseGroup.fromJson(json['Transformador de Potencial'])
          : null,
      transformadorCorrente: json['Transformador de Corrente'] != null
          ? PhaseGroup.fromJson(json['Transformador de Corrente'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (transformador.isNotEmpty) {
      data['Transformador'] = transformador.map(
        (k, v) => MapEntry(k, v.toJson()),
      );
    }
    // ONLY ADD TO MAP IF NOT NULL
    if (transformadorPotencial != null) {
      data['Transformador de Potencial'] = transformadorPotencial!.toJson();
    }
    if (transformadorCorrente != null) {
      data['Transformador de Corrente'] = transformadorCorrente!.toJson();
    }

    return data;
  }

  InspectionProgress getProgress() {
    int total = 0;
    int completed = 0;

    void countMap(Map<String, dynamic> map) {
      for (var eq in map.values) {
        total++;
        if ((eq is PhaseGroup && eq.isFullyComplete) ||
            (eq is DynamicGroup && eq.isFullyComplete)) {
          completed++;
        }
      }
    }

    countMap(transformador);

    // SAFELY CHECK NULLS
    if (transformadorCorrente != null) {
      total++;
      if (transformadorCorrente!.isFullyComplete) completed++;
    }

    if (transformadorPotencial != null) {
      total++;
      if (transformadorPotencial!.isFullyComplete) completed++;
    }

    return InspectionProgress(completed: completed, total: total);
  }
}

class Hipot {
  Map<String, PhaseGroup> caboMediaTensao; // Poste Cubiculo, Cubiculo Trafo

  Hipot({Map<String, PhaseGroup>? caboMediaTensao})
    : caboMediaTensao = caboMediaTensao ?? {};

  factory Hipot.fromJson(Map<String, dynamic> json) {
    // Hipot is flat in your JSON, so we just map the whole object
    return Hipot(caboMediaTensao: _parseMapPhase(json));
  }

  Map<String, dynamic> toJson() {
    return caboMediaTensao.map((k, v) => MapEntry(k, v.toJson()));
  }

  InspectionProgress getProgress() {
    int total = 0;
    int completed = 0;

    void countMap(Map<String, dynamic> map) {
      for (var eq in map.values) {
        total++;
        if ((eq is PhaseGroup && eq.isFullyComplete) ||
            (eq is DynamicGroup && eq.isFullyComplete)) {
          completed++;
        }
      }
    }

    countMap(caboMediaTensao);

    return InspectionProgress(completed: completed, total: total);
  }
}

class Terrometro {
  DynamicGroup? subestacao;
  Map<String, DynamicGroup> transformadores; // Transformador 01...08

  Terrometro({this.subestacao, Map<String, DynamicGroup>? transformadores})
    : transformadores = transformadores ?? {};

  factory Terrometro.fromJson(Map<String, dynamic> json) {
    return Terrometro(
      // SAFELY PARSE ONLY IF IT EXISTS
      subestacao: json['Subestação - Resitencia Aterramento'] != null
          ? DynamicGroup.fromJson(json['Subestação - Resitencia Aterramento'])
          : null,
      transformadores: _parseMapDynamic(
        json['Transformador - Resistencia Aterramento'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (subestacao != null) {
      data['Subestação - Resitencia Aterramento'] = subestacao!.toJson();
    }
    if (transformadores.isNotEmpty) {
      data['Transformador - Resistencia Aterramento'] = transformadores.map(
        (k, v) => MapEntry(k, v.toJson()),
      );
    }

    return data;
  }

  InspectionProgress getProgress() {
    int total = 0;
    int completed = 0;

    void countMap(Map<String, dynamic> map) {
      for (var eq in map.values) {
        total++;
        if ((eq is PhaseGroup && eq.isFullyComplete) ||
            (eq is DynamicGroup && eq.isFullyComplete)) {
          completed++;
        }
      }
    }

    // SAFELY CHECK THE NULLABLE SUBESTACAO
    if (subestacao != null && subestacao!.readings.isNotEmpty) {
      total++;
      if (subestacao!.isFullyComplete) completed++;
    }

    countMap(transformadores);

    return InspectionProgress(completed: completed, total: total);
  }
}

class ToquePasso {
  Map<String, DynamicGroup> subestacao;
  Map<String, DynamicGroup> cercamento;
  Map<String, DynamicGroup> skid;

  ToquePasso({
    Map<String, DynamicGroup>? subestacao,
    Map<String, DynamicGroup>? cercamento,
    Map<String, DynamicGroup>? skid,
  }) : subestacao = subestacao ?? {},
       cercamento = cercamento ?? {},
       skid = skid ?? {};

  factory ToquePasso.fromJson(Map<String, dynamic> json) {
    return ToquePasso(
      subestacao: _parseMapDynamic(json['Toque-Passo - Subestacao']),
      cercamento: _parseMapDynamic(json['Toque-Passo - Cercamento/Abrigo']),
      skid: _parseMapDynamic(json['Toque-Passo - SKID']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (subestacao.isNotEmpty) {
      data['Toque-Passo - Subestacao'] = subestacao.map(
        (k, v) => MapEntry(k, v.toJson()),
      );
    }
    if (cercamento.isNotEmpty) {
      data['Toque-Passo - Cercamento/Abrigo'] = cercamento.map(
        (k, v) => MapEntry(k, v.toJson()),
      );
    }
    if (skid.isNotEmpty) {
      data['Toque-Passo - SKID'] = skid.map((k, v) => MapEntry(k, v.toJson()));
    }

    return data;
  }

  InspectionProgress getProgress() {
    int total = 0;
    int completed = 0;

    void countMap(Map<String, dynamic> map) {
      for (var eq in map.values) {
        total++;
        if ((eq is PhaseGroup && eq.isFullyComplete) ||
            (eq is DynamicGroup && eq.isFullyComplete)) {
          completed++;
        }
      }
    }

    countMap(subestacao);
    countMap(cercamento);
    countMap(skid);
    return InspectionProgress(completed: completed, total: total);
  }
}

// ==========================================
// 3. ROOT CLASS & UTILS
// ==========================================

class FullInspection {
  Megohmetro megohmetro;
  Microohmimetro microohmimetro;
  Ttr ttr;
  Hipot hipot;
  Terrometro terrometro;
  ToquePasso toquePasso;

  FullInspection({
    required this.megohmetro,
    required this.microohmimetro,
    required this.ttr,
    required this.hipot,
    required this.terrometro,
    required this.toquePasso,
  });

  factory FullInspection.fromJson(Map<String, dynamic> json) {
    return FullInspection(
      megohmetro: Megohmetro.fromJson(json['Megohmetro'] ?? {}),
      microohmimetro: Microohmimetro.fromJson(json['Microohmimetro'] ?? {}),
      ttr: Ttr.fromJson(json['TTR'] ?? {}),
      hipot: Hipot.fromJson(json['Hipot'] ?? {}),
      terrometro: Terrometro.fromJson(json['Terrometro'] ?? {}),
      toquePasso: ToquePasso.fromJson(
        json,
      ), // Note: ToquePasso is split into 3 keys in root, passing root
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'Megohmetro': megohmetro.toJson(),
      'Microohmimetro': microohmimetro.toJson(),
      'TTR': ttr.toJson(),
      'Hipot': hipot.toJson(),
      'Terrometro': terrometro.toJson(),
    };

    // Because ToquePasso keys are at the root of the JSON (e.g., "Toque-Passo - Subestacao"),
    // we spread them into the main map rather than nesting them.
    data.addAll(toquePasso.toJson());

    return data;
  }
}

// Helpers to reduce code repetition
Map<String, PhaseGroup> _parseMapPhase(dynamic json) {
  if (json is! Map<String, dynamic>) return {};
  return json.map((k, v) => MapEntry(k, PhaseGroup.fromJson(v)));
}

Map<String, DynamicGroup> _parseMapDynamic(dynamic json) {
  if (json is! Map<String, dynamic>) return {};
  return json.map((k, v) => MapEntry(k, DynamicGroup.fromJson(v)));
}

// --- 1. The Progress Helper ---
class InspectionProgress {
  int completed;
  int total;

  InspectionProgress({this.completed = 0, this.total = 0});
}

// --- 2. Update PhaseGroup ---
extension PhaseGroupProgress on PhaseGroup {
  InspectionProgress getProgress() {
    int total = 0;
    int completed = 0;

    // Count main phases
    total++;
    if (faseA.isFilled) completed++;
    total++;
    if (faseB.isFilled) completed++;
    total++;
    if (faseC.isFilled) completed++;

    // Count optional phases only if they exist in the JSON
    if (faseReserva != null) {
      total++;
      if (faseReserva!.isFilled) completed++;
    }
    if (auxiliar != null) {
      total++;
      if (auxiliar!.isFilled) completed++;
    }

    return InspectionProgress(completed: completed, total: total);
  }

  bool get isFullyComplete {
    final prog = getProgress();
    return prog.completed == prog.total && prog.total > 0;
  }
}

// --- 3. Update DynamicGroup ---
extension DynamicGroupProgress on DynamicGroup {
  InspectionProgress getProgress() {
    int total = readings.length;
    int completed = readings.values.where((r) => r.isFilled).length;
    return InspectionProgress(completed: completed, total: total);
  }

  bool get isFullyComplete {
    final prog = getProgress();
    return prog.completed == prog.total && prog.total > 0;
  }
}
