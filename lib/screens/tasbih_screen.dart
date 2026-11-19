import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/prefs.dart';
import '../widgets.dart';

const _phrases = [
  'سُبْحَانَ اللَّهِ',
  'الْحَمْدُ لِلَّهِ',
  'اللَّهُ أَكْبَرُ',
  'لَا إِلَٰهَ إِلَّا اللَّهُ',
  'أَسْتَغْفِرُ اللَّهَ',
  'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَىٰ نَبِيِّنَا مُحَمَّدٍ',
];

class TasbihPage extends StatefulWidget {
  const TasbihPage({super.key});
  @override
  State<TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends State<TasbihPage> {
  int count = Prefs.tasbihCount;
  int target = Prefs.tasbihTarget;
  int phrase = Prefs.tasbihPhrase;
  int total = Prefs.tasbihTotal;
  bool pressed = false;

  void _tick() {
    setState(() {
      count++;
      total++;
    });
    Prefs.tickTasbih(count);
    if (target > 0 && count % target == 0) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.selectionClick();
    }
  }

  void _reset() {
    setState(() => count = 0);
    Prefs.setTasbihCount(0);
  }

  double get _ring {
    if (target <= 0 || count == 0) return 0;
    return count % target == 0 ? 1 : (count % target) / target;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          children: [
            Align(
                alignment: AlignmentDirectional.centerStart,
                child: const PageTitle('المسبحة')),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _phrases.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (c, i) => ChoiceChip(
                  label: Text(_phrases[i].length > 18
                      ? 'الصلاة على النبي ﷺ'
                      : _phrases[i]),
                  selected: phrase == i,
                  onSelected: (_) {
                    setState(() => phrase = i);
                    Prefs.setTasbihPhrase(i);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(_phrases[phrase],
                  key: ValueKey(phrase),
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700, height: 1.6)),
            ),
            const Spacer(),
            GestureDetector(
              onTapDown: (_) => setState(() => pressed = true),
              onTapCancel: () => setState(() => pressed = false),
              onTapUp: (_) {
                setState(() => pressed = false);
                _tick();
              },
              child: AnimatedScale(
                scale: pressed ? .94 : 1,
                duration: const Duration(milliseconds: 120),
                child: SizedBox(
                  width: 250,
                  height: 250,
                  child: Stack(alignment: Alignment.center, children: [
                    SizedBox(
                      width: 250,
                      height: 250,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: _ring),
                        duration: const Duration(milliseconds: 300),
                        builder: (c, v, _) => CircularProgressIndicator(
                          value: v,
                          strokeWidth: 8,
                          strokeCap: StrokeCap.round,
                          backgroundColor: cs.primary.withOpacity(.15),
                        ),
                      ),
                    ),
                    Container(
                      width: 214,
                      height: 214,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [cs.primary, cs.primary.withOpacity(.7)],
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: cs.primary.withOpacity(.3),
                              blurRadius: 24,
                              offset: const Offset(0, 10))
                        ],
                      ),
                      alignment: Alignment.center,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 150),
                        transitionBuilder: (w, a) =>
                            ScaleTransition(scale: a, child: w),
                        child: Text('$count',
                            key: ValueKey(count),
                            style: TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.w800,
                                color: cs.onPrimary)),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
            const Spacer(),
            Wrap(spacing: 8, children: [
              for (final t in [33, 100, 1000, 0])
                ChoiceChip(
                  label: Text(t == 0 ? 'مفتوح' : '$t'),
                  selected: target == t,
                  onSelected: (_) {
                    setState(() => target = t);
                    Prefs.setTasbihTarget(t);
                  },
                ),
            ]),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('الإجمالي: $total',
                    style: TextStyle(color: cs.onSurface.withOpacity(.6))),
                TextButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('تصفير')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
