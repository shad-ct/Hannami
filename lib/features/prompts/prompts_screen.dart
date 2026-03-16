import 'dart:convert';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/widgets/bottom_nav.dart';

class PromptsScreen extends StatefulWidget {
  final bool showBottomNav;
  const PromptsScreen({super.key, this.showBottomNav = true});

  @override
  State<PromptsScreen> createState() => _PromptsScreenState();
}

class _PromptsScreenState extends State<PromptsScreen>
  with SingleTickerProviderStateMixin {
  final Random _random = Random();
  final AudioPlayer _player = AudioPlayer();
  late final AnimationController _didAnimationController;
  late final Animation<double> _didFade;
  late final Animation<double> _didScale;
  List<_PromptItem> _prompts = const [];
  final Set<int> _donePromptIds = <int>{};
  int _currentIndex = 0;
  bool _showDidOnly = false;

  List<_PromptItem> get _visiblePrompts {
    if (_showDidOnly) {
      return _prompts.where((p) => _donePromptIds.contains(p.id)).toList();
    }
    return _prompts.where((p) => !_donePromptIds.contains(p.id)).toList();
  }

  void _clampCurrentIndex() {
    final length = _visiblePrompts.length;
    if (length == 0) {
      _currentIndex = 0;
      return;
    }
    if (_currentIndex >= length) {
      _currentIndex = length - 1;
    }
    if (_currentIndex < 0) {
      _currentIndex = 0;
    }
  }

  @override
  void initState() {
    super.initState();
    _didAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );
    _didFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _didAnimationController,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
        reverseCurve: const Interval(0.55, 1.0, curve: Curves.easeIn),
      ),
    );
    _didScale = Tween<double>(begin: 0.7, end: 1.1).animate(
      CurvedAnimation(
        parent: _didAnimationController,
        curve: Curves.easeOutBack,
      ),
    );
    _loadPrompts();
  }

  @override
  void dispose() {
    _didAnimationController.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _loadPrompts() async {
    final raw = await rootBundle.loadString('lib/models/prompts.json');
    final decoded = (jsonDecode(raw) as List<dynamic>)
        .map((item) => _PromptItem.fromJson(item as Map<String, dynamic>))
        .toList();
    decoded.shuffle(_random);
    if (!mounted) return;
    setState(() {
      _prompts = decoded;
      _currentIndex = 0;
    });
  }

  void _goNext() {
    final visible = _visiblePrompts;
    if (visible.isEmpty || _currentIndex >= visible.length - 1) return;
    setState(() => _currentIndex += 1);
  }

  void _goPrevious() {
    if (_visiblePrompts.isEmpty || _currentIndex <= 0) return;
    setState(() => _currentIndex -= 1);
  }

  Future<void> _toggleDid() async {
    final visible = _visiblePrompts;
    if (visible.isEmpty) return;
    final id = visible[_currentIndex].id;
    final wasDone = _donePromptIds.contains(id);
    setState(() {
      if (wasDone) {
        _donePromptIds.remove(id);
      } else {
        _donePromptIds.add(id);
      }
      _clampCurrentIndex();
    });
    if (!wasDone) {
      _didAnimationController.forward(from: 0);
    }
    try {
      await _player.play(AssetSource('Ding Sound Effect.mp3'));
    } catch (_) {
      // Ignore playback errors to keep the double-tap interaction responsive.
    }
  }

  @override
  Widget build(BuildContext context) {
    final routeName = ModalRoute.of(context)?.settings.name;
    final visible = _visiblePrompts;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Prompts'),
        actions: [
          IconButton(
            tooltip: _showDidOnly ? 'Show home prompts' : 'Show did prompts',
            onPressed: () {
              setState(() {
                _showDidOnly = !_showDidOnly;
                _clampCurrentIndex();
              });
            },
            icon: Icon(
              _showDidOnly ? Icons.check_circle : Icons.check_circle_outline,
              color: _showDidOnly ? Colors.green : null,
            ),
          ),
          IconButton(
            tooltip: 'Shuffle prompts',
            onPressed: _prompts.isEmpty
                ? null
                : () {
                    setState(() {
                      _prompts = [..._prompts]..shuffle(_random);
                      _currentIndex = 0;
                      _clampCurrentIndex();
                    });
                  },
            icon: const Icon(Icons.shuffle),
          ),
        ],
      ),
      body: _prompts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : visible.isEmpty
          ? Center(
              child: Text(
                _showDidOnly
                    ? 'No did prompts yet. Double tap a prompt to mark one.'
                    : 'No prompts left in Home. Open the Did list from the tick button.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final canGoNext = _currentIndex < visible.length - 1;
                final canGoPrevious = _currentIndex > 0;
                final current = visible[_currentIndex];
                final next = canGoNext ? visible[_currentIndex + 1] : null;
                final prev = canGoPrevious ? visible[_currentIndex - 1] : null;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    children: [
                      Text(
                        _showDidOnly
                            ? 'Did list. Double tap card to undo. Use buttons below to move between prompts.'
                            : 'Home prompts. Did prompts are hidden here. Double tap card to mark as did.',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (prev != null)
                              _PromptCard(
                                prompt: prev,
                                isDone: _donePromptIds.contains(prev.id),
                                width: constraints.maxWidth - 44,
                                height: constraints.maxHeight * 0.56,
                                scale: 0.9,
                                yOffset: -10,
                                opacity: 0.2,
                              ),
                            if (next != null)
                              _PromptCard(
                                prompt: next,
                                isDone: _donePromptIds.contains(next.id),
                                width: constraints.maxWidth - 30,
                                height: constraints.maxHeight * 0.6,
                                scale: 0.95,
                                yOffset: 12,
                                opacity: 0.5,
                              ),
                            GestureDetector(
                              onDoubleTap: _toggleDid,
                              child: _PromptCard(
                                prompt: current,
                                isDone: _donePromptIds.contains(current.id),
                                width: constraints.maxWidth - 16,
                                height: constraints.maxHeight * 0.63,
                                scale: 1,
                                yOffset: 0,
                                opacity: 1,
                              ),
                            ),
                            IgnorePointer(
                              child: AnimatedBuilder(
                                animation: _didAnimationController,
                                builder: (context, _) {
                                  if (_didAnimationController.value == 0) {
                                    return const SizedBox.shrink();
                                  }
                                  final fadeOut = 1 - _didAnimationController.value;
                                  return Opacity(
                                    opacity: (_didFade.value * fadeOut).clamp(0, 1),
                                    child: Transform.scale(
                                      scale: _didScale.value,
                                      child: Container(
                                        width: 124,
                                        height: 124,
                                        decoration: const BoxDecoration(
                                          color: Color(0xCC2E7D32),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 72,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton.icon(
                            onPressed: canGoPrevious ? _goPrevious : null,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Previous'),
                          ),
                          Text('${_currentIndex + 1}/${_prompts.length}'),
                          OutlinedButton.icon(
                            onPressed: canGoNext ? _goNext : null,
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Next'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: widget.showBottomNav
          ? HannamiBottomNav(currentRoute: routeName)
          : null,
    );
  }
}

class _PromptCard extends StatelessWidget {
  final _PromptItem prompt;
  final bool isDone;
  final double width;
  final double height;
  final double scale;
  final double yOffset;
  final double opacity;

  const _PromptCard({
    required this.prompt,
    required this.isDone,
    required this.width,
    required this.height,
    required this.scale,
    required this.yOffset,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(0, yOffset),
        child: Transform.scale(
          scale: scale,
          child: SizedBox(
            width: width,
            height: height,
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Chip(label: Text(prompt.type)),
                        const Spacer(),
                        if (isDone)
                          const Chip(
                            avatar: Icon(Icons.check_circle, size: 16),
                            label: Text('Did'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      prompt.question,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    Text(
                      'Prompt #${prompt.id}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PromptItem {
  final int id;
  final String question;
  final String type;

  const _PromptItem({
    required this.id,
    required this.question,
    required this.type,
  });

  factory _PromptItem.fromJson(Map<String, dynamic> json) {
    return _PromptItem(
      id: json['id'] as int,
      question: json['question'] as String,
      type: json['type'] as String,
    );
  }
}