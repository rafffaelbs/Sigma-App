import 'package:flutter/material.dart';
import 'package:sigma_app/widgets/custom_header.dart';
import 'package:sigma_app/widgets/plant_button.dart'; // Using the pill button!

class FolderOption {
  final String title;
  final int completedCount;
  final int totalCount;
  final VoidCallback onTap;

  FolderOption({
    required this.title,
    required this.completedCount,
    required this.totalCount,
    required this.onTap,
  });
}

class DynamicFolderScreen extends StatelessWidget {
  final String title;
  final List<FolderOption> options;

  const DynamicFolderScreen({
    super.key,
    required this.title,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(title: title),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    // Now Level 2 uses the exact same UI as Level 1
                    child: InspectionButton(
                      title: option.title,
                      completedCount: option.completedCount,
                      totalCount: option.totalCount,
                      onTap: option.onTap,
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
