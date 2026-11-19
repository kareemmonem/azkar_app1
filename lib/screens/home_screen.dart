import 'package:flutter/material.dart';

import '../data/hadith_data.dart';
import '../services/prefs.dart';
import '../widgets.dart';
import 'azkar_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.goToTab});
  final void Function(int) goToTab;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'صباح الخير';
    if (h < 17) return 'نهارك سعيد';
    return 'مساء الخير';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final h = hadithOfDay();
    final done = Prefs.wirdToday;
    final goal = Prefs.wirdGoal;
    final prog = (done / goal).clamp(0.0, 1.0);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          FadeSlide(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_greeting(),
                      style: tt.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  Text('اذكروا الله كثيرًا لعلكم تفلحون',
                      style: TextStyle(color: cs.onSurface.withOpacity(.6))),
                ],
              ),
            ),
          ),
          // حديث اليوم
          FadeSlide(
            index: 1,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [cs.primary, cs.primary.withOpacity(.72)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.auto_stories_rounded, color: cs.onPrimary),
                    const SizedBox(width: 8),
                    Text('حديث اليوم',
                        style: TextStyle(
                            color: cs.onPrimary, fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 14),
                  Text('قال رسول الله ﷺ:',
                      style: TextStyle(
                          color: cs.onPrimary.withOpacity(.85), fontSize: 13)),
                  const SizedBox(height: 6),
                  Text('«${h.text}»',
                      style: tt.titleMedium?.copyWith(
                          color: cs.onPrimary, height: 1.9)),
                  const SizedBox(height: 10),
                  Text(h.source,
                      style: TextStyle(
                          color: cs.onPrimary.withOpacity(.8), fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // الورد
          FadeSlide(
            index: 2,
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text('وردك اليوم',
                          style: tt.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                    ),
                    if (Prefs.streak > 0)
                      Row(children: [
                        Icon(Icons.local_fire_department_rounded,
                            color: cs.secondary, size: 20),
                        const SizedBox(width: 4),
                        Text('${Prefs.streak} يوم',
                            style: TextStyle(color: cs.secondary)),
                      ]),
                  ]),
                  const SizedBox(height: 12),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: prog),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (c, v, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                          value: v,
                          minHeight: 10,
                          backgroundColor: cs.primary.withOpacity(.15)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('$done من $goal صفحة',
                      style: TextStyle(color: cs.onSurface.withOpacity(.7))),
                  const SizedBox(height: 10),
                  Row(children: [
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        await Prefs.addWird(1);
                        setState(() {});
                      },
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('قرأت صفحة'),
                    ),
                    const SizedBox(width: 8),
                    if (done > 0)
                      IconButton(
                        tooltip: 'تراجع',
                        icon: const Icon(Icons.undo_rounded),
                        onPressed: () async {
                          await Prefs.addWird(-1);
                          setState(() {});
                        },
                      ),
                    const Spacer(),
                    TextButton(
                        onPressed: () => widget.goToTab(2),
                        child: const Text('افتح المصحف')),
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeSlide(
            index: 3,
            child: Text('وصول سريع',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 10),
          Row(children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(
                child: FadeSlide(
                  index: 4 + i,
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    onTap: () => openCat(context, kCats[i]),
                    child: Column(children: [
                      Icon(kCats[i].icon, color: cs.primary, size: 28),
                      const SizedBox(height: 8),
                      Text(kCats[i].title.replaceFirst('أذكار ', ''),
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ),
            ],
          ]),
        ],
      ),
    );
  }
}
