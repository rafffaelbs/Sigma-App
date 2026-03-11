import 'package:flutter/material.dart';
import 'package:sigma_app/models/plant_model.dart';
import 'package:sigma_app/screens/edit_ufv.dart';
import 'package:sigma_app/screens/ufv_instrument_screen.dart';
import 'package:sigma_app/widgets/custom_header.dart';
import 'package:sigma_app/widgets/plant_button.dart';

class SelectUfv extends StatefulWidget {
  final Plant plant;

  const SelectUfv({super.key, required this.plant});

  @override
  State<SelectUfv> createState() => _SelectUfvState();
}

class _SelectUfvState extends State<SelectUfv> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(title: 'Selecione a UFV'),
            SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: Text(
                widget.plant.name.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: widget.plant.ufvs.length,
                itemBuilder: (context, index) {
                  var ufv = widget.plant.ufvs[index];

                  return Padding(
                    padding: const EdgeInsetsGeometry.only(bottom: 16),
                    child: UfvButton(
                      ufv: ufv.name,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UfvInstrumentsScreen(
                              ufv: ufv,
                              plant: widget.plant,
                            ),
                          ),
                        );
                      },
                      onConfigTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditUfv(plant: widget.plant, ufv: ufv),
                          ),
                        );

                        if (result != null && result is UFV) {
                          setState(() {
                            // 1. Find the exact position of this UFV in the plant's list
                            int index = widget.plant.ufvs.indexWhere(
                              (u) => u.id == ufv.id,
                            );

                            // 2. Replace the old UFV with the newly edited one
                            if (index != -1) {
                              widget.plant.ufvs[index] = result;
                            }
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
