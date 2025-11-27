
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:page_to_play/models/ebook.dart';
import 'package:page_to_play/service/firebase_service.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MaterialApp(home: AudiobookPlayerScreen(ebookId: '0Nq8qKLVKRm08L8Jhsjw')));
}

class AudiobookPlayerScreen extends StatefulWidget {
  final String ebookId;
  const AudiobookPlayerScreen({super.key, required this.ebookId});

  @override
  State<AudiobookPlayerScreen> createState() => _AudiobookPlayerScreenState();
}

class _AudiobookPlayerScreenState extends State<AudiobookPlayerScreen> {
  late Future<EBook> _ebookFuture;
  int _currentSentenceIndex = 0;
  List<String> _sentences = [];
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();
    // Create the future once and store it.
    _ebookFuture = FirebaseService().getEbook(widget.ebookId);
    _itemPositionsListener.itemPositions.addListener(_onScroll);
  }

  void _onScroll() {
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    // Find the item near the top center of the viewport
    const viewportCenter = 0.4;
    int? centerItemIndex;
    double minDifference = double.infinity;

    for (var position in positions) {
      final itemCenter = (position.itemLeadingEdge + position.itemTrailingEdge) / 2;
      final difference = (itemCenter - viewportCenter).abs();

      if (difference < minDifference) {
        minDifference = difference;
        centerItemIndex = position.index;
      }
    }

    if (centerItemIndex != null && centerItemIndex != _currentSentenceIndex) {
      setState(() {
        _currentSentenceIndex = centerItemIndex!;
        _onSentenceSelected();
      });
    }
  }

  void _onSentenceSelected() {
    // This function is called when a new sentence is selected.
    // You can add your logic here, for example, to trigger TTS playback.
    print('Sentence ${_currentSentenceIndex + 1} selected.');
  }

  void _scrollToIndex(int index) {
    _itemScrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: 0.4, // Align to the near top center of the viewport
    );
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audiobook Player'),
      ),
      body: FutureBuilder<EBook>(
        future: _ebookFuture, // Use the stored future
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Ebook not found.'));
          }

          final ebook = snapshot.data!;
          // Only assign sentences if the list is empty to avoid resetting it on rebuilds
          if (_sentences.isEmpty) {
            _sentences = ebook.content;
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(ebook.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous),
                    onPressed: () {
                      if (_currentSentenceIndex > 0) {
                        _scrollToIndex(_currentSentenceIndex - 1);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () {
                      // In a real app, this would play/pause the TTS
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    onPressed: () {
                      if (_currentSentenceIndex < _sentences.length - 1) {
                        _scrollToIndex(_currentSentenceIndex + 1);
                      }
                    },
                  ),
                ],
              ),
              if (_sentences.isNotEmpty)
                Slider(
                  value: _currentSentenceIndex.toDouble() / (_sentences.length - 1),
                  onChanged: (double value) {
                    final newIndex = (value * (_sentences.length - 1)).round();
                    _scrollToIndex(newIndex);
                  },
                )
              else
                const Slider(value: 0, onChanged: null),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final double verticalPadding = (constraints.maxHeight / 2.5);

                    return ScrollablePositionedList.builder(
                      padding: EdgeInsets.symmetric(vertical: verticalPadding),
                      itemCount: _sentences.length,
                      itemScrollController: _itemScrollController,
                      itemPositionsListener: _itemPositionsListener,
                      itemBuilder: (context, index) {
                        final isSelected = index == _currentSentenceIndex;
                        return Container(
                          color: isSelected ? Colors.lightBlue.withOpacity(0.3) : Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                          child: Text(
                            _sentences[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
