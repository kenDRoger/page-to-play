
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:page_to_play/models/ebook.dart';

// Custom exception for handling duplicate ebook entries.
class EbookAlreadyExistsException implements Exception {
  final String message;
  EbookAlreadyExistsException(this.message);

  @override
  String toString() => message;
}

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'books';

  // Add a new ebook to the Firestore collection, checking for duplicates first.
  Future<void> addEbook(EBook ebook) async {
    const serviceName = 'FirebaseService';
    try {
      // Query for books with the same title and author.
      final querySnapshot = await _firestore
          .collection(_collectionPath)
          .where('title', isEqualTo: ebook.title)
          .where('author', isEqualTo: ebook.author)
          .limit(1)
          .get();

      // If a document is found, it's a duplicate.
      if (querySnapshot.docs.isNotEmpty) {
        final message = 'Ebook with title "${ebook.title}" already exists.';
        log(message, name: serviceName);
        throw EbookAlreadyExistsException(message);
      }

      // If no duplicates are found, add the new ebook.
      await _firestore.collection(_collectionPath).add(ebook.toJson());
      log('Successfully added ebook: ${ebook.title}', name: serviceName);

    } catch (e, s) {
      // Re-throw our custom exception directly.
      if (e is EbookAlreadyExistsException) {
        rethrow;
      }
      // Log other errors and re-throw them to be handled by the UI.
      log("Error adding ebook to Firebase", name: serviceName, error: e, stackTrace: s);
      rethrow;
    }
  }

  // Fetch a single ebook by its ID.
  Future<EBook> getEbook(String id) async {
    final doc = await _firestore.collection(_collectionPath).doc(id).get();
    return EBook.fromJson(doc);
  }

  // Fetch all ebooks as a stream for real-time updates, without their content.
  Stream<List<EBook>> getEbooks() {
    return _firestore.collection(_collectionPath).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => EBook.fromSnapshot(doc)).toList();
    });
  }

  // Fetch a list of ebooks by their IDs.
  Future<List<EBook>> getEbooksByIds(List<String> ids) async {
    if (ids.isEmpty) {
      return [];
    }
    final querySnapshot = await _firestore
        .collection(_collectionPath)
        .where(FieldPath.documentId, whereIn: ids)
        .get();
    return querySnapshot.docs.map((doc) => EBook.fromSnapshot(doc)).toList();
  }
}
