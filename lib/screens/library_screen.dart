import 'package:flutter/material.dart';
import 'package:page_to_play/models/ebook.dart';
import 'package:page_to_play/models/playlist.dart';
import 'package:page_to_play/screens/audiobook_player_screen.dart';
import 'package:page_to_play/screens/playlist_details_screen.dart';
import 'package:page_to_play/service/firebase_service.dart';
import 'package:page_to_play/service/playlist_service.dart';
import 'package:page_to_play/utilities/constants.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  late TabController _tabController;
  final PlaylistService _playlistService = PlaylistService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Books'),
            Tab(text: 'Playlists'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllBooksView(),
          _buildPlaylistsView(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton() {
    return _tabController.index == 0
        ? FloatingActionButton(
            onPressed: () => Navigator.pushNamed(context, '/conversion'),
            child: const Icon(Icons.add),
          )
        : FloatingActionButton(
            onPressed: _showCreatePlaylistDialog,
            child: const Icon(Icons.playlist_add),
          );
  }

  void _showCreatePlaylistDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Playlist'),
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
                  _playlistService.createPlaylist(nameController.text,
                      description: descriptionController.text);
                  Navigator.pop(context);
                  setState(() {});
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAllBooksView() {
    return Column(
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
              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
              hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
            ),
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
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
                    child: Text('Error: ${snapshot.error}',
                        style: kBodyTextStyle.apply(
                            color: Theme.of(context).textTheme.bodyMedium?.color)));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                    child: Text('No ebooks found. Add one to get started!',
                        style: kBodyTextStyle.apply(
                            color: Theme.of(context).textTheme.bodyMedium?.color)));
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
                return Center(
                    child: Text('No ebooks match your search.',
                        style: kBodyTextStyle.apply(
                            color: Theme.of(context).textTheme.bodyMedium?.color)));
              }

              return ListView.builder(
                itemCount: filteredEbooks.length,
                itemBuilder: (context, index) {
                  final ebook = filteredEbooks[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    color: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      title: Text(ebook.title,
                          style: kSubheadingTextStyle
                              .apply(
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.color)
                              .copyWith(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ebook.author,
                              style: kBodyTextStyle.apply(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withOpacity(0.7))),
                          const SizedBox(height: 4),
                          Text(
                            ebook.status.displayName,
                            style: kBodyTextStyle.apply(
                                color: ebook.status == EbookStatus.processing
                                    ? Colors.orangeAccent
                                    : ebook.status == EbookStatus.done
                                        ? Colors.greenAccent
                                        : Colors.grey,
                                fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                      trailing: _buildAddToPlaylistButton(ebook),
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
    );
  }

  Widget _buildAddToPlaylistButton(EBook ebook) {
    return FutureBuilder<List<Playlist>>(
        future: _playlistService.getPlaylists(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const SizedBox.shrink();
          }
          return PopupMenuButton<String>(
            onSelected: (String playlistName) {
              if (ebook.id != null) {
                _playlistService.addEbookToPlaylist(playlistName, ebook.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added to $playlistName')),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  enabled: false,
                  child: Text('Add to Playlist'),
                ),
                const PopupMenuDivider(),
                ...snapshot.data!.map((playlist) {
                  return PopupMenuItem<String>(
                    value: playlist.name,
                    child: Text(playlist.name),
                  );
                })
              ];
            },
          );
        });
  }

  Widget _buildPlaylistsView() {
    return FutureBuilder<List<Playlist>>(
      future: _playlistService.getPlaylists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No playlists yet. Create one!'));
        }

        final playlists = snapshot.data!;

        return ListView.builder(
          itemCount: playlists.length,
          itemBuilder: (context, index) {
            final playlist = playlists[index];
            return ListTile(
              title: Text(playlist.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(playlist.description),
                  Text('${playlist.ebookIds.length} books'),
                ],
              ),
              trailing: playlist.ebookIds.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AudiobookPlayerScreen(
                              ebookId: playlist.ebookIds.first,
                              playlist: playlist,
                            ),
                          ),
                        );
                      },
                    )
                  : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PlaylistDetailsScreen(playlist: playlist),
                  ),
                ).then((_) => setState(() {}));
              },
            );
          },
        );
      },
    );
  }
}
