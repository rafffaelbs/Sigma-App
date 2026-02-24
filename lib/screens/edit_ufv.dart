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
  final List<String> fechamentoOptions = ['Delta', 'Estrela'];
  final List<String> marcaOptions = ['WEG', 'Siemens', 'ABB'];

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

  @override
  void initState() {
    super.initState();

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
    super.dispose();
  }

  void _saveChanges() async {
    // String newFechamento = fechamentoController.text;
    // String newMarca = fechamentoController.text;
    // String newDataFabricacao = dataFabricacaoController.text;

    // double newNSerie = double.tryParse(nSerieController.text) ?? 0.0;
    // double newFatorK = double.tryParse(fatorKController.text) ?? 0.0;
    // double newTensaoPrimaria =
    //     double.tryParse(tensaoPrimariaController.text) ?? 0.0;
    // double newRelacaoNominal =
    //     double.tryParse(relacaoNominalController.text) ?? 0.0;
    // double newTensaoSecundaria =
    //     double.tryParse(tensaoSecundariaController.text) ?? 0.0;
    // double newPotenciaKva = double.tryParse(potenciaKvaController.text) ?? 0.0;
    // double newImpedancia = double.tryParse(impedanciaController.text) ?? 0.0;
    // double newFrequencia = double.tryParse(frequenciaController.text) ?? 0.0;
    // double newPeso = double.tryParse(pesoController.text) ?? 0.0;
    // double newIp = double.tryParse(ipController.text) ?? 0.0;
    // double newVolumeOleo = double.tryParse(volumeOleoController.text) ?? 0.0;

    // print(
    //   'Saving: $newFechamento $newMarca $newDataFabricacao $newNSerie $newFatorK $newTensaoPrimaria $newRelacaoNominal $newTensaoSecundaria $newPotenciaKva $newImpedancia $newFrequencia $newPeso $newIp $newVolumeOleo',
    // );
    // // TODO: logic to save this back to my database
    // // Navigator.pop(context); // Go back after saving

    // Show a loading indicator (Good UX)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Create the new object using copyWith
      final updatedUfv = widget.ufv.copyWith(
        fechamento: fechamentoController.text,
        marca: marcaController.text,
        nSerie: nSerieController.text,
        fatorK: double.tryParse(fatorKController.text) ?? widget.ufv.fatorK,
        tensaoPrimaria:
            double.tryParse(tensaoPrimariaController.text) ??
            widget.ufv.tensaoPrimaria,
        relacaoNominal:
            double.tryParse(relacaoNominalController.text) ??
            widget.ufv.relacaoNominal,
        tensaoSecundaria:
            double.tryParse(tensaoSecundariaController.text) ??
            widget.ufv.tensaoSecundaria,
        potenciaKva:
            double.tryParse(potenciaKvaController.text) ??
            widget.ufv.potenciaKva,
        impedancia:
            double.tryParse(impedanciaController.text) ?? widget.ufv.impedancia,
        frequencia:
            double.tryParse(frequenciaController.text) ?? widget.ufv.frequencia,
        peso: double.tryParse(pesoController.text) ?? widget.ufv.peso,
        ip: int.tryParse(ipController.text) ?? widget.ufv.ip,
        dataFabricacao: dataFabricacaoController.text,
        volumeOleo:
            double.tryParse(volumeOleoController.text) ?? widget.ufv.volumeOleo,
      );

      // Call the Service
      final service = PlantService();
      await service.updateUfv(widget.plant.id, updatedUfv);

      // Close Loading and go back
      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context, updatedUfv);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados salvos com sucesso')),
        );
      }
    } catch (e) {
      // Se der erro
      if (mounted) {
        Navigator.pop(context); // Fecha o loading

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(title: 'Dados do Transformador'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(11.0),
                child: Column(
                  children: [
                    // The Top Button from your first code snippet
                    UfvButton(
                      ufv: "${widget.plant.name} ${widget.ufv.name}",
                      showConfigButton: false,
                    ),
                    const SizedBox(height: 20),

                    // Use the reusable row for each data point
                    TransformerDataRow(
                      label: "FECHAMENTO",
                      controller: fechamentoController,
                      dropdownItems: fechamentoOptions,
                      onDropdownChanged: (value) {
                        setState(() {});
                      },
                    ),
                    TransformerDataRow(
                      label: "MARCA",
                      controller: marcaController,
                      dropdownItems: marcaOptions,
                      onDropdownChanged: (value) {
                        setState(() {});
                      },
                    ),
                    TransformerDataRow(
                      label: "N. SÉRIE",
                      controller: nSerieController,
                    ),
                    TransformerDataRow(
                      label: "FATOR K",
                      controller: fatorKController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    TransformerDataRow(
                      label: "Tensão Primária",
                      controller: tensaoPrimariaController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    TransformerDataRow(
                      label: "Relação Nominal",
                      controller: relacaoNominalController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    TransformerDataRow(
                      label: "Tensão Secundária",
                      controller: tensaoSecundariaController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    TransformerDataRow(
                      label: "POTENCIA KVA",
                      controller: potenciaKvaController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    TransformerDataRow(
                      label: "IMPEDANCIA",
                      controller: impedanciaController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    TransformerDataRow(
                      label: "FREQUENCIA",
                      controller: frequenciaController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    TransformerDataRow(
                      label: "PESO",
                      controller: pesoController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    TransformerDataRow(
                      label: "IP",
                      controller: ipController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    TransformerDataRow(
                      label: "Data Fabricação",
                      controller: dataFabricacaoController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    TransformerDataRow(
                      label: "VOLUME OLEO",
                      controller: volumeOleoController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
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
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransformerDataRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;

  final List<String>? dropdownItems;
  final Function(String?)? onDropdownChanged;

  const TransformerDataRow({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.dropdownItems,
    this.onDropdownChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          // Left Side - Fixed Label
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black87),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Right Side - Editable Area
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color:
                    Colors.grey[300], // Darker background for editable fields
                border: Border.all(color: Colors.black87),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0), //
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
            style: const TextStyle(fontWeight: FontWeight.w500),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        const Icon(Icons.edit, size: 18, color: Colors.black54),
      ],
    );
  }

  Widget _buildDropdown() {
    String? currentValue = controller.text;
    if (!dropdownItems!.contains(currentValue)) {
      currentValue = null;
    }

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: currentValue,
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        alignment: Alignment.center,
        items: dropdownItems!.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Center(child: Text(value)),
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
