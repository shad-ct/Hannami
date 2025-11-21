import 'package:flutter/material.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../core/widgets/swipe_nav.dart';
import '../../models/diary_entry.dart';
import 'calendar_controller.dart';

class CalendarScreen extends StatefulWidget {
  final bool showBottomNav;
  final bool enableSwipeNav;
  const CalendarScreen({super.key, this.showBottomNav = true, this.enableSwipeNav = true});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _controller = CalendarController();
  late Future<List<DiaryEntry>> _future;
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _future = _controller.loadAll();
  }

  void _goMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  List<DateTime> _monthDays() {
    final first = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final firstWeekday = first.weekday; // 1=Mon .. 7=Sun
    final startOffset = firstWeekday % 7; // convert so Sunday=0
    final daysInMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final list = <DateTime>[];
    for (int i = 0; i < startOffset; i++) {
      list.add(first.subtract(Duration(days: startOffset - i)));
    }
    for (int d = 1; d <= daysInMonth; d++) {
      list.add(DateTime(_visibleMonth.year, _visibleMonth.month, d));
    }
    while (list.length % 7 != 0) {
      list.add(list.last.add(const Duration(days: 1)));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final routeName = ModalRoute.of(context)?.settings.name;
    final content = Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(onPressed: () => _goMonth(-1), icon: const Icon(Icons.chevron_left)),
          IconButton(onPressed: () => _goMonth(1), icon: const Icon(Icons.chevron_right)),
        ],
      ),
      body: FutureBuilder<List<DiaryEntry>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final entries = snapshot.data ?? const [];
          final grouped = _controller.groupByDate(entries);
          final days = _monthDays();
          final selectedEntries = _selectedDay == null
              ? <DiaryEntry>[]
              : grouped[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] ?? const [];
          return Column(
            children: [
              AspectRatio(
                aspectRatio: 7 / 6, // fixed visual height
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(8),
                  itemCount: days.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemBuilder: (context, i) {
                    final day = days[i];
                    final isCurrentMonth = day.month == _visibleMonth.month;
                    final dayKey = DateTime(day.year, day.month, day.day);
                    final hasEntries = grouped.containsKey(dayKey);
                    final isSelected = _selectedDay != null && dayKey == DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
                    final color = isSelected
                        ? Colors.blueAccent
                        : hasEntries
                            ? Colors.blueGrey.shade700
                            : Colors.white10;
                    return GestureDetector(
                      onTap: isCurrentMonth
                          ? () => setState(() => _selectedDay = day)
                          : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.all(4),
                        child: Opacity(
                          opacity: isCurrentMonth ? 1 : .25,
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: selectedEntries.isEmpty
                    ? const Center(child: Text('No entries for selected day'))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemBuilder: (context, index) {
                          final e = selectedEntries[index];
                          return ListTile(
                            title: Text(e.title),
                            subtitle: Text(e.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                            onTap: () => Navigator.pushNamed(context, '/diary-detail', arguments: e),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 4),
                        itemCount: selectedEntries.length,
                      ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: widget.showBottomNav ? HannamiBottomNav(currentRoute: routeName) : null,
    );
    if (widget.enableSwipeNav) {
      return SwipeNav(currentRoute: routeName, child: content);
    }
    return content;
  }
}

