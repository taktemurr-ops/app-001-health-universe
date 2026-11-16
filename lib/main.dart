import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:health_universe/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

void main() => runApp(const HealthUniverseApp());

class HealthEntry {
  final String id;
  final DateTime recordedAt;
  final String metric;
  final double value;
  final String unit;

  const HealthEntry({required this.id, required this.recordedAt, required this.metric, required this.value, required this.unit});

  Map<String, dynamic> toJson() => {'id': id, 'recordedAt': recordedAt.toIso8601String(), 'metric': metric, 'value': value, 'unit': unit};

  factory HealthEntry.fromJson(Map<String, dynamic> json) => HealthEntry(
    id: json['id'] as String,
    recordedAt: DateTime.parse(json['recordedAt'] as String),
    metric: json['metric'] as String,
    value: (json['value'] as num).toDouble(),
    unit: json['unit'] as String,
  );
}

class HealthJournal extends ChangeNotifier {
  static const storageKey = 'health_entries_v1';
  final List<HealthEntry> _entries = [];
  List<HealthEntry> get entries => List.unmodifiable(_entries);

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(storageKey);
    if (raw == null) return;
    try {
      final parsed = jsonDecode(raw) as List<dynamic>;
      _entries
        ..clear()
        ..addAll(parsed.map((item) => HealthEntry.fromJson(Map<String, dynamic>.from(item as Map))));
      _entries.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
      notifyListeners();
    } catch (_) {
      // Preserve corrupt data on disk for possible recovery.
    }
  }

  Future<void> add(String metric, double value, String unit) async {
    if (!value.isFinite || value <= 0) throw ArgumentError('Value must be positive and finite');
    final now = DateTime.now();
    _entries.insert(0, HealthEntry(
      id: '${now.microsecondsSinceEpoch}-${_entries.length}',
      recordedAt: now, metric: metric, value: value, unit: unit,
    ));
    notifyListeners();
    await _persist();
  }

  Future<void> remove(String id) async {
    _entries.removeWhere((entry) => entry.id == id);
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(storageKey, jsonEncode(_entries.map((entry) => entry.toJson()).toList()));
  }
}

class HealthUniverseApp extends StatelessWidget {
  const HealthUniverseApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF087E83)), useMaterial3: true),
    home: const HealthHome(),
  );
}

class HealthHome extends StatefulWidget {
  const HealthHome({super.key});

  @override
  State<HealthHome> createState() => _HealthHomeState();
}

class _HealthHomeState extends State<HealthHome> {
  final journal = HealthJournal();
  String metric = 'Weight';
  final controller = TextEditingController();

  static const metrics = <String, String>{
    'Weight': 'kg',
    'Heart rate': 'bpm',
    'Systolic pressure': 'mmHg',
    'Diastolic pressure': 'mmHg',
    'Water': 'ml',
    'Sleep': 'hours',
  };

  @override
  void initState() {
    super.initState();
    journal.addListener(_refresh);
    journal.load();
  }

  void _refresh() { if (mounted) setState(() {}); }

  @override
  void dispose() {
    journal.removeListener(_refresh);
    journal.dispose();
    controller.dispose();
    super.dispose();
  }

  String _metricLabel(BuildContext context, String key) {
    final l = AppLocalizations.of(context)!;
    return switch (key) {
      'Weight' => l.weight,
      'Heart rate' => l.heartRate,
      'Systolic pressure' => l.systolic,
      'Diastolic pressure' => l.diastolic,
      'Water' => l.water,
      'Sleep' => l.sleep,
      _ => key,
    };
  }

  Future<void> _save() async {
    final value = double.tryParse(controller.text.trim().replaceAll(',', '.'));
    if (value == null || !value.isFinite || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.invalidValue)));
      return;
    }
    await journal.add(metric, value, metrics[metric]!);
    if (!mounted) return;
    controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(AppLocalizations.of(context)!.appTitle)),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Text(AppLocalizations.of(context)!.journalTitle, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text(AppLocalizations.of(context)!.privacyNotice),
      const SizedBox(height: 24),
      DropdownButtonFormField<String>(
        value: metric,
        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.measurement, border: const OutlineInputBorder()),
        items: metrics.keys.map((name) => DropdownMenuItem(value: name, child: Text(_metricLabel(context, name)))).toList(),
        onChanged: (value) => setState(() => metric = value!),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.value(metrics[metric]!), border: const OutlineInputBorder()),
      ),
      const SizedBox(height: 12),
      FilledButton.icon(onPressed: _save, icon: const Icon(Icons.add), label: Text(AppLocalizations.of(context)!.saveMeasurement)),
      const SizedBox(height: 24),
      Text(AppLocalizations.of(context)!.history(journal.entries.length), style: Theme.of(context).textTheme.titleLarge),
      if (journal.entries.isEmpty) Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(AppLocalizations.of(context)!.emptyHistory),
      ),
      ...journal.entries.map((entry) => Card(child: ListTile(
        title: Text('${_metricLabel(context, entry.metric)}: ${NumberFormat.decimalPattern(Localizations.localeOf(context).toLanguageTag()).format(entry.value)} ${entry.unit}'),
        subtitle: Text(DateFormat.yMd(Localizations.localeOf(context).toLanguageTag()).add_jm().format(entry.recordedAt.toLocal())),
        trailing: IconButton(
          tooltip: AppLocalizations.of(context)!.deleteEntry,
          icon: const Icon(Icons.delete_outline),
          onPressed: () => journal.remove(entry.id),
        ),
      ))),
    ]),
  );
}
