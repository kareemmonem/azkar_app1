import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Dhikr {
  final String text;
  final int count;
  const Dhikr(this.text, this.count);
  Map<String, dynamic> toJson() => {'t': text, 'c': count};
  factory Dhikr.fromJson(Map<String, dynamic> j) =>
      Dhikr(j['t'] as String, j['c'] as int);
}

class Reminder {
  final int id;
  final String key, title, body;
  bool enabled;
  int hour, minute;
  Reminder({
    required this.id,
    required this.key,
    required this.title,
    required this.body,
    required this.enabled,
    required this.hour,
    required this.minute,
  });
}

class Prefs {
  static late SharedPreferences _p;
  static Future<void> init() async {
    _p = await SharedPreferences.getInstance();
  }

  // ---------- التذكيرات ----------
  static const _defs = <(int, String, String, String, bool, int, int)>[
    (1, 'morning', 'أذكار الصباح', 'حان وقت أذكار الصباح، ابدأ يومك بذكر الله ☀️', true, 6, 0),
    (2, 'evening', 'أذكار المساء', 'حان وقت أذكار المساء 🌙', true, 17, 0),
    (3, 'sleep', 'أذكار النوم', 'لا تنسَ أذكار النوم قبل أن تنام 😴', true, 22, 30),
    (4, 'wird', 'وردك اليومي', 'حان موعد وردك من القرآن 📖', true, 20, 0),
    (5, 'custom', 'أذكاري', 'تذكير بأذكارك الخاصة ✨', false, 12, 0),
  ];

  static List<Reminder> reminders() => _defs.map((d) {
        final s = _p.getString('rem_${d.$2}');
        var en = d.$5, h = d.$6, m = d.$7;
        if (s != null) {
          final x = s.split('|');
          en = x[0] == '1';
          h = int.parse(x[1]);
          m = int.parse(x[2]);
        }
        return Reminder(
            id: d.$1, key: d.$2, title: d.$3, body: d.$4,
            enabled: en, hour: h, minute: m);
      }).toList();

  static Future<void> saveReminder(Reminder r) async {
    await _p.setString(
        'rem_${r.key}', '${r.enabled ? 1 : 0}|${r.hour}|${r.minute}');
  }

  // ---------- أذكار المستخدم ----------
  static List<Dhikr> custom() {
    final s = _p.getString('custom');
    if (s == null) return [];
    return (jsonDecode(s) as List)
        .map((e) => Dhikr.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static Future<void> saveCustom(List<Dhikr> l) async {
    await _p.setString('custom', jsonEncode(l.map((e) => e.toJson()).toList()));
  }

  // ---------- الورد ----------
  static String _fmt(DateTime n) => '${n.year}-${n.month}-${n.day}';
  static String _today() => _fmt(DateTime.now());
  static String _yesterday() =>
      _fmt(DateTime.now().subtract(const Duration(days: 1)));

  static int get wirdGoal => _p.getInt('wird_goal') ?? 2;
  static Future<void> setWirdGoal(int v) async {
    await _p.setInt('wird_goal', v);
  }

  static int get wirdToday => _p.getString('wird_date') == _today()
      ? (_p.getInt('wird_done') ?? 0)
      : 0;

  static int get streak {
    final last = _p.getString('wird_last');
    if (last == null) return 0;
    if (last == _today() || last == _yesterday()) {
      return _p.getInt('wird_streak') ?? 0;
    }
    return 0;
  }

  static Future<void> addWird(int d) async {
    final before = wirdToday;
    final now = (before + d).clamp(0, 999);
    await _p.setString('wird_date', _today());
    await _p.setInt('wird_done', now);
    if (before < wirdGoal &&
        now >= wirdGoal &&
        _p.getString('wird_last') != _today()) {
      final s = _p.getString('wird_last') == _yesterday()
          ? (_p.getInt('wird_streak') ?? 0) + 1
          : 1;
      await _p.setInt('wird_streak', s);
      await _p.setString('wird_last', _today());
    }
  }

  // ---------- المسبحة ----------
  static int get tasbihCount => _p.getInt('tasbih_count') ?? 0;
  static int get tasbihTotal => _p.getInt('tasbih_total') ?? 0;
  static int get tasbihTarget => _p.getInt('tasbih_target') ?? 33;
  static int get tasbihPhrase => _p.getInt('tasbih_phrase') ?? 0;
  static Future<void> tickTasbih(int count) async {
    await _p.setInt('tasbih_count', count);
    await _p.setInt('tasbih_total', tasbihTotal + 1);
  }

  static Future<void> setTasbihCount(int v) async {
    await _p.setInt('tasbih_count', v);
  }

  static Future<void> setTasbihTarget(int v) async {
    await _p.setInt('tasbih_target', v);
  }

  static Future<void> setTasbihPhrase(int v) async {
    await _p.setInt('tasbih_phrase', v);
  }

  // ---------- القرآن ----------
  static int get lastSurah => _p.getInt('last_surah') ?? 0;
  static Future<void> setLastSurah(int v) async {
    await _p.setInt('last_surah', v);
  }

  static double get quranFont => _p.getDouble('quran_font') ?? 26;
  static Future<void> setQuranFont(double v) async {
    await _p.setDouble('quran_font', v);
  }
}
