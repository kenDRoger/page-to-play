
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:page_to_play/models/ebook.dart';
import 'package:page_to_play/service/ebook_importer_service.dart';
import 'package:page_to_play/service/firebase_service.dart';
import 'package:page_to_play/utilities/constants.dart';
import 'package:url_launcher/url_launcher.dart';

import '../firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MaterialApp(home: ConversionFlowScreen()));
}

class ConversionFlowScreen extends StatefulWidget {
  const ConversionFlowScreen({super.key});

  @override
  State<ConversionFlowScreen> createState() => _ConversionFlowScreenState();
}

class _ConversionFlowScreenState extends State<ConversionFlowScreen> {
  final EbookImporterService _importer = EbookImporterService();
  final FirebaseService _firebaseService = FirebaseService();

  EBook? _ebook;
  bool _isLoading = false;
  String? _error;
  String? _status;

  // Controllers for editable fields
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late List<TextEditingController> _contentControllers;

  @override
  void dispose() {
    // Only dispose controllers if they have been initialized.
    if (_ebook != null) {
      _disposeControllers();
    }
    super.dispose();
  }

  void _disposeControllers() {
    _titleController.dispose();
    _authorController.dispose();
    for (var controller in _contentControllers) {
      controller.dispose();
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _error = message;
    });
    // Clear the error message after 5 seconds.
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _error == message) {
        setState(() {
          _error = null;
        });
      }
    });
  }

  Future<void> _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      _showError("Could not launch $url");
    }
  }

  Future<void> _pickFile() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _ebook = null;
      _status = null;
    });

    try {
      final ebook = await _importer.pickAndProcessFile();
      if (ebook != null) {
        setState(() {
          _ebook = ebook;
          _titleController = TextEditingController(text: ebook.title);
          _authorController = TextEditingController(text: ebook.author);
          _contentControllers = ebook.content
              .map((sentence) => TextEditingController(text: sentence))
              .toList();
        });
      } else {
        _showError("File import was cancelled or failed.");
      }
    } catch (e) {
      _showError("An error occurred: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveToFirebase() async {
    if (_ebook == null) return;

    final editedEbook = EBook(
      title: _titleController.text,
      author: _authorController.text,
      content: _contentControllers.map((c) => c.text).toList(),
    );

    setState(() {
      _isLoading = true;
      _error = null;
      _status = null;
    });

    try {
      await _firebaseService.addEbook(editedEbook);
      // Dispose controllers before resetting the state.
      _disposeControllers();
      setState(() {
        _status = "Ebook saved to Firebase successfully!";
        _ebook = null;
      });
    } on EbookAlreadyExistsException catch (e) {
      _showError("This book is already in the library: ${e.message}");
    } catch (e) {
      _showError("An error occurred while saving: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _reset() {
    // Dispose controllers before clearing the ebook object.
    if (_ebook != null) {
      _disposeControllers();
    }
    setState(() {
      _ebook = null;
      _error = null;
      _status = null;
    });
  }

  Widget _buildInitialView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _pickFile,
            child: const Text('Import Ebook (PDF or EPUB)'),
          ),
          if (_status != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _status!,
                style: const TextStyle(color: Colors.green, fontSize: 16),
              ),
            ),
          const SizedBox(height: 40),
          const Text("Don't have an ebook?", style: kSubheadingTextStyle),
          const Text("Download one from these sites:"),
          const SizedBox(height: 10),
          ...kEbookSites.entries.map((entry) {
            return TextButton(
              onPressed: () => _launchURL(entry.value),
              child: Text(entry.key),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEditView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _authorController,
            decoration: const InputDecoration(
              labelText: 'Author',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Content Preview:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _contentControllers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: TextFormField(
                    controller: _contentControllers[index],
                    maxLines: null, // Allows for multi-line sentences
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Sentence ${index + 1}',
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(onPressed: _reset, child: const Text('Discard')),
              ElevatedButton(
                onPressed: _saveToFirebase,
                child: const Text('Save to Library'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // If the edit view is showing, pressing back will reset the state.
        if (_ebook != null) {
          _reset();
          return false; // Prevent the default back navigation.
        }
        // Otherwise, allow the default back navigation.
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Add New Ebook')),
        body: Stack(
          children: [
            if (_ebook == null) _buildInitialView() else _buildEditView(),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(child: CircularProgressIndicator()),
              ),
            if (_error != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Material(
                  color: Colors.red,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
