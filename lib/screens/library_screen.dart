import 'package:flutter/material.dart';
import 'package:page_to_play/models/ebook.dart';
import 'package:page_to_play/screens/audiobook_player_screen.dart';
import 'package:page_to_play/service/firebase_service.dart';
import 'package:page_to_play/utilities/constants.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: kTextFieldInputDecoration.copyWith(
                hintText: 'Search by title or author',
                prefixIcon: const Icon(Icons.search),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<EBook>>(
              stream: FirebaseService().getEbooks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}', style: kBodyTextStyle));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('No ebooks found. Add one to get started!',
                          style: kBodyTextStyle));
                }

                final allEbooks = snapshot.data!;
                final filteredEbooks = _searchQuery.isEmpty
                    ? allEbooks
                    : allEbooks.where((ebook) {
                        final title = ebook.title.toLowerCase();
                        final author = ebook.author.toLowerCase();
                        final query = _searchQuery.toLowerCase();
                        return title.contains(query) || author.contains(query);
                      }).toList();

                if (filteredEbooks.isEmpty) {
                  return const Center(
                      child: Text('No ebooks match your search.',
                          style: kBodyTextStyle));
                }

                return ListView.builder(
                  itemCount: filteredEbooks.length,
                  itemBuilder: (context, index) {
                    final ebook = filteredEbooks[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      color: const Color(0xFF1F1F1F),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        title: Text(ebook.title,
                            style: kSubheadingTextStyle.copyWith(
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(ebook.author,
                            style: kBodyTextStyle.copyWith(color: Colors.white54)),
                        trailing: Text(
                          ebook.status.displayName,
                          style: kBodyTextStyle.copyWith(
                              color: ebook.status == EbookStatus.processing
                                  ? Colors.orangeAccent
                                  : ebook.status == EbookStatus.done
                                      ? Colors.greenAccent
                                      : Colors.grey,
                              fontStyle: FontStyle.italic),
                        ),
                        onTap: () {
                          if (ebook.id != null &&
                              ebook.status == EbookStatus.done) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AudiobookPlayerScreen(ebookId: ebook.id!),
                              ),
                            );
                          } else if (ebook.status != EbookStatus.done) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Ebook is not ready to play yet.')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Error: Ebook ID is missing.')),
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => {Navigator.pushNamed(context, '/conversion')}),
    );
  }
}
