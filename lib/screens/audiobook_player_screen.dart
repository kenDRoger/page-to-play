import 'package:flutter/material.dart';
import 'package:page_to_play/models/ebook.dart';
import 'package:page_to_play/models/playlist.dart';
import 'package:page_to_play/service/firebase_service.dart';
import 'package:page_to_play/service/tts_service.dart';
import 'package:page_to_play/utilities/constants.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class AudiobookPlayerScreen extends StatefulWidget {
  final String ebookId;
  final Playlist? playlist;

  const AudiobookPlayerScreen({super.key, required this.ebookId, this.playlist});

  @override
  State<AudiobookPlayerScreen> createState() => _AudiobookPlayerScreenState();
}

class _AudiobookPlayerScreenState extends State<AudiobookPlayerScreen> {
  late Future<EBook> _ebookFuture;
  late String _currentEbookId;
  late Playlist? _playlist;
  bool _shouldAutoPlayNext = false;

  int _currentSentenceIndex = 0;
  List<String> _sentences = [];
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  TtsService _ttsService = TtsService();
  bool _isManuallyScrolling = false;

  @override
  void initState() {
    super.initState();
    _currentEbookId = widget.ebookId;
    _playlist = widget.playlist;
    _ebookFuture = FirebaseService().getEbook(_currentEbookId);
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
        final itemCenter =
            (position.itemLeadingEdge + position.itemTrailingEdge) / 2;
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

  void _playNextBookInPlaylist() {
    if (_playlist == null) return;
    final currentIndex = _playlist!.ebookIds.indexOf(_currentEbookId);
    if (currentIndex < _playlist!.ebookIds.length - 1) {
      final nextEbookId = _playlist!.ebookIds[currentIndex + 1];
      setState(() {
        _currentEbookId = nextEbookId;
        _ebookFuture = FirebaseService().getEbook(_currentEbookId);
        _sentences = [];
        _currentSentenceIndex = 0;
        _shouldAutoPlayNext = true;
        _ttsService.stop();
      });
    }
  }

  void _playPreviousBookInPlaylist() {
    if (_playlist == null) return;
    final currentIndex = _playlist!.ebookIds.indexOf(_currentEbookId);
    if (currentIndex > 0) {
      final prevEbookId = _playlist!.ebookIds[currentIndex - 1];
      setState(() {
        _currentEbookId = prevEbookId;
        _ebookFuture = FirebaseService().getEbook(_currentEbookId);
        _sentences = [];
        _currentSentenceIndex = 0;
        _shouldAutoPlayNext = true;
        _ttsService.stop();
      });
    }
  }

  void _playSequence() async {
    if (_sentences.isEmpty) return;

    setState(() {
      _ttsService.isPlaying = true;
    });

    while (_ttsService.isPlaying && _currentSentenceIndex < _sentences.length) {
      setState(() {});
      _scrollToIndex(_currentSentenceIndex, isManual: false);

      await _ttsService.speak(_sentences[_currentSentenceIndex]);

      if (!_ttsService.isPlaying) {
        break;
      }

      if (_currentSentenceIndex < _sentences.length - 1) {
        _currentSentenceIndex++;
      } else {
        _ttsService.isPlaying = false; // for UI and to stop loop

        if (_playlist != null) {
          final currentIndex = _playlist!.ebookIds.indexOf(_currentEbookId);
          if (currentIndex < _playlist!.ebookIds.length - 1) {
            _playNextBookInPlaylist();
            break;
          }
        }

        setState(() {}); // For UI update to show play button again
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audiobook Player'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              if (_ttsService.isPlaying) {
                _ttsService.stop();
              }
              Navigator.pushNamed(context, '/settings').then((_) {
                setState(() {
                  _ttsService = TtsService();
                });
              });
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

          if (_shouldAutoPlayNext) {
            _shouldAutoPlayNext = false;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _playSequence();
              }
            });
          }

          return Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final double verticalPadding =
                        (constraints.maxHeight / 2.5);

                    return NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is ScrollStartNotification &&
                            notification.dragDetails != null) {
                          _isManuallyScrolling = true;
                        } else if (notification is ScrollEndNotification) {
                          Future.delayed(const Duration(milliseconds: 200),
                              () {
                            _isManuallyScrolling = false;
                          });
                        }
                        return false;
                      },
                      child: ScrollablePositionedList.builder(
                        padding:
                            EdgeInsets.symmetric(vertical: verticalPadding),
                        itemCount: _sentences.length,
                        itemScrollController: _itemScrollController,
                        itemPositionsListener: _itemPositionsListener,
                        itemBuilder: (context, index) {
                          final isSelected = index == _currentSentenceIndex;
                          return Container(
                            decoration: isSelected
                                ? kPlayerSelectedSentenceDecoration
                                : null,
                            padding: const EdgeInsets.symmetric(
                                vertical: 20.0, horizontal: 16.0),
                            child: Text(
                              _sentences[index],
                              textAlign: TextAlign.center,
                              style: isSelected
                                  ? kPlayerContentSelectedTextStyle.apply(
                                      color:
                                          theme.textTheme.bodyLarge?.color)
                                  : kPlayerContentTextStyle.apply(
                                      color: theme.textTheme.bodyMedium?.color),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              _buildPlayerControls(ebook, theme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlayerControls(EBook ebook, ThemeData theme) {
    final bool hasPlaylist = _playlist != null;
    int? currentIndexInPlaylist;
    if (hasPlaylist) {
      currentIndexInPlaylist = _playlist!.ebookIds.indexOf(_currentEbookId);
    }

    final bool canGoPrevious = hasPlaylist &&
        currentIndexInPlaylist != null &&
        currentIndexInPlaylist > 0;
    final bool canGoNext = hasPlaylist &&
        currentIndexInPlaylist != null &&
        currentIndexInPlaylist < _playlist!.ebookIds.length - 1;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(ebook.title,
              style: kPlayerTitleTextStyle.apply(
                  color: theme.textTheme.titleLarge?.color),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(ebook.author,
              style: kPlayerAuthorTextStyle.apply(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
              textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Slider(
            value: _sentences.isNotEmpty
                ? _currentSentenceIndex.toDouble() / (_sentences.length - 1)
                : 0,
            onChanged: _sentences.isNotEmpty
                ? (double value) {
                    final newIndex = (value * (_sentences.length - 1)).round();
                    if (newIndex != _currentSentenceIndex) {
                      setState(() {
                        _currentSentenceIndex = newIndex;
                      });
                      _scrollToIndex(newIndex, isManual: false);
                    }
                  }
                : null,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous,
                    size: kPlayerControlIconSize),
                onPressed:
                    canGoPrevious ? _playPreviousBookInPlaylist : null,
              ),
              const SizedBox(width: 20),
              IconButton(
                icon: Icon(
                    _ttsService.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    size: kPlayerMainControlIconSize),
                onPressed: () {
                  if (_ttsService.isPlaying) {
                    _ttsService.pause();
                  } else {
                    _playSequence();
                  }
                  setState(() {});
                },
              ),
              const SizedBox(width: 20),
              IconButton(
                icon: const Icon(Icons.skip_next, size: kPlayerControlIconSize),
                onPressed: canGoNext ? _playNextBookInPlaylist : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
