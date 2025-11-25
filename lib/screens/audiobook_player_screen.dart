
import 'package:flutter/material.dart';

void main(){
  runApp(MaterialApp(home: AudiobookPlayerScreen()));
}

class AudiobookPlayerScreen extends StatelessWidget {
  const AudiobookPlayerScreen({super.key});

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
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: () {},
              ),
            ],
          ),
          Slider(
            value: 0.5,
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }
}
