import 'package:flutter/material.dart';

class PlantButton extends StatelessWidget {
  const PlantButton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

// Widget _buildPlantButton(BuildContext context, Plant plant) {
//     return Material(
//       color: Colors.grey[300],
//       borderRadius: BorderRadius.circular(12),
//       clipBehavior: Clip.hardEdge,
//       child: InkWell(
//         onTap: () {
//           print("Clickedon ${plant.name}");
//           // Nagita to other pages later
//         },
//         child: Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           alignment: Alignment.center,
//           child: Text(
//             plant.name.toUpperCase(),
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 18,
//               color: Colors.black87,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }