
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: AudiobookPlayerScreen()));
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

  void _scrollToCurrentSentence() {
    // In a real app, you'd calculate the exact scroll position.
    // For this example, we'll just jump to the item.
    _scrollController.animateTo(
      _currentSentenceIndex * 60.0, // Assuming a fixed item height for simplicity
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
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
                    setState(() {
                      _currentSentenceIndex--;
                      _scrollToCurrentSentence();
                    });
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
                    setState(() {
                      _currentSentenceIndex++;
                      _scrollToCurrentSentence();
                    });
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
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _sentences.length,
              itemBuilder: (context, index) {
                final isSelected = index == _currentSentenceIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentSentenceIndex = index;
                    });
                  },
                  child: Container(
                    color: isSelected ? Colors.lightBlue.withValues(alpha:0.3) : Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                    child: Text(
                      _sentences[index],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
