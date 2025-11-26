import 'package:flutter/material.dart';
import 'package:page_to_play/models/ebook.dart';
import 'package:page_to_play/service/ebook_importer_service.dart';
import 'package:page_to_play/service/firebase_service.dart';

import '../firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(home: const SampleImporterScreen()));
}

class SampleImporterScreen extends StatefulWidget {
  const SampleImporterScreen({super.key});

  @override
  State<SampleImporterScreen> createState() => _SampleImporterScreenState();
}

class _SampleImporterScreenState extends State<SampleImporterScreen> {
  final EbookImporterService _importer = EbookImporterService();
  final FirebaseService _firebaseService = FirebaseService();
  EBook? _ebook;
  bool _isLoading = false;
  String? _error;
  String? _status;

  Future<void> _pickFile() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _ebook = null;
      _status = null;
    });

    try {
      final ebook = await _importer.pickAndProcessFile();
      setState(() {
        _ebook = ebook;
        if (ebook == null) {
          _error = "File import was cancelled or failed.";
        }
      });
    } catch (e) {
      setState(() {
        _error = "An error occurred: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveToFirebase() async {
    if (_ebook == null) return;

    final ebookToSave = _ebook;

    setState(() {
      _isLoading = true;
      _error = null;
      _status = null;
    });

    String? localStatus;
    String? localError;

    try {
      await _firebaseService.addEbook(ebookToSave!);
      localStatus = "Ebook saved to Firebase successfully!";
    } on EbookAlreadyExistsException catch (e) {
      localError = "This book is already in your library.";
    } catch (e) {
      localError = "An error occurred while saving: $e";
    } finally {
      if (mounted && _ebook == ebookToSave) {
        setState(() {
          _isLoading = false;
          _status = localStatus;
          _error = localError;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ebook Importer Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _pickFile,
                  child: const Text('Pick and Process Ebook'),
                ),
                const SizedBox(width: 16),
                if (_ebook != null)
                  ElevatedButton(
                    onPressed: _saveToFirebase,
                    child: const Text('Save to Firebase'),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            if (_isLoading) const CircularProgressIndicator(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_status != null)
              Text(
                _status!,
                style: const TextStyle(color: Colors.green),
                textAlign: TextAlign.center,
              ),
            if (_ebook != null)
              Card(
                margin: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Title: ${_ebook!.title}', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text('Author: ${_ebook!.author}', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('Sentences found: ${_ebook!.content.length}'),
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
