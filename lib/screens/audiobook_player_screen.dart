
import 'package:flutter/material.dart';

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
  final ScrollController _scrollController = ScrollController();
  final double _itemHeight = 80.0; // Using a fixed height for each item

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.position.hasPixels) return;

    final newIndex = (_scrollController.offset / _itemHeight).round();

    if (newIndex != _currentSentenceIndex && newIndex >= 0 && newIndex < _sentences.length) {
      setState(() {
        _currentSentenceIndex = newIndex;
      });
    }
  }

  void _scrollToIndex(int index) {
    if (!_scrollController.position.hasPixels) return;

    final targetOffset = index * _itemHeight;

    _scrollController.animateTo(
      targetOffset.clamp(0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
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
              builder: (context, constraints) {
                final viewportHeight = constraints.maxHeight;
                final verticalPadding = (viewportHeight / 2) - (_itemHeight / 2);

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: _sentences.length,
                  itemExtent: _itemHeight, // Enforce a fixed height for each item
                  padding: EdgeInsets.symmetric(vertical: verticalPadding > 0 ? verticalPadding : 0),
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
