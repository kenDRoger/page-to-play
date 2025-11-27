
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


class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),

      ),
      body: StreamBuilder<List<EBook>>(
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

          final ebooks = snapshot.data!;

          return ListView.builder(
            itemCount: ebooks.length,
            addAutomaticKeepAlives: false,
            itemBuilder: (context, index) {
              final ebook = ebooks[index];
              return ListTile(
                title: Text(ebook.title),
                subtitle: Text(ebook.author),
                trailing: Text(ebook.status.toString().split('.').last),
                onTap: () {
                  if (ebook.id != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AudiobookPlayerScreen(ebookId: ebook.id!),
                      ),
                    );
                  } else {
                    // Handle the case where the ebook ID is null
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error: Ebook ID is missing.')),
                    );
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: () =>{
        Navigator.pushNamed(context, '/conversion')
      }),
    );
  }
}
