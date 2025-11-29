import 'package:page_to_play/models/playlist.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlaylistService {
  static const String _playlistsKey = 'playlists';

  Future<List<Playlist>> getPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final playlistStrings = prefs.getStringList(_playlistsKey) ?? [];
    return playlistStrings
        .map((p) => Playlist.fromJsonString(p))
        .toList();
  }

  Future<void> savePlaylists(List<Playlist> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    final playlistStrings = playlists.map((p) => p.toJsonString()).toList();
    await prefs.setStringList(_playlistsKey, playlistStrings);
  }

  Future<void> createPlaylist(String name, {String description = ''}) async {
    final playlists = await getPlaylists();
    if (playlists.any((p) => p.name == name)) {
      throw Exception('A playlist with this name already exists.');
    }
    playlists.add(Playlist(name: name, description: description));
    await savePlaylists(playlists);
  }

  Future<void> updatePlaylist(String name, {String? newName, String? newDescription}) async {
    final playlists = await getPlaylists();
    final playlist = playlists.firstWhere((p) => p.name == name);

    if (newName != null) {
      playlist.name = newName;
    }
    if (newDescription != null) {
      playlist.description = newDescription;
    }

    await savePlaylists(playlists);
  }

  Future<void> deletePlaylist(String name) async {
    final playlists = await getPlaylists();
    playlists.removeWhere((p) => p.name == name);
    await savePlaylists(playlists);
  }

  Future<void> addEbookToPlaylist(String playlistName, String ebookId) async {
    final playlists = await getPlaylists();
    final playlist = playlists.firstWhere((p) => p.name == playlistName);
    if (!playlist.ebookIds.contains(ebookId)) {
      playlist.ebookIds.add(ebookId);
      await savePlaylists(playlists);
    }
  }

  Future<void> removeEbookFromPlaylist(
      String playlistName, String ebookId) async {
    final playlists = await getPlaylists();
    final playlist = playlists.firstWhere((p) => p.name == playlistName);
    playlist.ebookIds.remove(ebookId);
    await savePlaylists(playlists);
  }
}
