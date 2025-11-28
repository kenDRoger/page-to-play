import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:page_to_play/models/ebook.dart';
import 'package:page_to_play/screens/audiobook_player_screen.dart';
import 'package:page_to_play/service/firebase_service.dart';

import '../firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MaterialApp(home: LibraryScreen()));
}

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
        title: const Text('Page To Play Library'),
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
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Search by title or author',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
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
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No ebooks found.'));
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
                  return const Center(child: Text('No ebooks match your search.'));
                }

                return ListView.builder(
                  itemCount: filteredEbooks.length,
                  addAutomaticKeepAlives: false,
                  itemBuilder: (context, index) {
                    final ebook = filteredEbooks[index];
                    return ListTile(
                      title: Text(ebook.title),
                      subtitle: Text(ebook.author),
                      trailing: Text(ebook.status.toString().split('.').last),
                      onTap: () {
                        if (ebook.id != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AudiobookPlayerScreen(ebookId: ebook.id!),
                            ),
                          );
                        } else {
                          // Handle the case where the ebook ID is null
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Error: Ebook ID is missing.')),
                          );
                        }
                      },
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
