import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;

import '../services/prefs.dart';
import '../widgets.dart';

const _basmala = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});
  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  String q = '';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final all = List.generate(114, (i) => i + 1)
        .where((n) => quran.getSurahNameArabic(n).contains(q.trim()))
        .toList();
    final last = Prefs.lastSurah;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          const PageTitle('القرآن الكريم'),
          TextField(
            onChanged: (v) => setState(() => q = v),
            decoration: InputDecoration(
              hintText: 'ابحث عن سورة',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: cs.surface,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 14),
          if (last > 0 && q.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                color: cs.primary.withOpacity(.12),
                onTap: () => Navigator.push(context, slideRoute(SurahScreen(n: last)))
                    .then((_) => setState(() {})),
                child: Row(children: [
                  Icon(Icons.bookmark_rounded, color: cs.primary),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(
                          'تابع القراءة: سورة ${quran.getSurahNameArabic(last)}',
                          style: const TextStyle(fontWeight: FontWeight.w700))),
                  const Icon(Icons.chevron_left_rounded),
                ]),
              ),
            ),
          for (var i = 0; i < all.length; i++)
            FadeSlide(
              index: i < 8 ? i : 0,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  onTap: () => Navigator.push(
                          context, slideRoute(SurahScreen(n: all[i])))
                      .then((_) => setState(() {})),
                  child: Row(children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: cs.primary.withOpacity(.14),
                      child: Text('${all[i]}',
                          style: TextStyle(
                              fontSize: 13,
                              color: cs.primary,
                              fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(quran.getSurahNameArabic(all[i]),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                    ),
                    Text('${quran.getVerseCount(all[i])} آية',
                        style: TextStyle(
                            fontSize: 12, color: cs.onSurface.withOpacity(.6))),
                  ]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SurahScreen extends StatefulWidget {
  const SurahScreen({super.key, required this.n});
  final int n;
  @override
  State<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen> {
  double fs = Prefs.quranFont;
  late final String body;

  @override
  void initState() {
    super.initState();
    Prefs.setLastSurah(widget.n);
    final b = StringBuffer();
    final count = quran.getVerseCount(widget.n);
    for (var v = 1; v <= count; v++) {
      b.write('${quran.getVerse(widget.n, v, verseEndSymbol: true)} ');
    }
    body = b.toString();
  }

  void _fontSheet() {
    showModalBottomSheet(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, set) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('حجم الخط'),
            Slider(
              min: 18,
              max: 44,
              value: fs,
              onChanged: (v) {
                set(() => fs = v);
                setState(() {});
              },
              onChangeEnd: Prefs.setQuranFont,
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showBasmala = widget.n != 1 && widget.n != 9;
    return Scaffold(
      appBar: AppBar(
        title: Text('سورة ${quran.getSurahNameArabic(widget.n)}'),
        actions: [
          IconButton(
              icon: const Icon(Icons.text_fields_rounded),
              onPressed: _fontSheet),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 40),
        child: Column(children: [
          if (showBasmala)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(_basmala,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiri(
                      fontSize: fs + 2, fontWeight: FontWeight.w700)),
            ),
          Text(body,
              textAlign: TextAlign.justify,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.amiri(fontSize: fs, height: 2.2)),
        ]),
      ),
    );
  }
}
