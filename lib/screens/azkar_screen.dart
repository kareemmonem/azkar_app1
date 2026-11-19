import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/azkar_data.dart';
import '../services/prefs.dart';
import '../widgets.dart';

class AzkarCat {
  final String title, key;
  final IconData icon;
  const AzkarCat(this.title, this.icon, this.key);
}

const kCats = [
  AzkarCat('أذكار الصباح', Icons.wb_sunny_rounded, 'morning'),
  AzkarCat('أذكار المساء', Icons.nights_stay_rounded, 'evening'),
  AzkarCat('أذكار النوم', Icons.bedtime_rounded, 'sleep'),
  AzkarCat('بعد الصلاة', Icons.mosque_rounded, 'prayer'),
  AzkarCat('أذكاري', Icons.favorite_rounded, 'custom'),
];

void openCat(BuildContext c, AzkarCat cat) {
  Navigator.push(
    c,
    slideRoute(DhikrListScreen(
      title: cat.title,
      items: azkarFor(cat.key),
      custom: cat.key == 'custom',
    )),
  );
}

class AzkarPage extends StatelessWidget {
  const AzkarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          const PageTitle('الأذكار'),
          for (var i = 0; i < kCats.length; i++)
            FadeSlide(
              index: i,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  onTap: () => openCat(context, kCats[i]),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: cs.primary.withOpacity(.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(kCats[i].icon, color: cs.primary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(kCats[i].title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                      ),
                      Icon(Icons.chevron_left_rounded,
                          color: cs.onSurface.withOpacity(.4)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DhikrListScreen extends StatefulWidget {
  const DhikrListScreen(
      {super.key,
      required this.title,
      required this.items,
      this.custom = false});
  final String title;
  final List<Dhikr> items;
  final bool custom;

  @override
  State<DhikrListScreen> createState() => _DhikrListScreenState();
}

class _DhikrListScreenState extends State<DhikrListScreen> {
  late List<Dhikr> items = List.of(widget.items);
  late List<int> left = items.map((e) => e.count).toList();

  void _tap(int i) {
    if (left[i] <= 0) return;
    setState(() => left[i]--);
    if (left[i] == 0) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _add() async {
    final text = TextEditingController();
    final count = TextEditingController(text: '1');
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('إضافة ذكر'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: text,
              maxLines: 4,
              minLines: 2,
              autofocus: true,
              decoration: const InputDecoration(
                  labelText: 'نص الذكر', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: count,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                  labelText: 'عدد التكرار', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('إلغاء')),
          FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('إضافة')),
        ],
      ),
    );
    if (ok != true || text.text.trim().isEmpty) return;
    final n = (int.tryParse(count.text) ?? 1).clamp(1, 10000);
    setState(() {
      items.add(Dhikr(text.text.trim(), n));
      left.add(n);
    });
    await Prefs.saveCustom(items);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      floatingActionButton: widget.custom
          ? FloatingActionButton.extended(
              onPressed: _add,
              icon: const Icon(Icons.add_rounded),
              label: const Text('إضافة ذكر'),
            )
          : null,
      body: items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'لم تضف أي ذكر بعد.\nاضغط "إضافة ذكر" لتبدأ.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cs.onSurface.withOpacity(.6)),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              itemCount: items.length,
              itemBuilder: (c, i) {
                final done = left[i] == 0;
                final card = FadeSlide(
                  index: i,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: done ? .5 : 1,
                      child: AppCard(
                        onTap: () => _tap(i),
                        color: done ? cs.primary.withOpacity(.1) : null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(items[i].text,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(height: 1.9)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: done
                                      ? Icon(Icons.check_circle_rounded,
                                          key: const ValueKey('d'),
                                          color: cs.primary)
                                      : Container(
                                          key: ValueKey(left[i]),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: cs.primary.withOpacity(.14),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                              '${left[i]} / ${items[i].count}',
                                              style: TextStyle(
                                                  color: cs.primary,
                                                  fontWeight:
                                                      FontWeight.w700)),
                                        ),
                                ),
                                const Spacer(),
                                if (done || left[i] != items[i].count)
                                  IconButton(
                                    tooltip: 'إعادة',
                                    icon: const Icon(Icons.refresh_rounded),
                                    onPressed: () => setState(
                                        () => left[i] = items[i].count),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
                if (!widget.custom) return card;
                return Dismissible(
                  key: ObjectKey(items[i]),
                  direction: DismissDirection.horizontal,
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                        color: cs.error.withOpacity(.2),
                        borderRadius: BorderRadius.circular(22)),
                    child: const Icon(Icons.delete_rounded),
                  ),
                  onDismissed: (_) async {
                    setState(() {
                      items.removeAt(i);
                      left.removeAt(i);
                    });
                    await Prefs.saveCustom(items);
                  },
                  child: card,
                );
              },
            ),
    );
  }
}
