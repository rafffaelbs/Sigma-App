import 'measurements.dart'; // Assuming you saved the previous classes here

class Plant {
  final String id;
  final String name;
  final String local;
  final List<UFV> ufvs;

  Plant({
    required this.id,
    required this.name,
    required this.local,
    required this.ufvs,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'local': local,
      'ufvs': { for (var ufv in ufvs) ufv.id: ufv.toMap() },
    };
  }

  // Create Plant from Map (from Firebase)
  factory Plant.fromMap(Map<String, dynamic> map) {
    var ufvsMap = map['ufvs'] as Map<String, dynamic>? ?? {};

    return Plant(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      local: map['local'] ?? '',
      ufvs: ufvsMap.values.map((x) => UFV.fromMap(x as Map<String, dynamic>)).toList(),
    );
  }
}

class UFV {
  final String id;
  final String name;
  final String fechamento;
  final String marca;
  final String nSerie;
  final double fatorK;
  final double tensaoPrimaria;
  final double relacaoNominal;
  final double tensaoSecundaria;
  final double potenciaKva;
  final double impedancia;
  final double frequencia;
  final double peso;
  final int ip;
  final String dataFabricacao;
  final double volumeOleo;
  
  final FullInspection? measurements;

  UFV({
    required this.id,
    required this.name,
    this.fechamento = '',
    this.marca = '',
    this.nSerie = '',
    this.fatorK = 0.0,
    this.tensaoPrimaria = 0.0,
    this.relacaoNominal = 0.0,
    this.tensaoSecundaria = 0.0,
    this.potenciaKva = 0.0,
    this.impedancia = 0.0,
    this.frequencia = 0.0,
    this.peso = 0.0,
    this.ip = 0,
    this.dataFabricacao = '',
    this.volumeOleo = 0.0,
    this.measurements, // Optional
  });

  // Convert UFV to Map
// Convert UFV to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'fechamento': fechamento,
      'marca': marca,
      'nSerie': nSerie,
      'fatorK': fatorK,
      'tensaoPrimaria': tensaoPrimaria,
      'relacaoNominal': relacaoNominal,
      'tensaoSecundaria': tensaoSecundaria,
      'potenciaKva': potenciaKva,
      'impedancia': impedancia,
      'frequencia': frequencia,
      'peso': peso,
      'ip': ip,
      'dataFabricacao': dataFabricacao,
      'volumeOleo': volumeOleo,
      // CORRECTED: Use a String key, and call toJson() to save the object
      'measurements': measurements?.toJson(), 
    };
  }

  // Create UFV from Map
  factory UFV.fromMap(Map<String, dynamic> map) {
    return UFV(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      fechamento: map['fechamento'] ?? '',
      marca: map['marca'] ?? '',
      nSerie: map['nSerie'] ?? '',
      fatorK: (map['fatorK'] ?? 0).toDouble(),
      tensaoPrimaria: (map['tensaoPrimaria'] ?? 0).toDouble(),
      relacaoNominal: (map['relacaoNominal'] ?? 0).toDouble(),
      tensaoSecundaria: (map['tensaoSecundaria'] ?? 0).toDouble(),
      potenciaKva: (map['potenciaKva'] ?? 0).toDouble(),
      impedancia: (map['impedancia'] ?? 0).toDouble(),
      frequencia: (map['frequencia'] ?? 0).toDouble(),
      peso: (map['peso'] ?? 0).toDouble(),
      ip: (map['ip'] ?? 0).toInt(),
      dataFabricacao: map['dataFabricacao'] ?? '',
      volumeOleo: (map['volumeOleo'] ?? 0).toDouble(),
      // CORRECTED: The parsing logic belongs here where 'map' exists
      measurements: map['measurements'] != null 
          ? FullInspection.fromJson(map['measurements']) 
          : null,
    );
  }

  UFV copyWith({
    String? name,
    String? fechamento,
    String? marca,
    String? nSerie,
    double? fatorK,
    double? tensaoPrimaria,
    double? relacaoNominal,
    double? tensaoSecundaria,
    double? potenciaKva,
    double? impedancia,
    double? frequencia,
    double? peso,
    int? ip,
    String? dataFabricacao,
    double? volumeOleo,
    FullInspection? measurements,
  }) {
    return UFV(
      id: id,
      name: name ?? this.name,
      fechamento: fechamento ?? this.fechamento,
      marca: marca ?? this.marca,
      nSerie: nSerie ?? this.nSerie,
      fatorK: fatorK ?? this.fatorK,
      tensaoPrimaria: tensaoPrimaria ?? this.tensaoPrimaria,
      relacaoNominal: relacaoNominal ?? this.relacaoNominal,
      tensaoSecundaria: tensaoSecundaria ?? this.tensaoSecundaria,
      potenciaKva: potenciaKva ?? this.potenciaKva,
      impedancia: impedancia ?? this.impedancia,
      frequencia: frequencia ?? this.frequencia,
      peso: peso ?? this.peso,
      ip: ip ?? this.ip,
      dataFabricacao: dataFabricacao ?? this.dataFabricacao,
      volumeOleo: volumeOleo ?? this.volumeOleo,
      measurements: measurements ?? this.measurements,
    );
  }
}


