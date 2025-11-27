
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

void main() {
  runApp(const MaterialApp(home: AudiobookPlayerScreen()));
}

class AudiobookPlayerScreen extends StatefulWidget {
  const AudiobookPlayerScreen({super.key});

  @override
  State<AudiobookPlayerScreen> createState() => _AudiobookPlayerScreenState();
}

class _AudiobookPlayerScreenState extends State<AudiobookPlayerScreen> {
  int _currentSentenceIndex = 0;
  final List<String> _sentences = List.generate(
    50,
    (index) => 'This is sentence number ${index + 1}. As the text gets longer, '
        'it will eventually wrap to the next line, demonstrating how the layout handles multiple lines of text.',
  );
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();
    _itemPositionsListener.itemPositions.addListener(_onScroll);
  }

  void _onScroll() {
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    // Find the item near the top center of the viewport
    final viewportCenter = 0.4;
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
      alignment: 0.5, // Align to the center of the viewport
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Audiobook Title'),
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
          Slider(
            value: 0.5,
            onChanged: (value) {},
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double verticalPadding = (constraints.maxHeight / 2);

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
      ),
    );
  }
}
