import 'package:flutter/material.dart';

import '../services/notifier.dart';
import '../services/prefs.dart';
import '../widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final reminders = Prefs.reminders();
  int goal = Prefs.wirdGoal;

  Future<void> _save(Reminder r) async {
    await Prefs.saveReminder(r);
    if (r.enabled) await Notifier.requestPermission();
    await Notifier.schedule(r);
  }

  Future<void> _pickTime(Reminder r) async {
    final t = await showTimePicker(
        context: context, initialTime: TimeOfDay(hour: r.hour, minute: r.minute));
    if (t == null) return;
    setState(() {
      r.hour = t.hour;
      r.minute = t.minute;
    });
    await _save(r);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          const PageTitle('الإعدادات'),
          Text('التذكيرات',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          for (var i = 0; i < reminders.length; i++)
            FadeSlide(
              index: i,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(reminders[i].title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            TextButton(
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 32),
                                  alignment: AlignmentDirectional.centerStart),
                              onPressed: () => _pickTime(reminders[i]),
                              child: Text(
                                  TimeOfDay(
                                          hour: reminders[i].hour,
                                          minute: reminders[i].minute)
                                      .format(context),
                                  style: TextStyle(color: cs.primary)),
                            ),
                          ]),
                    ),
                    Switch(
                      value: reminders[i].enabled,
                      onChanged: (v) async {
                        setState(() => reminders[i].enabled = v);
                        await _save(reminders[i]);
                      },
                    ),
                  ]),
                ),
              ),
            ),
          const SizedBox(height: 14),
          Text('الورد اليومي',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          AppCard(
            child: Row(children: [
              const Expanded(child: Text('عدد الصفحات يوميًا')),
              IconButton.filledTonal(
                icon: const Icon(Icons.remove_rounded),
                onPressed: goal > 1
                    ? () {
                        setState(() => goal--);
                        Prefs.setWirdGoal(goal);
                      }
                    : null,
              ),
              SizedBox(
                  width: 44,
                  child: Text('$goal',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800))),
              IconButton.filledTonal(
                icon: const Icon(Icons.add_rounded),
                onPressed: () {
                  setState(() => goal++);
                  Prefs.setWirdGoal(goal);
                },
              ),
            ]),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text('بدون إعلانات • يعمل بدون إنترنت',
                style: TextStyle(color: cs.onSurface.withOpacity(.5))),
          ),
        ],
      ),
    );
  }
}
