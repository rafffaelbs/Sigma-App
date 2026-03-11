import 'package:flutter/material.dart';
import 'package:sigma_app/services/local_sync_service.dart';
import 'package:sigma_app/services/upload_service.dart';

/// After concluding the upload of the initial data, this button will be responsible for syncing all the local data to Firebase
class SyncButtonWidget extends StatefulWidget {
  const SyncButtonWidget({super.key});

  @override
  State<SyncButtonWidget> createState() => _SyncButtonWidgetState();
}

class _SyncButtonWidgetState extends State<SyncButtonWidget> {
  bool _isSyncing = false;

  Future<void> _handleSync() async {
    setState(() => _isSyncing = true);

    try {
      await LocalSyncService.syncAllToFirebase();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sincronização concluída com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Defining the colors based on your image
    const Color lightPurpleBg = Color(0xFFE8DFFD); // Light purple background
    const Color deepPurpleIcon = Color(
      0xFF512DA8,
    ); // Deep purple icon/indicator

    return GestureDetector(
      onTap: _isSyncing ? null : _handleSync,
      child: Container(
        width: 65, // Adjust size to match your UI needs
        height: 65,
        decoration: BoxDecoration(
          color: lightPurpleBg,
          borderRadius: BorderRadius.circular(20), // Soft rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: _isSyncing
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: deepPurpleIcon,
                    strokeWidth: 3,
                  ),
                )
              : const Icon(Icons.cloud_upload, color: deepPurpleIcon, size: 30),
        ),
      ),
    );
  }
}

/// This widget is responsible for uploading initial data to Firebase, it contains data about the plants
class SendToFirebase extends StatefulWidget {
  const SendToFirebase({super.key});

  @override
  State<SendToFirebase> createState() => _SendToFirebaseState();
}

class _SendToFirebaseState extends State<SendToFirebase> {
  bool _isSyncing = false;

  Future<void> _handleSync() async {
    setState(() => _isSyncing = true);

    // Show initial loading feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Iniciando upload para o Firebase...')),
    );

    try {
      await FirebaseService().uploadInitialDataToFirebase(context);

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dados enviados com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro na sincronização: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color lightPurpleBg = Color(0xFFE8DFFD);
    const Color deepPurpleIcon = Color(0xFF512DA8);

    return GestureDetector(
      onTap: _isSyncing ? null : _handleSync,
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          color: lightPurpleBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: _isSyncing
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: deepPurpleIcon,
                    strokeWidth: 3,
                  ),
                )
              : const Icon(
                  Icons.cloud_download,
                  color: deepPurpleIcon,
                  size: 30,
                ),
        ),
      ),
    );
  }
}