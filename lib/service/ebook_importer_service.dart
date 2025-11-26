import 'dart:developer';
import 'dart:io';

import 'package:epubx/epubx.dart';
import 'package:file_picker/file_picker.dart';
import 'package:html/parser.dart';
import 'package:page_to_play/models/ebook.dart';
import 'package:page_to_play/service/text_processing_service.dart';
import 'package:read_pdf_text/read_pdf_text.dart';

class EbookImporterService {
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

      // Delegate metadata extraction to the processing service.
      final extractedMeta = TextProcessingService.extractMetadata(rawText);
      if (extractedMeta.$1 != null) ebookTitle = extractedMeta.$1!;
      if (extractedMeta.$2 != null) ebookAuthor = extractedMeta.$2!;

      // The EBook factory is now responsible for calling the text processor.
      final ebook = EBook.fromExtractedText(ebookTitle, ebookAuthor, rawText);

      log("Ebook Title: ${ebook.title}", name: serviceName);
      log("Ebook Author: ${ebook.author}", name: serviceName);
      log("Sentences found: ${ebook.content.length}", name: serviceName);
      //debug: do not remove
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
