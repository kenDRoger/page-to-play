import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:page_to_play/service/text_processing_service.dart';

enum EbookStatus {
  awaitingReview,
  done,
  processing;

  String get displayName {
    switch (this) {
      case EbookStatus.awaitingReview:
        return 'Awaiting Review';
      case EbookStatus.done:
        return 'Ready to Play';
      case EbookStatus.processing:
        return 'Processing';
      default:
        return '';
    }
  }
}

class EBook {
  String? id;
  final String title;
  final String author;
  final List<String> content;
  EbookStatus status;

  EBook({
    this.id,
    required this.title,
    required this.author,
    required this.content,
    this.status = EbookStatus.awaitingReview,
  });

  // Convert an EBook object into a map for Firestore.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'content': content,
      'status': status.toString(),
    };
  }

  // Create an EBook object from a Firestore document snapshot, including content.
  factory EBook.fromJson(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EBook(
      id: doc.id,
      title: data['title'] ?? 'Untitled',
      author: data['author'] ?? 'Unknown Author',
      content: List<String>.from(data['content'] ?? []),
      status: EbookStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
        orElse: () => EbookStatus.awaitingReview,
      ),
    );
  }

  // Create an EBook object from a Firestore document snapshot, excluding content.
  // Only used for Library Screen as it doesn't need content
  factory EBook.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EBook(
      id: doc.id,
      title: data['title'] ?? 'Untitled',
      author: data['author'] ?? 'Unknown Author',
      content: [], // Content is intentionally left empty
      status: EbookStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
        orElse: () => EbookStatus.awaitingReview,
      ),
    );
  }

  factory EBook.fromExtractedText(String title, String author, String rawText) {
    final sentences = TextProcessingService.cleanAndStructureText(rawText);
    return EBook(title: title, author: author, content: sentences);
  }
}
