import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:page_to_play/service/text_processing_service.dart';

enum EbookStatus {
  awaitingReview,
  readyToPlay,
  processing,
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

  // Create an EBook object from a Firestore document snapshot.
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

  factory EBook.fromExtractedText(String title, String author, String rawText) {
    final sentences = TextProcessingService.cleanAndStructureText(rawText);
    return EBook(title: title, author: author, content: sentences);
  }
}
