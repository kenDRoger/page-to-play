import 'package:flutter/material.dart';
import 'package:page_to_play/utilities/constants.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _tutorialData = [
    {
      'image': 'assets/step1.png',
      'title': 'Import Your Ebooks',
      'content':
          'Tap the "+" button in your library to import ebooks from your device. You can upload up to 5 books per day.',
    },
    {
      'image': 'assets/step2.png',
      'title': 'From Text to Speech',
      'content':
          'After importing, you can review and edit the extracted text before it\'s converted into an audiobook.',
    },
    {
      'image': 'assets/step3.png',
      'title': 'Organize with Playlists',
      'content':
          'Group your audiobooks into playlists from the "Playlists" tab. You can add books from the library or even while you\'re listening.',
    },
    {
      'image': 'assets/step4.png',
      'title': 'Seamless Listening',
      'content':
          'Play books individually or as a playlist. The player automatically proceeds to the next book and even skips any that are missing.',
    },
    {
      'image': 'assets/step5.png',
      'title': 'Customize Your App',
      'content':
          'Visit Settings to switch between light and dark themes or to adjust the TTS voice and playback speed.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: kSplashScreenDecoration,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _tutorialData.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return TutorialPage(
                    imageData: _tutorialData[index],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _tutorialData.length,
                      (index) => buildDot(index, context),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _tutorialData.length - 1) {
                        Navigator.of(context).pushReplacementNamed('/library');
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text(
                      _currentPage == _tutorialData.length - 1 ? 'DONE' : 'NEXT',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 10,
      width: _currentPage == index ? 25 : 10,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: _currentPage == index ? Colors.white : Colors.white54,
      ),
    );
  }
}

class TutorialPage extends StatelessWidget {
  const TutorialPage({super.key, required this.imageData});

  final Map<String, String>? imageData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imageData!['image']!,
            height: MediaQuery.of(context).size.height * 0.4,
          ),
          const SizedBox(height: 40),
          Text(
            imageData!['title']!,
            style: kTutorialTitleTextStyle.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            imageData!['content']!,
            style: kTutorialContentTextStyle.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
