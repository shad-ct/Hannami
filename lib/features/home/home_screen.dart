import 'package:flutter/material.dart';
import '../../core/widgets/hannami_card.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../core/widgets/swipe_nav.dart';
import '../diary/diary_editor_screen.dart';
import '../diary/diary_search_delegate.dart';
import 'home_controller.dart';
import '../../models/diary_entry.dart';

class HomeScreen extends StatefulWidget {
  final bool showBottomNav;
  final bool enableSwipeNav;
  const HomeScreen({super.key, this.showBottomNav = true, this.enableSwipeNav = true});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = HomeController();
  late Future<List<DiaryEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = _controller.loadEntries();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _controller.loadEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeName = ModalRoute.of(context)?.settings.name;
    final content = Scaffold(
      appBar: AppBar(
        title: const Text('Hannami'),
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
          IconButton(
            onPressed: () async {
              final selected = await showSearch<DiaryEntry?>(
                context: context,
                delegate: DiarySearchDelegate(),
              );
              if (selected != null && mounted) {
                Navigator.pushNamed(context, '/diary-detail', arguments: selected);
              }
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: FutureBuilder<List<DiaryEntry>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
            final entries = snapshot.data ?? const [];
          if (entries.isEmpty) {
            return Center(
              child: Text('No entries yet. Tap + to create.', style: Theme.of(context).textTheme.bodyMedium),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemBuilder: (context, index) {
              final e = entries[index];
              return HannamiCard(
                title: e.title,
                snippet: e.content,
                date: e.dateTime,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/diary-detail',
                  arguments: e,
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: entries.length,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const DiaryEditorScreen(),
            ),
          );
          if (result != null) {
            await _refresh();
          }
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: widget.showBottomNav ? HannamiBottomNav(currentRoute: routeName) : null,
    );

    if (widget.enableSwipeNav) {
      return SwipeNav(currentRoute: routeName, child: content);
    }
    return content;
  }
}
