import 'dart:developer';
import 'dart:io';

import 'package:epubx/epubx.dart';
import 'package:file_picker/file_picker.dart';
import 'package:html/parser.dart';
import 'package:page_to_play/models/ebook.dart';
import 'package:page_to_play/service/text_processing_service.dart';
import 'package:read_pdf_text/read_pdf_text.dart';

class EbookImporterService {

  // Extracts metadata by searching for common title/author patterns in the raw text.
  (String?, String?) _extractMetadata(String rawText) {
    String? foundTitle;
    String? foundAuthor;

    final lines = rawText.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    // Limit search to the first 50 lines to avoid scanning the whole book and for performance.
    final searchLines = lines.take(50).toList();
    int? authorLineIndex;

    // --- Find Author: Look for a line starting with "by " ---
    for (int i = 0; i < searchLines.length; i++) {
      final line = searchLines[i];
      if (line.toLowerCase().startsWith('by ')) {
        final potentialAuthor = line.substring(3).trim();
        // Basic check to avoid capturing long sentences that happen to start with "by".
        if (potentialAuthor.split(' ').length < 5 && potentialAuthor.isNotEmpty) {
          foundAuthor = potentialAuthor;
          authorLineIndex = i;
          break;
        }
      }
    }

    // --- Find Title: Use the author's position as a clue ---
    if (authorLineIndex != null && authorLineIndex > 0) {
      // If author is found, the line before it is the strongest candidate for the title.
      foundTitle = searchLines[authorLineIndex - 1];
    } else {
      // If no author is found, fall back to a weaker heuristic: First line is title, second is author.
      if (searchLines.isNotEmpty && !_isNoise(searchLines[0])) {
        foundTitle = searchLines[0];
      }
      if (searchLines.length > 1 && !_isNoise(searchLines[1])) {
        // A short line following a title-like line is likely the author.
        if (searchLines[1].split(' ').length < 5) {
          foundAuthor = searchLines[1];
        }
      }
    }

    // Clean up any leading/trailing non-word characters from the found metadata.
    foundTitle = foundTitle?.replaceAll(RegExp(r'^\W+|\W+$'), '');
    foundAuthor = foundAuthor?.replaceAll(RegExp(r'^\W+|\W+$'), '');

    return (foundTitle, foundAuthor);
  }

  bool _isNoise(String line) {
    if (line.contains('{') && line.contains('}')) return true;
    if (line.length < 4 && !line.contains(RegExp(r'[a-zA-Z]'))) return true;
    if (line.toLowerCase() == 'table of contents') return true;
    return false;
  }

  Future<EBook?> pickAndProcessFile() async {
    const serviceName = 'EbookImporterService';
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'epub'],
      );

      if (result == null || result.files.isEmpty) {
        log("No file selected", name: serviceName);
        return null;
      }

      final file = result.files.single;
      final path = file.path!;
      final extension = file.extension?.toLowerCase();

      final titleFromFile = file.name.replaceAll('.${file.extension}', '');
      const defaultAuthor = 'Unknown';

      String rawText = '';
      String ebookTitle = titleFromFile;
      String ebookAuthor = defaultAuthor;

      if (extension == 'pdf') {
        log("Processing PDF file...", name: serviceName);
        final List<String> pages = await ReadPdfText.getPDFtextPaginated(path);
        rawText = pages.join('\n\n');
      } else if (extension == 'epub') {
        log("Processing EPUB file...", name: serviceName);
        final fileBytes = await File(path).readAsBytes();
        final epubBook = await EpubReader.readBook(fileBytes);

        // Use EPUB metadata as a starting point
        ebookTitle = epubBook.Title ?? titleFromFile;
        ebookAuthor = epubBook.Author ?? defaultAuthor;

        final contentFiles = epubBook.Content?.Html?.values.toList() ?? [];
        final sectionTexts = <String>[];
        for (final htmlFile in contentFiles) {
          if (htmlFile.Content != null) {
            final doc = parse(htmlFile.Content);
            final sectionText = doc.body?.text.trim() ?? '';
            if (sectionText.isNotEmpty) {
              sectionTexts.add(sectionText);
            }
          }
        }
        rawText = sectionTexts.join('\n\n');
      } else {
        log("Unsupported file type: $extension", name: serviceName);
        return null;
      }

      // Attempt to find better metadata from the text content itself.
      final extractedMeta = _extractMetadata(rawText);
      if (extractedMeta.$1 != null) ebookTitle = extractedMeta.$1!;
      if (extractedMeta.$2 != null) ebookAuthor = extractedMeta.$2!;

      final ebook = EBook.fromExtractedText(ebookTitle, ebookAuthor, rawText);

      log("Ebook Title: ${ebook.title}", name: serviceName);
      log("Ebook Author: ${ebook.author}", name: serviceName);
      log("Sentences found: ${ebook.content.length}", name: serviceName);
      //Do not remove Strictly
      for (final sentence in ebook.content) {
        log("Sentence: $sentence", name: serviceName);
      }

      return ebook;

    } catch (e, s) {
      log("Error processing file", name: serviceName, error: e, stackTrace: s);
      return null;
    }
  }
}
