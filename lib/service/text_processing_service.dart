class TextProcessingService {
  // A multi-stage pipeline to clean and structure raw text into a list of sentences.
  static List<String> cleanAndStructureText(String rawText) {
    final List<String> sentences = [];
    // Normalize different newline characters, then split into lines.
    final lines = rawText.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n');
    final List<String> processedLines = [];

    // Stage 1: De-hyphenate words split across lines.
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();
      if (line.endsWith('-') && i + 1 < lines.length) {
        final nextLine = lines[i + 1].trim();
        final firstWordMatch = RegExp(r'^(\w+)').firstMatch(nextLine);
        if (firstWordMatch != null) {
          line = line.substring(0, line.length - 1) + firstWordMatch.group(1)!;
          lines[i + 1] = nextLine.substring(firstWordMatch.group(1)!.length);
        }
      }
      processedLines.add(line);
    }

    // Stage 2: Assemble paragraphs and split into sentences.
    final StringBuffer currentParagraph = StringBuffer();
    for (final line in processedLines) {
      final cleanedLine = line.trim().replaceAll(RegExp(r'\s+'), ' ');

      if (cleanedLine.isEmpty) {
        if (currentParagraph.isNotEmpty) {
          sentences.addAll(_splitParagraphIntoSentences(currentParagraph.toString()));
          currentParagraph.clear();
        }
      } else {
        if (isNoise(cleanedLine)) {
          continue;
        }
        if (currentParagraph.isNotEmpty) {
          currentParagraph.write(' ');
        }
        currentParagraph.write(cleanedLine);
      }
    }

    if (currentParagraph.isNotEmpty) {
      sentences.addAll(_splitParagraphIntoSentences(currentParagraph.toString()));
    }

    return sentences;
  }

  // Improved sentence splitter that handles common abbreviations and no-space endings.
  static List<String> _splitParagraphIntoSentences(String paragraph) {
    // This regex splits the text after any of ., !, ? that is optionally followed by whitespace.
    // The negative lookbehind `(?<!...)` is to avoid splitting on common abbreviations like Mr., Dr., etc.
    final abbreviations = 'Mr|Mrs|Ms|Dr|Sr|Jr|e\.g|i\.e|etc|U\.S|U\. S'; // Added "U. S" for robustness
    // The `\b` (word boundary) was removed as it was too strict for multi-part abbreviations.
    final sentenceEndRegex = RegExp('(?<!($abbreviations))(?<=[.?!])\s*');

    return paragraph
        .split(sentenceEndRegex)
        // Additional cleanup to remove artifacts like chapter numbers from the start of sentences.
        .map((s) => s.trim().replaceAll(RegExp(r'^[IVXLC]+\s*'), '').trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  // More aggressive, static noise filter based on debug logs.
  static bool isNoise(String line) {
    final lowerCaseLine = line.toLowerCase();
    // Filter out lines that are just numbers, slashes, and spaces.
    if (line.trim().isNotEmpty && line.trim().replaceAll(RegExp(r'[\d\s/]'), '').isEmpty) return true;
    // Filter out copyright and ISBN lines.
    if (lowerCaseLine.contains('© copyright') || lowerCaseLine.contains('all rights reserved') || line.toUpperCase().contains('ISBN')) return true;

    // Filter out common title page/table of contents words if they appear alone on a line.
    const noiseWords = ['contents', 'introduction', 'chapter', 'table of contents'];
    if (noiseWords.contains(lowerCaseLine)) return true;

    return false;
  }

  // Extracts metadata by searching for common title/author patterns in the raw text.
  static (String?, String?) extractMetadata(String rawText) {
    String? foundTitle;
    String? foundAuthor;

    final lines = rawText.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    final searchLines = lines.take(50).toList();
    int? authorLineIndex;

    for (int i = 0; i < searchLines.length; i++) {
      final line = searchLines[i];
      if (line.toLowerCase().startsWith('by ')) {
        final potentialAuthor = line.substring(3).trim();
        if (potentialAuthor.split(' ').length < 5 && potentialAuthor.isNotEmpty) {
          foundAuthor = potentialAuthor;
          authorLineIndex = i;
          break;
        }
      }
    }

    if (authorLineIndex != null && authorLineIndex > 0) {
      foundTitle = searchLines[authorLineIndex - 1];
    } else {
      for (final line in searchLines) {
        if (!isNoise(line)) {
          foundTitle = line;
          break;
        }
      }
    }

    // Post-process the found title to remove junk.
    if (foundTitle != null) {
      final tocIndex = foundTitle.toLowerCase().indexOf('table of contents');
      if (tocIndex != -1) {
        foundTitle = foundTitle.substring(0, tocIndex).trim();
      }
      // Remove trailing roman numerals
      foundTitle = foundTitle.replaceAll(RegExp(r'\s*[IVXLC]+$'), '').trim();
    }

    foundTitle = foundTitle?.replaceAll(RegExp(r'^\W+|\W+$'), '');
    foundAuthor = foundAuthor?.replaceAll(RegExp(r'^\W+|\W+$'), '');

    return (foundTitle, foundAuthor);
  }
}
