
import 'package:flutter/material.dart';

void main(){
  runApp(MaterialApp(home: LibraryScreen()));
}

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Ebook 1'),
            subtitle: const Text('Author 1'),
            trailing: const Text('Awaiting Review'),
          ),
          ListTile(
            title: const Text('Audiobook 1'),
            subtitle: const Text('Author 1'),
            trailing: const Text('Ready to Play'),
          ),
        ],
      ),
    );
  }
}
