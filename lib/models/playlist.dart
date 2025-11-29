import 'dart:convert';

class Playlist {
  String name;
  String description;
  List<String> ebookIds;

  Playlist({
    required this.name,
    this.description = '',
    this.ebookIds = const [],
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      ebookIds: (json['ebookIds'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'ebookIds': ebookIds,
    };
  }

  String toJsonString() => json.encode(toJson());

  factory Playlist.fromJsonString(String jsonString) =>
      Playlist.fromJson(json.decode(jsonString) as Map<String, dynamic>);

  void reorderEbook(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final ebookId = ebookIds.removeAt(oldIndex);
    ebookIds.insert(newIndex, ebookId);
  }
}
