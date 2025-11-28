import 'package:flutter/material.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Use'),
      ),
      body: Stepper(
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_currentStep != 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('BACK'),
                  ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(_currentStep == 2 ? 'DONE' : 'CONTINUE'),
                ),
              ],
            ),
          );
        },
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() {
              _currentStep += 1;
            });
          } else {
            Navigator.of(context).pushReplacementNamed('/library');
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep -= 1;
            });
          }
        },
        steps: [
          Step(
            title: const Text('Import a Book'),
            content: Column(
              children: [
                const Text(
                    'Tap the + button on the library screen to import a book from your device.'),
                Image.asset('assets/step1.png'),
              ],
            ),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Convert to Audiobook'),
            content: Column(
              children: [
                const Text(
                    'Follow the steps to convert your ebook into an audiobook.'),
                Image.asset('assets/step2.png'),
              ],
            ),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Listen'),
            content: Column(
              children: [
                const Text(
                    'Once processed, you can listen to your audiobook at any time.'),
                Image.asset('assets/step3.png'),
              ],
            ),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }
}
