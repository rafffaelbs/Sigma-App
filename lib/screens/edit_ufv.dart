import 'package:flutter/material.dart';
import 'package:sigma_app/models/plant_model.dart';
import 'package:sigma_app/services/plant_service.dart';
import 'package:sigma_app/widgets/custom_header.dart';
import 'package:sigma_app/widgets/plant_button.dart';

class EditUfv extends StatefulWidget {
  final Plant plant;
  final UFV ufv;

  const EditUfv({super.key, required this.plant, required this.ufv});

  @override
  State<EditUfv> createState() => _EditUfvState();
}

class _EditUfvState extends State<EditUfv> {
  // --- DROPDOWN OPTIONS ---
  final List<String> fechamentoOptions = ['Delta', 'Estrela'];
  final List<String> marcaOptions = ['WEG', 'Siemens', 'ABB'];
  final List<String> statusGeralOptions = ['Bom', 'Regular', 'Ruim', 'NA'];
  final List<String> statusItemOptions = ['OK', 'Avaria', 'NA'];

  // --- HARDCODED EQUIPE MAPS ---
  final Map<String, String> executantesMap = {
    'LUIZ ANTÔNIO BARBOSA': '02127271173',
    'OUTRO EXECUTANTE': '12345678900',
  };

  final Map<String, String> engenheirosMap = {
    'THALLES NUNES': '20287/D-GO',
    'OUTRO ENGENHEIRO': '12345/D-GO',
  };

  // --- CONTROLLERS: DADOS DO TRANSFORMADOR ---
  late TextEditingController fechamentoController;
  late TextEditingController marcaController;
  late TextEditingController nSerieController;
  late TextEditingController fatorKController;
  late TextEditingController tensaoPrimariaController;
  late TextEditingController relacaoNominalController;
  late TextEditingController tensaoSecundariaController;
  late TextEditingController potenciaKvaController;
  late TextEditingController impedanciaController;
  late TextEditingController frequenciaController;
  late TextEditingController pesoController;
  late TextEditingController ipController;
  late TextEditingController dataFabricacaoController;
  late TextEditingController volumeOleoController;

  // --- CONTROLLERS: PROJETO E AMBIENTE ---
  late TextEditingController tempAmbienteController;
  late TextEditingController umidadeController;
  late TextEditingController classeKvController;

  // --- CONTROLLERS: PROTEÇÃO GERAL E LOCAL ---
  late TextEditingController estadoGeralProtecaoGeralController;
  late TextEditingController releProtecaoGeralController;
  late TextEditingController nobreakGeralController;
  late TextEditingController seccionamentoGeralController;

  late TextEditingController estadoGeralProtecaoLocalController;
  late TextEditingController releProtecaoLocalController;
  late TextEditingController nobreakLocalController;
  late TextEditingController seccionamentoLocalController;

  // --- CONTROLLERS: INSPEÇÃO VISUAL (Novos) ---
  late TextEditingController estadoGeralInspecaoController;
  late TextEditingController bobina1Controller;
  late TextEditingController bobina2Controller;
  late TextEditingController bobina3Controller;
  late TextEditingController h0BuchaMtController;
  late TextEditingController h1BuchaMtController;
  late TextEditingController h2BuchaMtController;
  late TextEditingController h3BuchaMtController;
  late TextEditingController x0BuchaBtController;
  late TextEditingController x1BuchaBtController;
  late TextEditingController x2BuchaBtController;
  late TextEditingController x3BuchaBtController;
  late TextEditingController vazamentoOleoCarcacaController;

  // --- CONTROLLERS: PROTEÇÕES FÍSICAS (Novos) ---
  late TextEditingController releTemperaturaDigitalController;
  late TextEditingController pt100Bobina1Controller;
  late TextEditingController pt100Bobina2Controller;
  late TextEditingController pt100Bobina3Controller;
  late TextEditingController ventilacaoForcadaController;
  late TextEditingController pt100TermometroOleoController;
  late TextEditingController pressostatoOleoController;
  late TextEditingController nivelOleoController;
  late TextEditingController analiseOleoController;

  // --- CONTROLLERS: ASSINATURAS E OBSERVAÇÕES ---
  late TextEditingController executanteNomeController;
  late TextEditingController engenheiroNomeController;
  late TextEditingController observacoesController;

  @override
  void initState() {
    super.initState();

    // 1. Init Transformer
    fechamentoController = TextEditingController(text: widget.ufv.fechamento);
    marcaController = TextEditingController(text: widget.ufv.marca);
    nSerieController = TextEditingController(text: widget.ufv.nSerie);
    fatorKController = TextEditingController(
      text: widget.ufv.fatorK.toString(),
    );
    tensaoPrimariaController = TextEditingController(
      text: widget.ufv.tensaoPrimaria.toString(),
    );
    relacaoNominalController = TextEditingController(
      text: widget.ufv.relacaoNominal.toString(),
    );
    tensaoSecundariaController = TextEditingController(
      text: widget.ufv.tensaoSecundaria.toString(),
    );
    potenciaKvaController = TextEditingController(
      text: widget.ufv.potenciaKva.toString(),
    );
    impedanciaController = TextEditingController(
      text: widget.ufv.impedancia.toString(),
    );
    frequenciaController = TextEditingController(
      text: widget.ufv.frequencia.toString(),
    );
    pesoController = TextEditingController(text: widget.ufv.peso.toString());
    ipController = TextEditingController(text: widget.ufv.ip.toString());
    dataFabricacaoController = TextEditingController(
      text: widget.ufv.dataFabricacao,
    );
    volumeOleoController = TextEditingController(
      text: widget.ufv.volumeOleo.toString(),
    );

    // 2. Init Projeto e Ambiente
    tempAmbienteController = TextEditingController(
      text: widget.ufv.tempAmbiente,
    );
    umidadeController = TextEditingController(text: widget.ufv.umidade);
    classeKvController = TextEditingController(text: widget.ufv.classeKv);

    // 3. Init Proteção Geral e Local
    estadoGeralProtecaoGeralController = TextEditingController(text: 'Bom');
    releProtecaoGeralController = TextEditingController(text: 'OK');
    nobreakGeralController = TextEditingController(text: 'OK');
    seccionamentoGeralController = TextEditingController(text: 'OK');

    estadoGeralProtecaoLocalController = TextEditingController(text: 'Bom');
    releProtecaoLocalController = TextEditingController(text: 'OK');
    nobreakLocalController = TextEditingController(text: 'OK');
    seccionamentoLocalController = TextEditingController(text: 'OK');

    // 4. Init Inspeção Visual
    estadoGeralInspecaoController = TextEditingController(text: 'Bom');
    bobina1Controller = TextEditingController(text: 'OK');
    bobina2Controller = TextEditingController(text: 'OK');
    bobina3Controller = TextEditingController(text: 'OK');
    h0BuchaMtController = TextEditingController(text: 'NA');
    h1BuchaMtController = TextEditingController(text: 'OK');
    h2BuchaMtController = TextEditingController(text: 'OK');
    h3BuchaMtController = TextEditingController(text: 'OK');
    x0BuchaBtController = TextEditingController(text: 'OK');
    x1BuchaBtController = TextEditingController(text: 'OK');
    x2BuchaBtController = TextEditingController(text: 'OK');
    x3BuchaBtController = TextEditingController(text: 'OK');
    vazamentoOleoCarcacaController = TextEditingController(text: 'NA');

    // 5. Init Proteções Físicas
    releTemperaturaDigitalController = TextEditingController(text: 'NA');
    pt100Bobina1Controller = TextEditingController(text: 'OK');
    pt100Bobina2Controller = TextEditingController(text: 'OK');
    pt100Bobina3Controller = TextEditingController(text: 'OK');
    ventilacaoForcadaController = TextEditingController(text: 'NA');
    pt100TermometroOleoController = TextEditingController(text: 'NA');
    pressostatoOleoController = TextEditingController(text: 'NA');
    nivelOleoController = TextEditingController(text: 'NA');
    analiseOleoController = TextEditingController(text: 'NA');

    // 6. Init Assinaturas e Obs
    executanteNomeController = TextEditingController(
      text: widget.ufv.executanteNome,
    );
    engenheiroNomeController = TextEditingController(
      text: widget.ufv.engenheiroNome,
    );
    observacoesController = TextEditingController(text: widget.ufv.observacoes);
  }

  @override
  void dispose() {
    fechamentoController.dispose();
    marcaController.dispose();
    nSerieController.dispose();
    fatorKController.dispose();
    tensaoPrimariaController.dispose();
    relacaoNominalController.dispose();
    tensaoSecundariaController.dispose();
    potenciaKvaController.dispose();
    impedanciaController.dispose();
    frequenciaController.dispose();
    pesoController.dispose();
    ipController.dispose();
    dataFabricacaoController.dispose();
    volumeOleoController.dispose();

    tempAmbienteController.dispose();
    umidadeController.dispose();
    classeKvController.dispose();

    estadoGeralProtecaoGeralController.dispose();
    releProtecaoGeralController.dispose();
    nobreakGeralController.dispose();
    seccionamentoGeralController.dispose();

    estadoGeralProtecaoLocalController.dispose();
    releProtecaoLocalController.dispose();
    nobreakLocalController.dispose();
    seccionamentoLocalController.dispose();

    estadoGeralInspecaoController.dispose();
    bobina1Controller.dispose();
    bobina2Controller.dispose();
    bobina3Controller.dispose();
    h0BuchaMtController.dispose();
    h1BuchaMtController.dispose();
    h2BuchaMtController.dispose();
    h3BuchaMtController.dispose();
    x0BuchaBtController.dispose();
    x1BuchaBtController.dispose();
    x2BuchaBtController.dispose();
    x3BuchaBtController.dispose();
    vazamentoOleoCarcacaController.dispose();

    releTemperaturaDigitalController.dispose();
    pt100Bobina1Controller.dispose();
    pt100Bobina2Controller.dispose();
    pt100Bobina3Controller.dispose();
    ventilacaoForcadaController.dispose();
    pt100TermometroOleoController.dispose();
    pressostatoOleoController.dispose();
    nivelOleoController.dispose();
    analiseOleoController.dispose();

    executanteNomeController.dispose();
    engenheiroNomeController.dispose();
    observacoesController.dispose();

    super.dispose();
  }

  void _saveChanges() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final updatedUfv = widget.ufv.copyWith(
        // -- DADOS DE PLACA --
        fechamento: fechamentoController.text,
        marca: marcaController.text,
        nSerie: nSerieController.text,
        fatorK: double.tryParse(fatorKController.text) ?? widget.ufv.fatorK,
        tensaoPrimaria: double.tryParse(tensaoPrimariaController.text) ?? widget.ufv.tensaoPrimaria,
        relacaoNominal: double.tryParse(relacaoNominalController.text) ?? widget.ufv.relacaoNominal,
        tensaoSecundaria: double.tryParse(tensaoSecundariaController.text) ?? widget.ufv.tensaoSecundaria,
        potenciaKva: double.tryParse(potenciaKvaController.text) ?? widget.ufv.potenciaKva,
        impedancia: double.tryParse(impedanciaController.text) ?? widget.ufv.impedancia,
        frequencia: double.tryParse(frequenciaController.text) ?? widget.ufv.frequencia,
        peso: double.tryParse(pesoController.text) ?? widget.ufv.peso,
        ip: int.tryParse(ipController.text) ?? widget.ufv.ip,
        dataFabricacao: dataFabricacaoController.text,
        volumeOleo: double.tryParse(volumeOleoController.text) ?? widget.ufv.volumeOleo,
        
        // -- PROJETO E AMBIENTE --
        tempAmbiente: tempAmbienteController.text,
        umidade: umidadeController.text,
        classeKv: classeKvController.text,
        
        // -- PROTEÇÃO GERAL --
        estadoGeralProtecaoGeral: estadoGeralProtecaoGeralController.text,
        releProtecaoGeral: releProtecaoGeralController.text,
        nobreakGeral: nobreakGeralController.text,
        seccionamentoGeral: seccionamentoGeralController.text,

        // -- PROTEÇÃO LOCAL --
        estadoGeralProtecaoLocal: estadoGeralProtecaoLocalController.text,
        releProtecaoLocal: releProtecaoLocalController.text,
        nobreakLocal: nobreakLocalController.text,
        seccionamentoLocal: seccionamentoLocalController.text,

        // -- INSPEÇÃO VISUAL E FÍSICA --
        estadoGeralInspecao: estadoGeralInspecaoController.text,
        bobina1: bobina1Controller.text,
        bobina2: bobina2Controller.text,
        bobina3: bobina3Controller.text,
        h0BuchaMt: h0BuchaMtController.text,
        h1BuchaMt: h1BuchaMtController.text,
        h2BuchaMt: h2BuchaMtController.text,
        h3BuchaMt: h3BuchaMtController.text,
        x0BuchaBt: x0BuchaBtController.text,
        x1BuchaBt: x1BuchaBtController.text,
        x2BuchaBt: x2BuchaBtController.text,
        x3BuchaBt: x3BuchaBtController.text,
        vazamentoOleoCarcaca: vazamentoOleoCarcacaController.text,

        releTemperaturaDigital: releTemperaturaDigitalController.text,
        pt100Bobina1: pt100Bobina1Controller.text,
        pt100Bobina2: pt100Bobina2Controller.text,
        pt100Bobina3: pt100Bobina3Controller.text,
        ventilacaoForcada: ventilacaoForcadaController.text,
        pt100TermometroOleo: pt100TermometroOleoController.text,
        pressostatoOleo: pressostatoOleoController.text,
        nivelOleo: nivelOleoController.text,
        analiseOleo: analiseOleoController.text,

        // -- OBSERVAÇÕES E ASSINATURAS --
        observacoes: observacoesController.text,
        executanteNome: executanteNomeController.text,
        executanteCft: executantesMap[executanteNomeController.text] ?? '',
        engenheiroNome: engenheiroNomeController.text,
        engenheiroCrea: engenheirosMap[engenheiroNomeController.text] ?? '',
      );

      final service = PlantService();
      await service.updateUfv(widget.plant.id, updatedUfv);

      if (mounted) {
        Navigator.pop(context); // Closes the loading dialog
        Navigator.pop(context, updatedUfv); // Closes the screen AND passes the new data back

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados salvos com sucesso'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
    Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 15),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              const CustomHeader(title: 'Edição de UFV'),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11.0,
                  vertical: 8.0,
                ),
                child: UfvButton(
                  ufv: "${widget.plant.name} ${widget.ufv.name}",
                  showConfigButton: false,
                ),
              ),

              const TabBar(
                isScrollable: true,
                labelColor: Colors.black87,
                unselectedLabelColor: Colors.black38,
                indicatorColor: Colors.black87,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                tabs: [
                  Tab(text: "Projeto e Ambiente"),
                  Tab(text: "Proteção e Inspeção"),
                  Tab(text: "Transformador"),
                  Tab(text: "Assinaturas e Obs"),
                ],
              ),

              Expanded(
                child: TabBarView(
                  children: [
                    // --- TAB 1: PROJETO E AMBIENTE ---
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(11.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Condições do Ambiente e Sistema'),
                          EditorDataRow(
                            label: "Temp. Ambiente (°C)",
                            controller: tempAmbienteController,
                            keyboardType: TextInputType.number,
                          ),
                          EditorDataRow(
                            label: "Umidade (%)",
                            controller: umidadeController,
                            keyboardType: TextInputType.number,
                          ),
                          EditorDataRow(
                            label: "Classe (kV)",
                            controller: classeKvController,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),

                    // --- TAB 2: PROTEÇÃO E INSPEÇÃO ---
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(11.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Sistemas de Proteção Geral'),
                          EditorDataRow(
                            label: "Estado Geral",
                            controller: estadoGeralProtecaoGeralController,
                            dropdownItems: statusGeralOptions,
                            onDropdownChanged: (v) => setState(() {}),
                          ),
                          EditorDataRow(
                            label: "Relé de Proteção",
                            controller: releProtecaoGeralController,
                            dropdownItems: statusItemOptions,
                            onDropdownChanged: (v) => setState(() {}),
                          ),
                          EditorDataRow(
                            label: "Nobreak",
                            controller: nobreakGeralController,
                            dropdownItems: statusItemOptions,
                            onDropdownChanged: (v) => setState(() {}),
                          ),
                          EditorDataRow(
                            label: "Seccionamento",
                            controller: seccionamentoGeralController,
                            dropdownItems: statusItemOptions,
                            onDropdownChanged: (v) => setState(() {}),
                          ),

                          _buildSectionTitle('Sistemas de Proteção Local'),
                          EditorDataRow(
                            label: "Estado Geral",
                            controller: estadoGeralProtecaoLocalController,
                            dropdownItems: statusGeralOptions,
                            onDropdownChanged: (v) => setState(() {}),
                          ),
                          EditorDataRow(
                            label: "Relé de Proteção",
                            controller: releProtecaoLocalController,
                            dropdownItems: statusItemOptions,
                            onDropdownChanged: (v) => setState(() {}),
                          ),
                          EditorDataRow(
                            label: "Nobreak",
                            controller: nobreakLocalController,
                            dropdownItems: statusItemOptions,
                            onDropdownChanged: (v) => setState(() {}),
                          ),
                          EditorDataRow(
                            label: "Seccionamento",
                            controller: seccionamentoLocalController,
                            dropdownItems: statusItemOptions,
                            onDropdownChanged: (v) => setState(() {}),
                          ),

                          _buildSectionTitle('Inspeção Visual'),
                          EditorDataRow(
                            label: "Estado Geral",
                            controller: estadoGeralInspecaoController,
                            dropdownItems: statusGeralOptions,
                            onDropdownChanged: (v) => setState(() {}),
                          ),
                          EditorDataRow(
                            label: "Bobina 1 (Trafo a Seco)",
                            controller: bobina1Controller,
                            dropdownItems: statusItemOptions,
                            onDropdownChanged: (v) => setState(() {}),
                          ),
                          EditorDataRow(
                            label: "Bobina 2 (Trafo a Seco)",
                            controller: bobina2Controller,
                            dropdownItems: statusItemOptions,
                            onDropdownChanged: (v) => setState(() {}),
                          ),
                          EditorDataRow(
                            label: "Bobina 3 (Trafo a Seco)",
                            controller: bobina3Controller,
                            dropdownItems: statusItemOptions,
                            onDropdownChanged: (v) => setState(() {}),
                          ),
                          EditorDataRow(
                            label: "H0 - Bucha MT",
                            controller: h0BuchaMtController,
                            dropdownItems: statusItemOptions,
                            onDropdownChanged: (v) => setState(() {}),
                          ),
                          EditorDataRow(
                            label: "H1 - Bucha MT",
                            controller: h1BuchaMtController,
                            dropdownItems: statusItemOptions,
                            onDropdownChanged: (v) => setState(() {}),
                          ),
                          EditorDataRow(
                            label: "H2 - Bucha MT",
                            controller: h2BuchaMtController,
                            dropdownItems: statusItemOptions,
                            onDropdownChanged: (v) => setState(() {}),
                          ),
                          EditorDataRow(
                            label: "H3 - Bucha MT",
                            controller: h3BuchaMtController,
                            dropdownItems: statusItemOptions,
                            onDropdownChanged: (v) => setState(() {}),
                          ),
                          EditorDataRow(
                            label: "X0 - Bucha BT",
                            controller: x0BuchaBtController,
                            dropdownItems: statusItemOptions,
                            onDropdownChanged: (v) => setState(() {}),
                          ),
                          EditorDataRow(
                            label: "X1 - Bucha BT",
                            controller: x1BuchaBtController,
                            dropdownItems: statusItemOptions,
                            onDropdownChanged: (v) => setState(() {}),
                          ),
                          EditorDataRow(
                            label: "X2 - Bucha BT",
                            controller: x2BuchaBtController,
                            dropdownItems: statusItemOptions,
                            onDropdownChanged: (v) => setState(() {}),
                          ),
                          EditorDataRow(
                            label: "X3 - Bucha BT",
                            controller: x3BuchaBtController,
                            dropdownItems: statusItemOptions,
                            onDropdownChanged: (v) => setState(() {}),
                          ),
                          EditorDataRow(
                            label: "Vazamento Óleo Carcaça",
                            controller: vazamentoOleoCarcacaController,
                            dropdownItems: statusItemOptions,
                            onDropdownChanged: (v) => setState(() {}),
                          ),

                          _buildSectionTitle('Proteções Físicas'),
                          EditorDataRow(
                            label: "Relé Temperatura Digital",
                            controller: releTemperaturaDigitalController,
                            dropdownItems: statusItemOptions,
                            onDropdownChanged: (v) => setState(() {}),
                          ),
                          EditorDataRow(
                            label: "PT-100 Bobina 1 (Seco)",
                            controller: pt100Bobina1Controller,
                            dropdownItems: statusItemOptions,
                            onDropdownChanged: (v) => setState(() {}),
                          ),
                          EditorDataRow(
                            label: "PT-100 Bobina 2 (Seco)",
                            controller: pt100Bobina2Controller,
                            dropdownItems: statusItemOptions,
                            onDropdownChanged: (v) => setState(() {}),
                          ),
                          EditorDataRow(
                            label: "PT-100 Bobina 3 (Seco)",
                            controller: pt100Bobina3Controller,
                            dropdownItems: statusItemOptions,
                            onDropdownChanged: (v) => setState(() {}),
                          ),
                          EditorDataRow(
                            label: "Ventilação Forçada",
                            controller: ventilacaoForcadaController,
                            dropdownItems: statusItemOptions,
                            onDropdownChanged: (v) => setState(() {}),
                          ),
                          EditorDataRow(
                            label: "PT-100 / Termômetro (Óleo)",
                            controller: pt100TermometroOleoController,
                            dropdownItems: statusItemOptions,
                            onDropdownChanged: (v) => setState(() {}),
                          ),
                          EditorDataRow(
                            label: "Pressostato (Óleo)",
                            controller: pressostatoOleoController,
                            dropdownItems: statusItemOptions,
                            onDropdownChanged: (v) => setState(() {}),
                          ),
                          EditorDataRow(
                            label: "Nível de Óleo (Óleo)",
                            controller: nivelOleoController,
                            dropdownItems: statusItemOptions,
                            onDropdownChanged: (v) => setState(() {}),
                          ),
                          EditorDataRow(
                            label: "Análise de Óleo",
                            controller: analiseOleoController,
                            dropdownItems: statusItemOptions,
                            onDropdownChanged: (v) => setState(() {}),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),

                    // --- TAB 3: DADOS DO TRANSFORMADOR (Original) ---
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(11.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Dados de Placa'),
                          EditorDataRow(
                            label: "FECHAMENTO",
                            controller: fechamentoController,
                            dropdownItems: fechamentoOptions,
                            onDropdownChanged: (v) => setState(() {}),
                          ),
                          EditorDataRow(
                            label: "MARCA",
                            controller: marcaController,
                            dropdownItems: marcaOptions,
                            onDropdownChanged: (v) => setState(() {}),
                          ),
                          EditorDataRow(
                            label: "N. SÉRIE",
                            controller: nSerieController,
                          ),
                          EditorDataRow(
                            label: "FATOR K",
                            controller: fatorKController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                          EditorDataRow(
                            label: "Tensão Primária",
                            controller: tensaoPrimariaController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                          EditorDataRow(
                            label: "Relação Nominal",
                            controller: relacaoNominalController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                          EditorDataRow(
                            label: "Tensão Secundária",
                            controller: tensaoSecundariaController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                          EditorDataRow(
                            label: "POTENCIA KVA",
                            controller: potenciaKvaController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                          EditorDataRow(
                            label: "IMPEDANCIA",
                            controller: impedanciaController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                          EditorDataRow(
                            label: "FREQUENCIA",
                            controller: frequenciaController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                          EditorDataRow(
                            label: "PESO",
                            controller: pesoController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                          EditorDataRow(
                            label: "IP",
                            controller: ipController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                          EditorDataRow(
                            label: "Data Fabricação",
                            controller: dataFabricacaoController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                          EditorDataRow(
                            label: "VOLUME OLEO",
                            controller: volumeOleoController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- TAB 4: ASSINATURAS E OBSERVAÇÕES ---
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(11.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Equipe Responsável'),
                          EditorDataRow(
                            label: "Nome Executante",
                            controller: executanteNomeController,
                            dropdownItems: executantesMap.keys.toList(),
                            onDropdownChanged: (v) => setState(() {}),
                          ),
                          const SizedBox(height: 10),
                          EditorDataRow(
                            label: "Eng. Responsável",
                            controller: engenheiroNomeController,
                            dropdownItems: engenheirosMap.keys.toList(),
                            onDropdownChanged: (v) => setState(() {}),
                          ),

                          const SizedBox(height: 10),
                          _buildSectionTitle('Observações e Recomendações'),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              border: Border.all(color: Colors.black87),
                            ),
                            child: TextField(
                              controller: observacoesController,
                              maxLines: 6,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(12),
                                hintText: 'Digite as observações aqui...',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --- PERSISTENT BOTTOM SAVE BUTTON ---
              Container(
                padding: const EdgeInsets.all(11.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(8),
                      ),
                    ),
                    child: const Text(
                      'SALVAR ALTERAÇÕES',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditorDataRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final List<String>? dropdownItems;
  final Function(String?)? onDropdownChanged;

  const EditorDataRow({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.dropdownItems,
    this.onDropdownChanged,
  });

  // --- NEW: Helper for subtle background colors ---
  Color _getBgColor(String? value) {
    if (value == null) return Colors.grey[200]!;
    switch (value.toUpperCase()) {
      case 'BOM':
      case 'OK':
        return const Color(0xFFE8F5E9); // Subtle Green (Green 50)
      case 'REGULAR':
        return const Color(0xFFFFF3E0); // Subtle Orange (Orange 50)
      case 'RUIM':
      case 'AVARIA':
        return const Color(0xFFFFEBEE); // Subtle Red (Red 50)
      case 'NA':
        return const Color(0xFFF5F5F5); // Subtle Grey (Grey 100)
      default:
        return Colors.grey[200]!;
    }
  }

  // --- NEW: Helper for text colors to match the background nicely ---
  Color _getTextColor(String? value) {
    if (value == null) return Colors.black;
    switch (value.toUpperCase()) {
      case 'BOM':
      case 'OK':
        return Colors.green[800]!;
      case 'REGULAR':
        return Colors.orange[800]!;
      case 'RUIM':
      case 'AVARIA':
        return Colors.red[800]!;
      case 'NA':
        return Colors.grey[600]!;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the background color dynamically based on the current text
    final bgColor = dropdownItems != null
        ? _getBgColor(controller.text)
        : Colors.grey[200];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black87),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                  fontSize: 10.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: bgColor, // <--- Applies the dynamic color here
                border: Border.all(color: Colors.black87),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: dropdownItems != null
                    ? _buildDropdown()
                    : _buildTextField(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        const Icon(Icons.edit, size: 16, color: Colors.black38),
      ],
    );
  }

  Widget _buildDropdown() {
    String? currentValue = controller.text;
    if (dropdownItems != null && !dropdownItems!.contains(currentValue)) {
      currentValue = dropdownItems!.first;
      controller.text = currentValue;
    }

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: currentValue,
        isExpanded: true,
        icon: Icon(Icons.arrow_drop_down, color: _getTextColor(currentValue)),
        style: TextStyle(
          color: _getTextColor(
            currentValue,
          ), // <--- Applies matching text color to selected item
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        alignment: Alignment.center,
        items: dropdownItems!.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Center(
              child: Text(
                value,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _getTextColor(
                    value,
                  ), // <--- Applies matching text color to list items
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
        onChanged: (newValue) {
          if (newValue != null) {
            controller.text = newValue;
            if (onDropdownChanged != null) onDropdownChanged!(newValue);
          }
        },
      ),
    );
  }
}
