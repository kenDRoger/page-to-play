import 'package:flutter/material.dart';
import 'package:page_to_play/models/ebook.dart';
import 'package:page_to_play/models/playlist.dart';
import 'package:page_to_play/screens/audiobook_player_screen.dart';
import 'package:page_to_play/service/firebase_service.dart';
import 'package:page_to_play/service/playlist_service.dart';

class PlaylistDetailsScreen extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailsScreen({super.key, required this.playlist});

  @override
  State<PlaylistDetailsScreen> createState() => _PlaylistDetailsScreenState();
}

class _PlaylistDetailsScreenState extends State<PlaylistDetailsScreen> {
  final PlaylistService _playlistService = PlaylistService();
  late Playlist _playlist;

  @override
  void initState() {
    super.initState();
    _playlist = widget.playlist;
  }

  void _showEditPlaylistDialog() {
    final nameController = TextEditingController(text: _playlist.name);
    final descriptionController =
        TextEditingController(text: _playlist.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Playlist'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Playlist name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(hintText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  _playlistService.updatePlaylist(
                    _playlist.name,
                    newName: nameController.text,
                    newDescription: descriptionController.text,
                  );
                  Navigator.pop(context);
                  setState(() {
                    _playlist.name = nameController.text;
                    _playlist.description = descriptionController.text;
                  });
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_playlist.name),
        actions: [
          if (_playlist.ebookIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AudiobookPlayerScreen(
                      ebookId: _playlist.ebookIds.first,
                      playlist: _playlist,
                    ),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditPlaylistDialog,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _playlistService.deletePlaylist(_playlist.name);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_playlist.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(_playlist.description),
            ),
          Expanded(
            child: FutureBuilder<List<EBook>>(
              future: FirebaseService().getEbooksByIds(_playlist.ebookIds),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No books in this playlist.'));
                }

                final fetchedEbooks = snapshot.data!;
                final ebookMap = {for (var ebook in fetchedEbooks) ebook.id: ebook};
                final ebooks = _playlist.ebookIds
                    .map((id) => ebookMap[id])
                    .whereType<EBook>()
                    .toList();

                return ReorderableListView.builder(
                  itemCount: ebooks.length,
                  itemBuilder: (context, index) {
                    final ebook = ebooks[index];
                    return ListTile(
                      key: ValueKey(ebook.id),
                      title: Text(ebook.title),
                      subtitle: Text(ebook.author),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          _playlistService.removeEbookFromPlaylist(
                              _playlist.name, ebook.id!);
                          setState(() {
                            _playlist.ebookIds.remove(ebook.id!);
                          });
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AudiobookPlayerScreen(
                                ebookId: ebook.id!,
                                playlist: _playlist),
                          ),
                        );
                      },
                    );
                  },
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      _playlist.reorderEbook(oldIndex, newIndex);

                      _playlistService.getPlaylists().then((playlists) {
                        final index = playlists
                            .indexWhere((p) => p.name == _playlist.name);
                        if (index != -1) {
                          playlists[index] = _playlist;
                          _playlistService.savePlaylists(playlists);
                        }
                      });
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
