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
  // -----------------------------------------
  // 1. DADOS ORIGINAIS / TRANSFORMADOR
  // -----------------------------------------
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
  
  // -----------------------------------------
  // 2. PROJETO E AMBIENTE 
  // -----------------------------------------
  final String tempAmbiente;
  final String umidade;
  final String classeKv;
 
  // -----------------------------------------
  // 3. SISTEMAS DE PROTEÇÃO
  // -----------------------------------------
  final String estadoGeralProtecaoGeral;
  final String releProtecaoGeral;
  final String nobreakGeral;
  final String seccionamentoGeral;
  
  final String estadoGeralProtecaoLocal;
  final String releProtecaoLocal;
  final String nobreakLocal;
  final String seccionamentoLocal;

  // -----------------------------------------
  // 4. INSPEÇÃO VISUAL E PROTEÇÕES FÍSICAS
  // -----------------------------------------
  final String estadoGeralInspecao;
  // Inspeção Visual
  final String bobina1;
  final String bobina2;
  final String bobina3;
  final String h0BuchaMt;
  final String h1BuchaMt;
  final String h2BuchaMt;
  final String h3BuchaMt;
  final String x0BuchaBt;
  final String x1BuchaBt;
  final String x2BuchaBt;
  final String x3BuchaBt;
  final String vazamentoOleoCarcaca;
  // Proteções Físicas
  final String releTemperaturaDigital;
  final String pt100Bobina1;
  final String pt100Bobina2;
  final String pt100Bobina3;
  final String ventilacaoForcada;
  final String pt100TermometroOleo;
  final String pressostatoOleo;
  final String nivelOleo;
  final String analiseOleo;

  // -----------------------------------------
  // 5. EQUIPE E OBSERVAÇÕES
  // -----------------------------------------
  final String executanteNome;
  final String executanteCft;
  final String engenheiroNome;
  final String engenheiroCrea;
  final String observacoes;

  // -----------------------------------------
  // MEASUREMENTS (Optional)
  // -----------------------------------------
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
    
    this.tempAmbiente = '',
    this.umidade = '',
    this.classeKv = '',
    
    this.estadoGeralProtecaoGeral = 'Bom',
    this.releProtecaoGeral = 'OK',
    this.nobreakGeral = 'OK',
    this.seccionamentoGeral = 'OK',
    
    this.estadoGeralProtecaoLocal = 'Bom',
    this.releProtecaoLocal = 'OK',
    this.nobreakLocal = 'OK',
    this.seccionamentoLocal = 'OK',
    
    this.estadoGeralInspecao = 'Bom',
    this.bobina1 = 'OK',
    this.bobina2 = 'OK',
    this.bobina3 = 'OK',
    this.h0BuchaMt = 'NA',
    this.h1BuchaMt = 'OK',
    this.h2BuchaMt = 'OK',
    this.h3BuchaMt = 'OK',
    this.x0BuchaBt = 'OK',
    this.x1BuchaBt = 'OK',
    this.x2BuchaBt = 'OK',
    this.x3BuchaBt = 'OK',
    this.vazamentoOleoCarcaca = 'NA',

    this.releTemperaturaDigital = 'NA',
    this.pt100Bobina1 = 'OK',
    this.pt100Bobina2 = 'OK',
    this.pt100Bobina3 = 'OK',
    this.ventilacaoForcada = 'NA',
    this.pt100TermometroOleo = 'NA',
    this.pressostatoOleo = 'NA',
    this.nivelOleo = 'NA',
    this.analiseOleo = 'NA',
    
    this.executanteNome = '',
    this.executanteCft = '',
    this.engenheiroNome = '',
    this.engenheiroCrea = '',
    this.observacoes = '',

    this.measurements, 
  });

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

      'tempAmbiente': tempAmbiente,
      'umidade': umidade,
      'classeKv': classeKv,
      
      'estadoGeralProtecaoGeral': estadoGeralProtecaoGeral,
      'releProtecaoGeral': releProtecaoGeral,
      'nobreakGeral': nobreakGeral,
      'seccionamentoGeral': seccionamentoGeral,
      
      'estadoGeralProtecaoLocal': estadoGeralProtecaoLocal,
      'releProtecaoLocal': releProtecaoLocal,
      'nobreakLocal': nobreakLocal,
      'seccionamentoLocal': seccionamentoLocal,

      'estadoGeralInspecao': estadoGeralInspecao,
      'bobina1': bobina1,
      'bobina2': bobina2,
      'bobina3': bobina3,
      'h0BuchaMt': h0BuchaMt,
      'h1BuchaMt': h1BuchaMt,
      'h2BuchaMt': h2BuchaMt,
      'h3BuchaMt': h3BuchaMt,
      'x0BuchaBt': x0BuchaBt,
      'x1BuchaBt': x1BuchaBt,
      'x2BuchaBt': x2BuchaBt,
      'x3BuchaBt': x3BuchaBt,
      'vazamentoOleoCarcaca': vazamentoOleoCarcaca,

      'releTemperaturaDigital': releTemperaturaDigital,
      'pt100Bobina1': pt100Bobina1,
      'pt100Bobina2': pt100Bobina2,
      'pt100Bobina3': pt100Bobina3,
      'ventilacaoForcada': ventilacaoForcada,
      'pt100TermometroOleo': pt100TermometroOleo,
      'pressostatoOleo': pressostatoOleo,
      'nivelOleo': nivelOleo,
      'analiseOleo': analiseOleo,

      'executanteNome': executanteNome,
      'executanteCft': executanteCft,
      'engenheiroNome': engenheiroNome,
      'engenheiroCrea': engenheiroCrea,
      'observacoes': observacoes,

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

      tempAmbiente: map['tempAmbiente'] ?? '',
      umidade: map['umidade'] ?? '',
      classeKv: map['classeKv'] ?? '',

      estadoGeralProtecaoGeral: map['estadoGeralProtecaoGeral'] ?? 'Bom',
      releProtecaoGeral: map['releProtecaoGeral'] ?? 'OK',
      nobreakGeral: map['nobreakGeral'] ?? 'OK',
      seccionamentoGeral: map['seccionamentoGeral'] ?? 'OK',
      
      estadoGeralProtecaoLocal: map['estadoGeralProtecaoLocal'] ?? 'Bom',
      releProtecaoLocal: map['releProtecaoLocal'] ?? 'OK',
      nobreakLocal: map['nobreakLocal'] ?? 'OK',
      seccionamentoLocal: map['seccionamentoLocal'] ?? 'OK',

      estadoGeralInspecao: map['estadoGeralInspecao'] ?? 'Bom',
      bobina1: map['bobina1'] ?? 'OK',
      bobina2: map['bobina2'] ?? 'OK',
      bobina3: map['bobina3'] ?? 'OK',
      h0BuchaMt: map['h0BuchaMt'] ?? 'NA',
      h1BuchaMt: map['h1BuchaMt'] ?? 'OK',
      h2BuchaMt: map['h2BuchaMt'] ?? 'OK',
      h3BuchaMt: map['h3BuchaMt'] ?? 'OK',
      x0BuchaBt: map['x0BuchaBt'] ?? 'OK',
      x1BuchaBt: map['x1BuchaBt'] ?? 'OK',
      x2BuchaBt: map['x2BuchaBt'] ?? 'OK',
      x3BuchaBt: map['x3BuchaBt'] ?? 'OK',
      vazamentoOleoCarcaca: map['vazamentoOleoCarcaca'] ?? 'NA',

      releTemperaturaDigital: map['releTemperaturaDigital'] ?? 'NA',
      pt100Bobina1: map['pt100Bobina1'] ?? 'OK',
      pt100Bobina2: map['pt100Bobina2'] ?? 'OK',
      pt100Bobina3: map['pt100Bobina3'] ?? 'OK',
      ventilacaoForcada: map['ventilacaoForcada'] ?? 'NA',
      pt100TermometroOleo: map['pt100TermometroOleo'] ?? 'NA',
      pressostatoOleo: map['pressostatoOleo'] ?? 'NA',
      nivelOleo: map['nivelOleo'] ?? 'NA',
      analiseOleo: map['analiseOleo'] ?? 'NA',

      executanteNome: map['executanteNome'] ?? '',
      executanteCft: map['executanteCft'] ?? '',
      engenheiroNome: map['engenheiroNome'] ?? '',
      engenheiroCrea: map['engenheiroCrea'] ?? '',
      observacoes: map['observacoes'] ?? '',

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
    
    String? tempAmbiente,
    String? umidade,
    String? classeKv,
    
    String? estadoGeralProtecaoGeral,
    String? releProtecaoGeral,
    String? nobreakGeral,
    String? seccionamentoGeral,
    
    String? estadoGeralProtecaoLocal,
    String? releProtecaoLocal,
    String? nobreakLocal,
    String? seccionamentoLocal,

    String? estadoGeralInspecao,
    String? bobina1,
    String? bobina2,
    String? bobina3,
    String? h0BuchaMt,
    String? h1BuchaMt,
    String? h2BuchaMt,
    String? h3BuchaMt,
    String? x0BuchaBt,
    String? x1BuchaBt,
    String? x2BuchaBt,
    String? x3BuchaBt,
    String? vazamentoOleoCarcaca,

    String? releTemperaturaDigital,
    String? pt100Bobina1,
    String? pt100Bobina2,
    String? pt100Bobina3,
    String? ventilacaoForcada,
    String? pt100TermometroOleo,
    String? pressostatoOleo,
    String? nivelOleo,
    String? analiseOleo,
    
    String? executanteNome,
    String? executanteCft,
    String? engenheiroNome,
    String? engenheiroCrea,
    String? observacoes,

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

      tempAmbiente: tempAmbiente ?? this.tempAmbiente,
      umidade: umidade ?? this.umidade,
      classeKv: classeKv ?? this.classeKv,
 
      estadoGeralProtecaoGeral: estadoGeralProtecaoGeral ?? this.estadoGeralProtecaoGeral,
      releProtecaoGeral: releProtecaoGeral ?? this.releProtecaoGeral,
      nobreakGeral: nobreakGeral ?? this.nobreakGeral,
      seccionamentoGeral: seccionamentoGeral ?? this.seccionamentoGeral,

      estadoGeralProtecaoLocal: estadoGeralProtecaoLocal ?? this.estadoGeralProtecaoLocal,
      releProtecaoLocal: releProtecaoLocal ?? this.releProtecaoLocal,
      nobreakLocal: nobreakLocal ?? this.nobreakLocal,
      seccionamentoLocal: seccionamentoLocal ?? this.seccionamentoLocal,

      estadoGeralInspecao: estadoGeralInspecao ?? this.estadoGeralInspecao,
      bobina1: bobina1 ?? this.bobina1,
      bobina2: bobina2 ?? this.bobina2,
      bobina3: bobina3 ?? this.bobina3,
      h0BuchaMt: h0BuchaMt ?? this.h0BuchaMt,
      h1BuchaMt: h1BuchaMt ?? this.h1BuchaMt,
      h2BuchaMt: h2BuchaMt ?? this.h2BuchaMt,
      h3BuchaMt: h3BuchaMt ?? this.h3BuchaMt,
      x0BuchaBt: x0BuchaBt ?? this.x0BuchaBt,
      x1BuchaBt: x1BuchaBt ?? this.x1BuchaBt,
      x2BuchaBt: x2BuchaBt ?? this.x2BuchaBt,
      x3BuchaBt: x3BuchaBt ?? this.x3BuchaBt,
      vazamentoOleoCarcaca: vazamentoOleoCarcaca ?? this.vazamentoOleoCarcaca,

      releTemperaturaDigital: releTemperaturaDigital ?? this.releTemperaturaDigital,
      pt100Bobina1: pt100Bobina1 ?? this.pt100Bobina1,
      pt100Bobina2: pt100Bobina2 ?? this.pt100Bobina2,
      pt100Bobina3: pt100Bobina3 ?? this.pt100Bobina3,
      ventilacaoForcada: ventilacaoForcada ?? this.ventilacaoForcada,
      pt100TermometroOleo: pt100TermometroOleo ?? this.pt100TermometroOleo,
      pressostatoOleo: pressostatoOleo ?? this.pressostatoOleo,
      nivelOleo: nivelOleo ?? this.nivelOleo,
      analiseOleo: analiseOleo ?? this.analiseOleo,

      executanteNome: executanteNome ?? this.executanteNome,
      executanteCft: executanteCft ?? this.executanteCft,
      engenheiroNome: engenheiroNome ?? this.engenheiroNome,
      engenheiroCrea: engenheiroCrea ?? this.engenheiroCrea,
      observacoes: observacoes ?? this.observacoes,

      measurements: measurements ?? this.measurements,
    );
  }
}