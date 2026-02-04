import 'package:flutter/material.dart';
import 'package:sigma_app/models/plant_model.dart';
import 'package:sigma_app/widgets/custom_header.dart';
import 'package:sigma_app/widgets/plant_button.dart';

class EditUfv extends StatelessWidget {
  final Plant plant;
  final String ufv;
  
  const EditUfv({super.key, required this.plant, required this.ufv});

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
                      ufv: "${plant.name} $ufv",
                      showConfigButton: false,
                    ),
                    const SizedBox(height: 20),

                    // Use the reusable row for each data point
                    const TransformerDataRow(
                      label: "FECHAMENTO",
                      initialValue: "DELTA ESTELA",
                      isDropdown: true,
                    ),
                    const TransformerDataRow(
                      label: "MARCA",
                      initialValue: "TAMURA",
                      isDropdown: true,
                    ),
                    const TransformerDataRow(
                      label: "N. SÉRIE",
                      initialValue: "0000000000",
                    ),
                    const TransformerDataRow(
                      label: "FATOR K",
                      initialValue: "4",
                    ),
                    const TransformerDataRow(
                      label: "POTENCIA KVA",
                      initialValue: "1000",
                    ),
                    const TransformerDataRow(
                      label: "IMPEDANCIA",
                      initialValue: "6,16",
                    ),
                    const TransformerDataRow(
                      label: "FREQUENCIA",
                      initialValue: "60",
                    ),
                    const TransformerDataRow(
                      label: "PESO",
                      initialValue: "4070",
                    ),
                    const TransformerDataRow(
                      label: "VOLUME",
                      initialValue: "0",
                    ),
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
  final String initialValue;
  final bool isDropdown;

  const TransformerDataRow({
    super.key,
    required this.label,
    required this.initialValue,
    this.isDropdown = false,
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
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        initialValue,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Icon(
                      isDropdown ? Icons.arrow_drop_down : Icons.edit,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
