import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: unused_import
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show PendingNotificationRequest;

import 'notifications.dart';

/* ───────────── Helper class for per‑type metadata ───────────── */
class _ReminderMeta {
  final String channelId;
  final String channelName;
  final String? sound; // mp3 in res/raw (filename only, no extension)
  final String? icon; // drawable name without extension
  final String? groupKey; // to collapse notifications by type
  const _ReminderMeta({
    required this.channelId,
    required this.channelName,
    this.sound,
    this.icon,
    this.groupKey,
  });
}

/* ───────────── Settings Page ───────────── */
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _remindersEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  final Map<String, bool> _reminderTypes = {
    'Hydrate': false,
    'Stretch': false,
    'Workout': false,
  };

  final Map<String, _ReminderMeta> _meta = const {
    'Hydrate': _ReminderMeta(
      channelId: 'hydrate_ch',
      channelName: 'Hydration',
      sound: 'water_drop',
      icon: 'ic_hydrate',
      groupKey: 'group_hydrate',
    ),
    'Stretch': _ReminderMeta(
      channelId: 'stretch_ch',
      channelName: 'Stretch',
      sound: 'stretch_bell',
      icon: 'ic_stretch',
      groupKey: 'group_stretch',
    ),
    'Workout': _ReminderMeta(
      channelId: 'workout_ch',
      channelName: 'Workout',
      sound: null,
      icon: 'ic_workout',
      groupKey: 'group_workout',
    ),
  };

  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _notificationService.init();
    await _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _remindersEnabled = prefs.getBool('remindersEnabled') ?? false;
      _reminderTime = TimeOfDay(
        hour: prefs.getInt('reminderHour') ?? 20,
        minute: prefs.getInt('reminderMinute') ?? 0,
      );
      for (final k in _reminderTypes.keys) {
        _reminderTypes[k] = prefs.getBool('reminder$k') ?? false;
      }
    });

    _remindersEnabled
        ? await _scheduleAllNotifications()
        : await _notificationService.cancelAllNotifications();
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remindersEnabled', _remindersEnabled);
    await prefs.setInt('reminderHour', _reminderTime.hour);
    await prefs.setInt('reminderMinute', _reminderTime.minute);
    for (final e in _reminderTypes.entries) {
      await prefs.setBool('reminder${e.key}', e.value);
    }
  }

  Future<void> _scheduleAllNotifications() async {
    await _notificationService.cancelAllNotifications();
    if (!_remindersEnabled) return;

    int id = 0;
    for (final entry in _reminderTypes.entries) {
      if (entry.value) {
        final m = _meta[entry.key]!;
        await _notificationService.scheduleDailyNotification(
          id: id++,
          title: '${entry.key} Reminder',
          body: 'Time to ${entry.key.toLowerCase()}!',
          time: _reminderTime,
          channelId: m.channelId,
          channelName: m.channelName,
          sound: m.sound,
          groupKey: m.groupKey,
          smallIcon: m.icon,
        );
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reminders set for ${_reminderTime.format(context)}'),
        ),
      );
      setState(() {});
    }
  }

  Future<void> _toggleMaster(bool v) async {
    setState(() => _remindersEnabled = v);
    await _savePrefs();
    v
        ? await _scheduleAllNotifications()
        : await _notificationService.cancelAllNotifications();
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (t != null) {
      setState(() => _reminderTime = t);
      await _savePrefs();
      if (_remindersEnabled) await _scheduleAllNotifications();
    }
  }

  Future<void> _toggleType(String type, bool? v) async {
    setState(() => _reminderTypes[type] = v ?? false);
    await _savePrefs();
    if (_remindersEnabled) await _scheduleAllNotifications();
  }

  Widget _pendingSection() {
    return FutureBuilder(
      future: _notificationService.pending(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        // ignore: unnecessary_cast
        final list = snapshot.data! as List<PendingNotificationRequest>;
        if (list.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            const Text(
              'Scheduled Reminders',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ...list.map(
              (p) => ListTile(
                title: Text(p.title ?? 'ID ${p.id}'),
                subtitle: Text(p.body ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () async {
                    await _notificationService.cancelNotification(p.id);
                    setState(() {});
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Enable Reminders'),
            value: _remindersEnabled,
            onChanged: _toggleMaster,
          ),
          ListTile(
            title: const Text('Reminder Time'),
            subtitle: Text(_reminderTime.format(context)),
            trailing: const Icon(Icons.access_time),
            enabled: _remindersEnabled,
            onTap: _pickTime,
          ),
          const Divider(),
          const Text(
            'Reminder Types',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ..._reminderTypes.entries.map((entry) {
            final meta = _meta[entry.key]!;
            return CheckboxListTile(
              title: Row(
                children: [
                  Expanded(child: Text(entry.key)),
                  IconButton(
                    tooltip: 'Test',
                    icon: const Icon(Icons.notifications_active),
                    onPressed: _remindersEnabled
                        ? () => _notificationService.showInstantNotification(
                            title: '${entry.key} Preview',
                            body: 'This is how it will look!',
                            channelId: meta.channelId,
                            channelName: meta.channelName,
                            sound: meta.sound,
                            groupKey: meta.groupKey,
                            smallIcon: meta.icon,
                          )
                        : null,
                  ),
                ],
              ),
              value: entry.value,
              onChanged: _remindersEnabled
                  ? (v) => _toggleType(entry.key, v)
                  : null,
            );
          }),
          _pendingSection(),
        ],
      ),
    );
  }
}
