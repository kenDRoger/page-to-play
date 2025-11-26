class TextProcessingService {
  // Cleans the raw text and structures it into a list of sentences.
  List<String> cleanAndStructureText(String rawText) {
    final List<String> sentences = [];
    // Normalize line endings to handle \r\n and \r, then split.
    final normalizedText = rawText.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final lines = normalizedText.split('\n');

    final StringBuffer currentParagraph = StringBuffer();

    for (final line in lines) {
      final trimmedLine = line.trim();

      // An empty line signifies a paragraph break.
      if (trimmedLine.isEmpty) {
        if (currentParagraph.isNotEmpty) {
          // Once we have a paragraph, split it into sentences.
          sentences.addAll(_splitParagraphIntoSentences(currentParagraph.toString()));
          currentParagraph.clear();
        }
      } else {
        if (_isNoise(trimmedLine)) {
          continue;
        }

        // Add a space between lines that belong to the same paragraph.
        if (currentParagraph.isNotEmpty) {
          currentParagraph.write(' ');
        }
        currentParagraph.write(trimmedLine);
      }
    }

    // Add sentences from the last paragraph if it exists.
    if (currentParagraph.isNotEmpty) {
      sentences.addAll(_splitParagraphIntoSentences(currentParagraph.toString()));
    }

    return sentences;
  }

  List<String> _splitParagraphIntoSentences(String paragraph) {
    // This regex splits the text after any of ., !, ? followed by whitespace.
    // It's a simple approach and won't handle all edge cases (e.g., "Mr. Smith") perfectly.
    final sentenceEndRegex = RegExp(r'(?<=[.?!])\s+');

    return paragraph
        .split(sentenceEndRegex)
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  // Helper to identify and filter out unwanted lines (noise).
  bool _isNoise(String line) {
    // Filter out CSS styles.
    if (line.contains('{') && line.contains('}')) return true;

    // Filter out short, non-alphanumeric lines that are often artifacts or page numbers.
    if (line.length < 4 && !line.contains(RegExp(r'[a-zA-Z]'))) return true;

    // Filter out common publishing artifacts.
    if (line.toLowerCase() == 'table of contents') return true;

    return false;
  }
}
