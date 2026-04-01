// ignore_for_file: constant_identifier_names

/// Maps every measurement slot to its unique code.
/// Key format: "instrument|subgroup|readingLabel"
/// where instrument and subgroup use the same names used in the routing layer.
///
/// For PhaseGroup slots the reading label is "Fase A", "Fase B", "Fase C", "Fase Reserva", "Auxiliar".
/// For DynamicGroup slots the reading label is the readings map key (e.g. "H1-H3", "MALHA D=18/40").
class MeasurementCodes {
  MeasurementCodes._();

  static const Map<String, String> _codes = {
    // ================================================================
    // 0. IDENTIFICAÇÃO
    // ================================================================
    'Identificacao||': '0.0.0',

    // ================================================================
    // 1. MEGÔHMETRO
    // ================================================================

    // 1.0 Transformador (DynamicGroup readings under Megohmetro|Transformador)
    'Megohmetro|Transformador|AT x BT (GUARD - Massa)': '1.0.1',
    'Megohmetro|Transformador|AT x Massa (GUARD - BT)': '1.0.2',
    'Megohmetro|Transformador|BT x Massa (GUARD - AT)': '1.0.3',

    // 1.1 Terminação Mufla
    // equipment key "Poste" → 1.1.1
    'Megohmetro|Terminação Mufla|Poste|Fase A': '1.1.1A',
    'Megohmetro|Terminação Mufla|Poste|Fase B': '1.1.1B',
    'Megohmetro|Terminação Mufla|Poste|Fase C': '1.1.1C',
    'Megohmetro|Terminação Mufla|Poste|Fase Reserva': '1.1.1R',
    // equipment key "Entrada Cubículo" → 1.1.2
    'Megohmetro|Terminação Mufla|Entrada Cubículo|Fase A': '1.1.2A',
    'Megohmetro|Terminação Mufla|Entrada Cubículo|Fase B': '1.1.2B',
    'Megohmetro|Terminação Mufla|Entrada Cubículo|Fase C': '1.1.2C',
    'Megohmetro|Terminação Mufla|Entrada Cubículo|Fase Reserva': '1.1.2R',
    // equipment key "Saída Cubículo" → 1.1.3
    'Megohmetro|Terminação Mufla|Saída Cubículo|Fase A': '1.1.3A',
    'Megohmetro|Terminação Mufla|Saída Cubículo|Fase B': '1.1.3B',
    'Megohmetro|Terminação Mufla|Saída Cubículo|Fase C': '1.1.3C',
    'Megohmetro|Terminação Mufla|Saída Cubículo|Fase Reserva': '1.1.3R',
    // equipment key "Transformador" → 1.1.4
    'Megohmetro|Terminação Mufla|Transformador|Fase A': '1.1.4A',
    'Megohmetro|Terminação Mufla|Transformador|Fase B': '1.1.4B',
    'Megohmetro|Terminação Mufla|Transformador|Fase C': '1.1.4C',
    'Megohmetro|Terminação Mufla|Transformador|Fase Reserva': '1.1.4R',

    // 1.2 Para Raios
    'Megohmetro|Para-Raios|Poste|Fase A': '1.2.1A',
    'Megohmetro|Para-Raios|Poste|Fase B': '1.2.1B',
    'Megohmetro|Para-Raios|Poste|Fase C': '1.2.1C',
    'Megohmetro|Para-Raios|Entrada Cubículo|Fase A': '1.2.2A',
    'Megohmetro|Para-Raios|Entrada Cubículo|Fase B': '1.2.2B',
    'Megohmetro|Para-Raios|Entrada Cubículo|Fase C': '1.2.2C',
    'Megohmetro|Para-Raios|Saída Cubículo|Fase A': '1.2.3A',
    'Megohmetro|Para-Raios|Saída Cubículo|Fase B': '1.2.3B',
    'Megohmetro|Para-Raios|Saída Cubículo|Fase C': '1.2.3C',
    'Megohmetro|Para-Raios|Transformador|Fase A': '1.2.4A',
    'Megohmetro|Para-Raios|Transformador|Fase B': '1.2.4B',
    'Megohmetro|Para-Raios|Transformador|Fase C': '1.2.4C',

    // 1.3 Seccionadora
    'Megohmetro|Seccionadora|Seccionadora 01|Fase A': '1.3.1A',
    'Megohmetro|Seccionadora|Seccionadora 01|Fase B': '1.3.1B',
    'Megohmetro|Seccionadora|Seccionadora 01|Fase C': '1.3.1C',
    'Megohmetro|Seccionadora|Seccionadora 02|Fase A': '1.3.2A',
    'Megohmetro|Seccionadora|Seccionadora 02|Fase B': '1.3.2B',
    'Megohmetro|Seccionadora|Seccionadora 02|Fase C': '1.3.2C',

    // 1.4 Disjuntor Religador
    'Megohmetro|Disjuntor Religador|Aberto|Fase A': '1.4.1A',
    'Megohmetro|Disjuntor Religador|Aberto|Fase B': '1.4.1B',
    'Megohmetro|Disjuntor Religador|Aberto|Fase C': '1.4.1C',
    'Megohmetro|Disjuntor Religador|Fechado|Fase A': '1.4.2A',
    'Megohmetro|Disjuntor Religador|Fechado|Fase B': '1.4.2B',
    'Megohmetro|Disjuntor Religador|Fechado|Fase C': '1.4.2C',

    // 1.5 TCs - Transformador de Corrente (single PhaseGroup, no equipment map)
    'Megohmetro|Transformador de Corrente|Fase A': '1.5A',
    'Megohmetro|Transformador de Corrente|Fase B': '1.5B',
    'Megohmetro|Transformador de Corrente|Fase C': '1.5C',

    // ================================================================
    // 2. MICROOHMIMETRO
    // ================================================================

    // 2.0 Transformador (DynamicGroup per equipment, readings are winding labels)
    'Microohmimetro|Transformador|H1-H3': '2.0.1',
    'Microohmimetro|Transformador|H2-H1': '2.0.2',
    'Microohmimetro|Transformador|H3-H2': '2.0.3',
    'Microohmimetro|Transformador|X1-X0': '2.0.4',
    'Microohmimetro|Transformador|X2-X0': '2.0.5',
    'Microohmimetro|Transformador|X3-X0': '2.0.6',

    // 2.1 Continuidade Malha (DynamicGroup; single group, readings keyed by label)
    'Microohmimetro|Continuidade Malha|MALHA CUBÍCULO/MALHA': '2.1.1',
    'Microohmimetro|Continuidade Malha|MALHA POSTE/MALHA': '2.1.2',
    'Microohmimetro|Continuidade Malha|MALHA CERCAMENTO/MALHA': '2.1.3',
    'Microohmimetro|Continuidade Malha|SKID TRANSFORMADOR/MALHA': '2.1.4',
    'Microohmimetro|Continuidade Malha|SKID BEP/MALHA': '2.1.5',
    'Microohmimetro|Continuidade Malha|SKID INVERSOR/MALHA': '2.1.6',

    // 2.2 Seccionadora
    'Microohmimetro|Seccionadora|Seccionadora 01|Fase A': '2.2.1A',
    'Microohmimetro|Seccionadora|Seccionadora 01|Fase B': '2.2.1B',
    'Microohmimetro|Seccionadora|Seccionadora 01|Fase C': '2.2.1C',
    'Microohmimetro|Seccionadora|Seccionadora 02|Fase A': '2.2.2A',
    'Microohmimetro|Seccionadora|Seccionadora 02|Fase B': '2.2.2B',
    'Microohmimetro|Seccionadora|Seccionadora 02|Fase C': '2.2.2C',

    // 2.3 Disjuntor Religador
    'Microohmimetro|Disjuntor Religador|Fechado|Fase A': '2.3.1A',
    'Microohmimetro|Disjuntor Religador|Fechado|Fase B': '2.3.1B',
    'Microohmimetro|Disjuntor Religador|Fechado|Fase C': '2.3.1C',

    // ================================================================
    // 3. TTR
    // ================================================================

    // 3.0 Transformador (DynamicGroup readings are winding pairs)
    'TTR|Transformador|H1-H3 / X1-X0': '3.0.1',
    'TTR|Transformador|H2-H1 / X2-X0': '3.0.2',
    'TTR|Transformador|H3-H2 / X3-X0': '3.0.3',
    'TTR|Transformador|H1-H0 / X1-X3': '3.0.4',
    'TTR|Transformador|H2-H0 / X2-X1': '3.0.5',
    'TTR|Transformador|H3-H0 / X3-X2': '3.0.6',

    // 3.1 TP - Transformador de Potencial (single PhaseGroup + Auxiliar)
    'TTR|Transformador de Potencial|Fase A': '3.1A',
    'TTR|Transformador de Potencial|Fase B': '3.1B',
    'TTR|Transformador de Potencial|Fase C': '3.1C',
    'TTR|Transformador de Potencial|Auxiliar': '3.1R',

    // 3.2 TC - Transformador de Corrente (single PhaseGroup)
    'TTR|Transformador de Corrente|Fase A': '3.2A',
    'TTR|Transformador de Corrente|Fase B': '3.2B',
    'TTR|Transformador de Corrente|Fase C': '3.2C',

    // ================================================================
    // 4. HIPOT
    // ================================================================

    // 4.1 Cabo Média Tensão (Map<String, PhaseGroup>)
    'Hipot|Cabo Média Tensão|Poste Cubículo|Fase A': '4.1.1A',
    'Hipot|Cabo Média Tensão|Poste Cubículo|Fase B': '4.1.1B',
    'Hipot|Cabo Média Tensão|Poste Cubículo|Fase C': '4.1.1C',
    'Hipot|Cabo Média Tensão|Poste Cubículo|Fase Reserva': '4.1.1R',
    'Hipot|Cabo Média Tensão|Cubículo Transformador|Fase A': '4.1.2A',
    'Hipot|Cabo Média Tensão|Cubículo Transformador|Fase B': '4.1.2B',
    'Hipot|Cabo Média Tensão|Cubículo Transformador|Fase C': '4.1.2C',
    'Hipot|Cabo Média Tensão|Cubículo Transformador|Fase Reserva': '4.1.2R',

    // ================================================================
    // 5. TERRÔMETRO
    // ================================================================

    // 5.0 Subestação (single DynamicGroup)
    'Terrometro|Subestação - Resitencia Aterramento|CUBÍCULO/MALHA D=18/40': '5.0A',
    'Terrometro|Subestação - Resitencia Aterramento|CUBÍCULO/MALHA D=19/40': '5.0B',
    'Terrometro|Subestação - Resitencia Aterramento|CUBÍCULO/MALHA D=20/40': '5.0C',

    // 5.1–5.8 Transformadores (Map<String, DynamicGroup>)
    'Terrometro|Transformador - Resistencia Aterramento|Transformador 01|TRANSFORMADOR-01/MALHA D=18/40': '5.1A',
    'Terrometro|Transformador - Resistencia Aterramento|Transformador 01|TRANSFORMADOR-01/MALHA D=19/40': '5.1B',
    'Terrometro|Transformador - Resistencia Aterramento|Transformador 01|TRANSFORMADOR-01/MALHA D=20/40': '5.1C',
    'Terrometro|Transformador - Resistencia Aterramento|Transformador 02|TRANSFORMADOR-02/MALHA D=18/40': '5.2A',
    'Terrometro|Transformador - Resistencia Aterramento|Transformador 02|TRANSFORMADOR-02/MALHA D=19/40': '5.2B',
    'Terrometro|Transformador - Resistencia Aterramento|Transformador 02|TRANSFORMADOR-02/MALHA D=20/40': '5.2C',
    'Terrometro|Transformador - Resistencia Aterramento|Transformador 03|TRANSFORMADOR-03/MALHA D=18/40': '5.3A',
    'Terrometro|Transformador - Resistencia Aterramento|Transformador 03|TRANSFORMADOR-03/MALHA D=19/40': '5.3B',
    'Terrometro|Transformador - Resistencia Aterramento|Transformador 03|TRANSFORMADOR-03/MALHA D=20/40': '5.3C',
    'Terrometro|Transformador - Resistencia Aterramento|Transformador 04|TRANSFORMADOR-04/MALHA D=18/40': '5.4A',
    'Terrometro|Transformador - Resistencia Aterramento|Transformador 04|TRANSFORMADOR-04/MALHA D=19/40': '5.4B',
    'Terrometro|Transformador - Resistencia Aterramento|Transformador 04|TRANSFORMADOR-04/MALHA D=20/40': '5.4C',
    'Terrometro|Transformador - Resistencia Aterramento|Transformador 05|TRANSFORMADOR-05/MALHA D=18/40': '5.5A',
    'Terrometro|Transformador - Resistencia Aterramento|Transformador 05|TRANSFORMADOR-05/MALHA D=19/40': '5.5B',
    'Terrometro|Transformador - Resistencia Aterramento|Transformador 05|TRANSFORMADOR-05/MALHA D=20/40': '5.5C',
    'Terrometro|Transformador - Resistencia Aterramento|Transformador 06|TRANSFORMADOR-06/MALHA D=18/40': '5.6A',
    'Terrometro|Transformador - Resistencia Aterramento|Transformador 06|TRANSFORMADOR-06/MALHA D=19/40': '5.6B',
    'Terrometro|Transformador - Resistencia Aterramento|Transformador 06|TRANSFORMADOR-06/MALHA D=20/40': '5.6C',
    'Terrometro|Transformador - Resistencia Aterramento|Transformador 07|TRANSFORMADOR-07/MALHA D=18/40': '5.7A',
    'Terrometro|Transformador - Resistencia Aterramento|Transformador 07|TRANSFORMADOR-07/MALHA D=19/40': '5.7B',
    'Terrometro|Transformador - Resistencia Aterramento|Transformador 07|TRANSFORMADOR-07/MALHA D=20/40': '5.7C',
    'Terrometro|Transformador - Resistencia Aterramento|Transformador 08|TRANSFORMADOR-08/MALHA D=18/40': '5.8A',
    'Terrometro|Transformador - Resistencia Aterramento|Transformador 08|TRANSFORMADOR-08/MALHA D=19/40': '5.8B',
    'Terrometro|Transformador - Resistencia Aterramento|Transformador 08|TRANSFORMADOR-08/MALHA D=20/40': '5.8C',

    // ================================================================
    // 6. TOQUE E PASSO (Terrômetro Alta Frequência)
    // ================================================================

    // 6.0 Subestação
    'Toque-Passo|Toque-Passo - Subestacao|Cubículo Proteção Geral|CUBÍCULO PROTEÇÃO GERAL - TOQUE': '6.0.0',
    'Toque-Passo|Toque-Passo - Subestacao|Cubículo Proteção Geral|CUBÍCULO PROTEÇÃO GERAL - PASSO 1m': '6.0.0.A',
    'Toque-Passo|Toque-Passo - Subestacao|Cubículo Proteção Geral|CUBÍCULO PROTEÇÃO GERAL - PASSO 5m': '6.0.0.B',
    'Toque-Passo|Toque-Passo - Subestacao|Cubículo Proteção/Medição 01|CUBÍCULO PROTEÇÃO/MEDIÇÃO 01 - TOQUE': '6.0.1',
    'Toque-Passo|Toque-Passo - Subestacao|Cubículo Proteção/Medição 02|CUBÍCULO PROTEÇÃO/MEDIÇÃO 02 - TOQUE': '6.0.2',
    'Toque-Passo|Toque-Passo - Subestacao|Cubículo Proteção/Medição 03|CUBÍCULO PROTEÇÃO/MEDIÇÃO 03 - TOQUE': '6.0.3',
    'Toque-Passo|Toque-Passo - Subestacao|Cubículo Proteção/Medição 04|CUBÍCULO PROTEÇÃO/MEDIÇÃO 04 - TOQUE': '6.0.4',
    'Toque-Passo|Toque-Passo - Subestacao|Cubículo Proteção/Medição 05|CUBÍCULO PROTEÇÃO/MEDIÇÃO 05 - TOQUE': '6.0.5',
    'Toque-Passo|Toque-Passo - Subestacao|Cubículo Proteção/Medição 06|CUBÍCULO PROTEÇÃO/MEDIÇÃO 06 - TOQUE': '6.0.6',
    'Toque-Passo|Toque-Passo - Subestacao|Cubículo Proteção/Medição 07|CUBÍCULO PROTEÇÃO/MEDIÇÃO 07 - TOQUE': '6.0.7',
    'Toque-Passo|Toque-Passo - Subestacao|Cubículo Proteção/Medição 08|CUBÍCULO PROTEÇÃO/MEDIÇÃO 08 - TOQUE': '6.0.8',

    // 6.1 Cercamento / Abrigo
    'Toque-Passo|Toque-Passo - Cercamento/Abrigo|Portão/Porta Acesso|PORTÃO/PORTA ACESSO - TOQUE': '6.1.0',
    'Toque-Passo|Toque-Passo - Cercamento/Abrigo|Portão/Porta Acesso|PORTÃO/PORTA ACESSO - PASSO 1m': '6.1.0.A',
    'Toque-Passo|Toque-Passo - Cercamento/Abrigo|Portão/Porta Acesso|PORTÃO/PORTA ACESSO - PASSO 5m': '6.1.0.B',
    'Toque-Passo|Toque-Passo - Cercamento/Abrigo|Alambrado|ALAMBRADO - TOQUE': '6.1.1',
    'Toque-Passo|Toque-Passo - Cercamento/Abrigo|Gradil Interno|GRADIL INTERNO - TOQUE': '6.1.2',
    'Toque-Passo|Toque-Passo - Cercamento/Abrigo|Componentes Metálicos|COMPONENTES METÁLICOS - TOQUE': '6.1.3',

    // 6.2 SKID
    'Toque-Passo|Toque-Passo - SKID|Transformador/QGBT|TRANSFORMADOR/QGBT - TOQUE': '6.2.0',
    'Toque-Passo|Toque-Passo - SKID|Transformador/QGBT|TRANSFORMADOR/QGBT - PASSO 1m': '6.2.0.A',
    'Toque-Passo|Toque-Passo - SKID|Transformador/QGBT|TRANSFORMADOR/QGBT - PASSO 5m': '6.2.0.B',
    'Toque-Passo|Toque-Passo - SKID|Inversores|INVERSORES - TOQUE': '6.2.1',
    'Toque-Passo|Toque-Passo - SKID|Inversores|INVERSORES - PASSO 1m': '6.2.1.A',
    'Toque-Passo|Toque-Passo - SKID|Inversores|INVERSORES - PASSO 5m': '6.2.1.B',
    'Toque-Passo|Toque-Passo - SKID|QGBT|QGBT - TOQUE': '6.2.2',
    'Toque-Passo|Toque-Passo - SKID|Quadro BT|QUADRO BT - TOQUE': '6.2.3',
    'Toque-Passo|Toque-Passo - SKID|Container Metálico|CONTAINER METÁLICO - TOQUE': '6.2.4',
    'Toque-Passo|Toque-Passo - SKID|Cercamento UFV|CERCAMENTO UFV - TOQUE': '6.2.5',
    'Toque-Passo|Toque-Passo - SKID|Estrutura Fixação FV|ESTRUTURA FIXAÇÃO FV - TOQUE': '6.2.6',
    'Toque-Passo|Toque-Passo - SKID|Módulos|MÓDULOS - TOQUE': '6.2.7',
    'Toque-Passo|Toque-Passo - SKID|Módulos|MÓDULOS - PASSO 1m': '6.2.7.A',
    'Toque-Passo|Toque-Passo - SKID|Módulos|MÓDULOS - PASSO 5m': '6.2.7.B',
  };

  /// Look up a code for a PhaseGroup reading.
  /// [instrument] — e.g. "Megohmetro", "TTR"
  /// [subgroup]   — e.g. "Terminação Mufla", "Transformador de Corrente"
  /// [equipment]  — the equipment map key, or "" for single-group slots
  /// [phase]      — "Fase A", "Fase B", "Fase C", "Fase Reserva", "Auxiliar"
  static String forPhase(
    String instrument,
    String subgroup,
    String equipment,
    String phase,
  ) {
    final key = equipment.isEmpty
        ? '$instrument|$subgroup|$phase'
        : '$instrument|$subgroup|$equipment|$phase';
    return _codes[key] ?? '';
  }

  /// Look up a code for a DynamicGroup reading.
  /// [instrument] — e.g. "Microohmimetro", "Terrometro"
  /// [subgroup]   — e.g. "Transformador", "Continuidade Malha"
  /// [equipment]  — the equipment map key (outer map), or "" for single DynamicGroup slots
  /// [readingKey] — the readings map key (e.g. "H1-H3", "MALHA CUBÍCULO/MALHA")
  static String forDynamic(
    String instrument,
    String subgroup,
    String equipment,
    String readingKey,
  ) {
    final key = equipment.isEmpty
        ? '$instrument|$subgroup|$readingKey'
        : '$instrument|$subgroup|$equipment|$readingKey';
    return _codes[key] ?? '';
  }
}
