import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    title: 'Health Universe',
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

  Future<void> _save() async {
    final value = double.tryParse(controller.text.trim().replaceAll(',', '.'));
    if (value == null || !value.isFinite || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a positive number.')));
      return;
    }
    await journal.add(metric, value, metrics[metric]!);
    if (!mounted) return;
    controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Health Universe')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Personal health journal', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('Your entries are stored locally on this device. Not for diagnosis or emergency use.'),
      const SizedBox(height: 24),
      DropdownButtonFormField<String>(
        value: metric,
        decoration: const InputDecoration(labelText: 'Measurement', border: OutlineInputBorder()),
        items: metrics.keys.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
        onChanged: (value) => setState(() => metric = value!),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: 'Value (${metrics[metric]})', border: const OutlineInputBorder()),
      ),
      const SizedBox(height: 12),
      FilledButton.icon(onPressed: _save, icon: const Icon(Icons.add), label: const Text('Save measurement')),
      const SizedBox(height: 24),
      Text('History (${journal.entries.length})', style: Theme.of(context).textTheme.titleLarge),
      if (journal.entries.isEmpty) const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Text('No measurements yet. Add your first entry above.'),
      ),
      ...journal.entries.map((entry) => Card(child: ListTile(
        title: Text('${entry.metric}: ${entry.value} ${entry.unit}'),
        subtitle: Text(entry.recordedAt.toLocal().toString().split('.').first),
        trailing: IconButton(
          tooltip: 'Delete entry',
          icon: const Icon(Icons.delete_outline),
          onPressed: () => journal.remove(entry.id),
        ),
      ))),
    ]),
  );
}
