import 'package:flutter/material.dart';
import 'package:page_to_play/models/ebook.dart';
import 'package:page_to_play/models/playlist.dart';
import 'package:page_to_play/screens/audiobook_player_screen.dart';
import 'package:page_to_play/service/firebase_service.dart';
import 'package:page_to_play/service/playlist_service.dart';
import 'package:page_to_play/utilities/constants.dart';

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
    final theme = Theme.of(context);

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
            onPressed: () async {
              final confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Playlist'),
                  content: const Text(
                      'Are you sure you want to delete this playlist?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await _playlistService.deletePlaylist(_playlist.name);
                if (mounted) {
                  Navigator.pop(context);
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_playlist.description.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16.0),
              width: double.infinity,
              color: theme.primaryColor.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About this playlist',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_playlist.description,
                      style: theme.textTheme.bodyMedium),
                ],
              ),
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.playlist_remove_outlined, size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text('No books in this playlist.', style: TextStyle(fontSize: 16)),
                        const Text('Add some from your library!', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                final fetchedEbooks = snapshot.data!;
                final ebookMap = {
                  for (var ebook in fetchedEbooks) ebook.id: ebook
                };
                final ebooks = _playlist.ebookIds
                    .map((id) => ebookMap[id])
                    .whereType<EBook>()
                    .toList();

                return ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: ebooks.length,
                  itemBuilder: (context, index) {
                    final ebook = ebooks[index];
                    return Card(
                      key: ValueKey(ebook.id),
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 16.0),
                        leading: const Icon(Icons.book, size: 40, color: kDeepIndigo),
                        title: Text(ebook.title,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(ebook.author,
                            style: TextStyle(color: Colors.grey.shade600)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: Colors.redAccent),
                              onPressed: () async {
                                final confirm = await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Remove Ebook'),
                                    content: const Text(
                                        'Are you sure you want to remove this ebook from the playlist?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Remove'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await _playlistService
                                      .removeEbookFromPlaylist(
                                          _playlist.name, ebook.id!);
                                  setState(() {
                                    _playlist.ebookIds.remove(ebook.id!);
                                  });
                                }
                              },
                            ),
                            const Icon(Icons.drag_handle),
                          ],
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
                      ),
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
