import 'package:flutter/material.dart';
import 'package:page_to_play/models/ebook.dart';
import 'package:page_to_play/service/ebook_importer_service.dart';
import 'package:page_to_play/service/firebase_service.dart';
import 'package:page_to_play/service/upload_limit_service.dart';
import 'package:page_to_play/utilities/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class ConversionFlowScreen extends StatefulWidget {
  const ConversionFlowScreen({super.key});

  @override
  State<ConversionFlowScreen> createState() => _ConversionFlowScreenState();
}

class _ConversionFlowScreenState extends State<ConversionFlowScreen> {
  final EbookImporterService _importer = EbookImporterService();
  final FirebaseService _firebaseService = FirebaseService();
  final UploadLimitService _uploadLimitService = UploadLimitService();

  EBook? _ebook;
  bool _isLoading = false;
  String? _error;
  String? _status;
  int _remainingUploads = 0;

  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late List<TextEditingController> _contentControllers;

  @override
  void initState() {
    super.initState();
    _updateRemainingUploads();
  }

  Future<void> _updateRemainingUploads() async {
    final remaining = await _uploadLimitService.getRemainingUploads();
    setState(() {
      _remainingUploads = remaining;
    });
  }

  @override
  void dispose() {
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
    final snackBar = SnackBar(
      content: Text(message, style: TextStyle(color: Theme.of(context).colorScheme.onError)),
      backgroundColor: Theme.of(context).colorScheme.error,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      _showError("Could not launch $url");
    }
  }

  Future<void> _pickFile() async {
    final canUpload = await _uploadLimitService.canUpload();
    if (!canUpload) {
      _showError('You have reached the daily upload limit.');
      return;
    }

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
    });

    try {
      await _firebaseService.addEbook(editedEbook);
      _disposeControllers();
      setState(() {
        _status = "Ebook saved to Firebase successfully!";
        _ebook = null;
      });
      _updateRemainingUploads();
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
    if (_ebook != null) {
      _disposeControllers();
    }
    setState(() {
      _ebook = null;
      _error = null;
      _status = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_ebook != null) {
          _reset();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_ebook == null ? 'Add New Ebook' : 'Review Ebook'),
          actions: _ebook != null
              ? [
                  TextButton(
                    onPressed: _reset,
                    child: const Text('Discard'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: _saveToFirebase,
                      child: const Text('Save'),
                    ),
                  ),
                ]
              : null,
        ),
        body: Stack(
          children: [
            if (_ebook == null) _buildInitialView() else _buildEditView(),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialView() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.cloud_upload_outlined),
              onPressed: _pickFile,
              label: const Text('Import Ebook (PDF or EPUB)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Remaining uploads today: $_remainingUploads',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.textTheme.bodySmall?.color),
              ),
            ),
            if (_status != null)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  _status!,
                  textAlign: TextAlign.center,
                  style: kSuccessTextStyle,
                ),
              ),
            const SizedBox(height: 60),
            Text("Don't have an ebook?",
                textAlign: TextAlign.center,
                style: kSubheadingTextStyle.apply(
                    color: theme.textTheme.titleLarge?.color)),
            const SizedBox(height: 10),
            Text("Download one from these sites:",
                textAlign: TextAlign.center,
                style: kBodyTextStyle.apply(
                    color: theme.textTheme.bodyMedium?.color)),
            const SizedBox(height: 20),
            ...kEbookSites.entries.map((entry) {
              return TextButton(
                onPressed: () => _launchURL(entry.value),
                child: Text(entry.key, style: const TextStyle(fontSize: 16)),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEditView() {
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              TextField(
                controller: _titleController,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: kTextFieldInputDecoration.copyWith(
                  labelText: 'Title',
                  fillColor: theme.inputDecorationTheme.fillColor,
                  labelStyle:
                      TextStyle(color: theme.inputDecorationTheme.hintStyle?.color),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _authorController,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: kTextFieldInputDecoration.copyWith(
                  labelText: 'Author',
                  fillColor: theme.inputDecorationTheme.fillColor,
                  labelStyle:
                      TextStyle(color: theme.inputDecorationTheme.hintStyle?.color),
                ),
              ),
              const SizedBox(height: 24),
              Text('Content Preview:',
                  style: kSubheadingTextStyle.apply(
                      color: theme.textTheme.titleLarge?.color)),
            ]),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _contentControllers[index],
                  maxLines: null,
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                  decoration: kTextFieldInputDecoration.copyWith(
                    labelText: 'Sentence ${index + 1}',
                    fillColor: theme.inputDecorationTheme.fillColor,
                    labelStyle: TextStyle(
                        color: theme.inputDecorationTheme.hintStyle?.color),
                  ),
                ),
              );
            },
            childCount: _contentControllers.length,
          ),
        ),
      ],
    );
  }
}
