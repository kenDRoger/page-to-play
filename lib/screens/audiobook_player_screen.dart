
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:page_to_play/models/ebook.dart';
import 'package:page_to_play/service/firebase_service.dart';
import 'package:page_to_play/service/tts_service.dart';
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
  final TtsService _ttsService = TtsService();
  bool _isManuallyScrolling = false;

  @override
  void initState() {
    super.initState();
    _ebookFuture = FirebaseService().getEbook(widget.ebookId);
    _itemPositionsListener.itemPositions.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isManuallyScrolling) {
      if (_ttsService.isPlaying) {
        _ttsService.pause();
        setState(() {});
      }

      final positions = _itemPositionsListener.itemPositions.value;
      if (positions.isEmpty) return;

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
        });
      }
    }
  }

  void _playSequence() async {
    if (_sentences.isEmpty) return;

    // Start playing
    setState(() {
      _ttsService.isPlaying = true;
    });

    while (_ttsService.isPlaying && _currentSentenceIndex < _sentences.length) {
      // Update the UI before speaking
      setState(() {});
      _scrollToIndex(_currentSentenceIndex, isManual: false);

      await _ttsService.speak(_sentences[_currentSentenceIndex]);

      if (_ttsService.isPlaying && _currentSentenceIndex < _sentences.length - 1) {
        _currentSentenceIndex++;
      } else {
        // Stop playing if it was the last sentence
        setState(() {
          _ttsService.isPlaying = false;
        });
      }
    }
  }

  void _scrollToIndex(int index, {bool isManual = true}) {
    _isManuallyScrolling = isManual;
    _itemScrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: 0.4,
    );
    // Reset the flag after the scroll completes
    Future.delayed(const Duration(milliseconds: 400), () {
      _isManuallyScrolling = false;
    });
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(_onScroll);
    _ttsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audiobook Player'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: FutureBuilder<EBook>(
        future: _ebookFuture,
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
                    icon: Icon(_ttsService.isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: () {
                      if (_ttsService.isPlaying) {
                        _ttsService.pause();
                      } else {
                        _playSequence();
                      }
                      setState(() {});
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

                    return NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is ScrollStartNotification && notification.dragDetails != null) {
                          _isManuallyScrolling = true;
                        } else if (notification is ScrollEndNotification) {
                          Future.delayed(const Duration(milliseconds: 200), () {
                            _isManuallyScrolling = false;
                          });
                        }
                        return false;
                      },
                      child: ScrollablePositionedList.builder(
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
                      ),
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
