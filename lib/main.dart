import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const OintmentCareApp());
}

class OintmentCareApp extends StatelessWidget {
  const OintmentCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF2563EB);

    return MaterialApp(
      title: 'Ointment Care',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Color(0xFFDCE3EA)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: const Color(0xFFFAFBFC),
        ),
      ),
      home: const OintmentHomePage(),
    );
  }
}

class UsageRecord {
  UsageRecord({
    required this.id,
    required this.date,
    required this.amountGrams,
    required this.createdAt,
    this.note = '',
  });

  final String id;
  final String date;
  final double amountGrams;
  final DateTime createdAt;
  final String note;

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'amountGrams': amountGrams,
    'createdAt': createdAt.toIso8601String(),
    'note': note,
  };

  factory UsageRecord.fromJson(Map<String, dynamic> json) => UsageRecord(
    id: json['id'] as String,
    date: json['date'] as String,
    amountGrams: (json['amountGrams'] as num).toDouble(),
    createdAt: DateTime.parse(json['createdAt'] as String),
    note: (json['note'] as String?) ?? '',
  );
}

class SkinEntry {
  SkinEntry({
    required this.id,
    required this.date,
    required this.condition,
    required this.itchScore,
    required this.rednessScore,
    required this.createdAt,
    this.memo = '',
  });

  final String id;
  final String date;
  final String condition;
  final int itchScore;
  final int rednessScore;
  final DateTime createdAt;
  final String memo;

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'condition': condition,
    'itchScore': itchScore,
    'rednessScore': rednessScore,
    'createdAt': createdAt.toIso8601String(),
    'memo': memo,
  };

  factory SkinEntry.fromJson(Map<String, dynamic> json) => SkinEntry(
    id: json['id'] as String,
    date: json['date'] as String,
    condition: json['condition'] as String,
    itchScore: json['itchScore'] as int,
    rednessScore: json['rednessScore'] as int,
    createdAt: DateTime.parse(json['createdAt'] as String),
    memo: (json['memo'] as String?) ?? '',
  );
}

class AppStore {
  AppStore({
    required this.usageRecords,
    required this.skinEntries,
    required this.dailyGoalGrams,
    required this.remindersEnabled,
    required this.morningReminder,
    required this.eveningReminder,
  });

  final List<UsageRecord> usageRecords;
  final List<SkinEntry> skinEntries;
  final double dailyGoalGrams;
  final bool remindersEnabled;
  final String morningReminder;
  final String eveningReminder;

  AppStore copyWith({
    List<UsageRecord>? usageRecords,
    List<SkinEntry>? skinEntries,
    double? dailyGoalGrams,
    bool? remindersEnabled,
    String? morningReminder,
    String? eveningReminder,
  }) {
    return AppStore(
      usageRecords: usageRecords ?? this.usageRecords,
      skinEntries: skinEntries ?? this.skinEntries,
      dailyGoalGrams: dailyGoalGrams ?? this.dailyGoalGrams,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      morningReminder: morningReminder ?? this.morningReminder,
      eveningReminder: eveningReminder ?? this.eveningReminder,
    );
  }

  Map<String, dynamic> toJson() => {
    'usageRecords': usageRecords.map((item) => item.toJson()).toList(),
    'skinEntries': skinEntries.map((item) => item.toJson()).toList(),
    'dailyGoalGrams': dailyGoalGrams,
    'remindersEnabled': remindersEnabled,
    'morningReminder': morningReminder,
    'eveningReminder': eveningReminder,
  };

  factory AppStore.fromJson(Map<String, dynamic> json) => AppStore(
    usageRecords: ((json['usageRecords'] as List?) ?? [])
        .map((item) => UsageRecord.fromJson(item as Map<String, dynamic>))
        .toList(),
    skinEntries: ((json['skinEntries'] as List?) ?? [])
        .map((item) => SkinEntry.fromJson(item as Map<String, dynamic>))
        .toList(),
    dailyGoalGrams: ((json['dailyGoalGrams'] as num?) ?? 2).toDouble(),
    remindersEnabled: (json['remindersEnabled'] as bool?) ?? false,
    morningReminder: (json['morningReminder'] as String?) ?? '08:00',
    eveningReminder: (json['eveningReminder'] as String?) ?? '21:00',
  );

  static AppStore initial() => AppStore(
    usageRecords: [],
    skinEntries: [],
    dailyGoalGrams: 2,
    remindersEnabled: false,
    morningReminder: '08:00',
    eveningReminder: '21:00',
  );
}

class OintmentHomePage extends StatefulWidget {
  const OintmentHomePage({super.key});

  @override
  State<OintmentHomePage> createState() => _OintmentHomePageState();
}

class _OintmentHomePageState extends State<OintmentHomePage> {
  static const storageKey = 'ointment_care_flutter_mvp_v1';
  var selectedIndex = 0;
  var store = AppStore.initial();
  var isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    setState(() {
      store = raw == null
          ? AppStore.initial()
          : AppStore.fromJson(jsonDecode(raw));
      isLoading = false;
    });
  }

  Future<void> _save(AppStore nextStore) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, jsonEncode(nextStore.toJson()));
    setState(() => store = nextStore);
  }

  Metrics get metrics => Metrics.fromStore(store);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeTab(store: store, metrics: metrics, onSave: _saveUsage),
      HistoryTab(records: store.usageRecords),
      SkinTab(entries: store.skinEntries, onSave: _saveSkinEntry),
      BadgeTab(store: store, metrics: metrics),
      SettingsTab(
        store: store,
        onSave: _save,
        onReset: () => _save(AppStore.initial()),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ointment Care',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            Text('軟膏使用管理 MVP', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              avatar: Icon(
                Icons.bluetooth_disabled,
                size: 16,
                color: Colors.grey.shade700,
              ),
              label: const Text('未接続'),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [pages[selectedIndex]],
              ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => setState(() => selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'ホーム',
          ),
          NavigationDestination(icon: Icon(Icons.show_chart), label: '履歴'),
          NavigationDestination(icon: Icon(Icons.edit_note), label: '肌記録'),
          NavigationDestination(
            icon: Icon(Icons.workspace_premium_outlined),
            label: '達成',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: '設定',
          ),
        ],
      ),
    );
  }

  Future<void> _saveUsage(double amountGrams, String note) async {
    final record = UsageRecord(
      id: _id('usage'),
      date: todayKey(),
      amountGrams: amountGrams,
      note: note.trim(),
      createdAt: DateTime.now(),
    );
    await _save(store.copyWith(usageRecords: [record, ...store.usageRecords]));
  }

  Future<void> _saveSkinEntry(
    String condition,
    int itchScore,
    int rednessScore,
    String memo,
  ) async {
    final today = todayKey();
    final entry = SkinEntry(
      id: _id('skin'),
      date: today,
      condition: condition,
      itchScore: itchScore,
      rednessScore: rednessScore,
      memo: memo.trim(),
      createdAt: DateTime.now(),
    );
    await _save(
      store.copyWith(
        skinEntries: [
          entry,
          ...store.skinEntries.where((item) => item.date != today),
        ],
      ),
    );
  }
}

class Metrics {
  Metrics({
    required this.todayTotal,
    required this.weekTotal,
    required this.adherence,
    required this.earnedBadges,
    required this.lastSevenDays,
  });

  final double todayTotal;
  final double weekTotal;
  final int adherence;
  final int earnedBadges;
  final List<String> lastSevenDays;

  factory Metrics.fromStore(AppStore store) {
    final today = todayKey();
    final days = lastNDays(7);
    final todayTotal = store.usageRecords
        .where((record) => record.date == today)
        .fold<double>(0, (sum, record) => sum + record.amountGrams);
    final weekTotal = store.usageRecords
        .where((record) => days.contains(record.date))
        .fold<double>(0, (sum, record) => sum + record.amountGrams);
    final recordedDays = store.usageRecords
        .map((record) => record.date)
        .toSet();
    final adherence = ((days.where(recordedDays.contains).length / 7) * 100)
        .round();
    final earnedBadges = [
      store.usageRecords.isNotEmpty,
      recordedDays.length >= 3,
      recordedDays.length >= 7,
      weekTotal >= store.dailyGoalGrams * 7,
    ].where((item) => item).length;

    return Metrics(
      todayTotal: todayTotal,
      weekTotal: weekTotal,
      adherence: adherence,
      earnedBadges: earnedBadges,
      lastSevenDays: days,
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({
    required this.store,
    required this.metrics,
    required this.onSave,
    super.key,
  });

  final AppStore store;
  final Metrics metrics;
  final Future<void> Function(double amountGrams, String note) onSave;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.store.dailyGoalGrams == 0
        ? 0.0
        : (widget.metrics.todayTotal / widget.store.dailyGoalGrams).clamp(
            0.0,
            1.0,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            StatTile(
              icon: Icons.scale,
              label: '今日',
              value: '${widget.metrics.todayTotal.toStringAsFixed(1)}g',
            ),
            StatTile(
              icon: Icons.calendar_month,
              label: '7日記録率',
              value: '${widget.metrics.adherence}%',
            ),
            StatTile(
              icon: Icons.bar_chart,
              label: '今週',
              value: '${widget.metrics.weekTotal.toStringAsFixed(1)}g',
            ),
            StatTile(
              icon: Icons.workspace_premium,
              label: 'バッジ',
              value: '${widget.metrics.earnedBadges}/4',
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(child: SectionTitle('本日の目標')),
                  Text(
                    '${(progress * 100).round()}%',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 8),
              Text(
                '目標 ${widget.store.dailyGoalGrams.toStringAsFixed(1)}g に対して ${widget.metrics.todayTotal.toStringAsFixed(1)}g 記録済み',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionTitle('今日の軟膏使用量'),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: '使用量 g',
                  prefixIcon: Icon(Icons.medication_liquid),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: '部位や気づき'),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('記録する'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        WeekChart(
          days: widget.metrics.lastSevenDays,
          records: widget.store.usageRecords,
          goal: widget.store.dailyGoalGrams,
        ),
      ],
    );
  }

  Future<void> _save() async {
    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      _showMessage(context, '使用量は 0 より大きい数値で入力してください。');
      return;
    }
    await widget.onSave(amount, noteController.text);
    amountController.clear();
    noteController.clear();
    if (mounted) _showMessage(context, '今日の使用量を保存しました。');
  }
}

class HistoryTab extends StatelessWidget {
  const HistoryTab({required this.records, super.key});

  final List<UsageRecord> records;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('使用履歴'),
          if (records.isEmpty)
            const EmptyState(
              icon: Icons.assignment_outlined,
              text: 'まだ使用量の記録がありません。',
            )
          else
            ...records.map(
              (record) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(formatDateJa(record.date)),
                subtitle: Text(record.note.isEmpty ? 'メモなし' : record.note),
                trailing: Text('${record.amountGrams.toStringAsFixed(1)}g'),
              ),
            ),
        ],
      ),
    );
  }
}

class SkinTab extends StatefulWidget {
  const SkinTab({required this.entries, required this.onSave, super.key});

  final List<SkinEntry> entries;
  final Future<void> Function(
    String condition,
    int itchScore,
    int rednessScore,
    String memo,
  )
  onSave;

  @override
  State<SkinTab> createState() => _SkinTabState();
}

class _SkinTabState extends State<SkinTab> {
  var condition = 'stable';
  double itchScore = 3;
  double rednessScore = 3;
  final memoController = TextEditingController();

  @override
  void dispose() {
    memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionTitle('今日の肌状態'),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'better', label: Text('改善')),
                  ButtonSegment(value: 'stable', label: Text('変化なし')),
                  ButtonSegment(value: 'worse', label: Text('悪化')),
                ],
                selected: {condition},
                onSelectionChanged: (value) =>
                    setState(() => condition = value.first),
              ),
              ScoreSlider(
                label: 'かゆみ',
                value: itchScore,
                onChanged: (value) => setState(() => itchScore = value),
              ),
              ScoreSlider(
                label: '赤み',
                value: rednessScore,
                onChanged: (value) => setState(() => rednessScore = value),
              ),
              TextField(
                controller: memoController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: '症状、塗布部位、生活上の変化'),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('肌状態を保存'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle('最近の肌記録'),
              if (widget.entries.isEmpty)
                const EmptyState(icon: Icons.edit_note, text: 'まだ肌状態の記録がありません。')
              else
                ...widget.entries.map(
                  (entry) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${formatDateJa(entry.date)} / ${conditionLabel(entry.condition)}',
                    ),
                    subtitle: Text(
                      'かゆみ ${entry.itchScore}/10、赤み ${entry.rednessScore}/10\n${entry.memo}',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    await widget.onSave(
      condition,
      itchScore.round(),
      rednessScore.round(),
      memoController.text,
    );
    memoController.clear();
    if (mounted) _showMessage(context, '今日の肌状態を保存しました。');
  }
}

class BadgeTab extends StatelessWidget {
  const BadgeTab({required this.store, required this.metrics, super.key});

  final AppStore store;
  final Metrics metrics;

  @override
  Widget build(BuildContext context) {
    final recordedDays = store.usageRecords
        .map((record) => record.date)
        .toSet()
        .length;
    final badges = [
      BadgeItem('初回記録', store.usageRecords.isNotEmpty, '最初の使用量を記録'),
      BadgeItem('3日記録', recordedDays >= 3, '3日分の使用実績'),
      BadgeItem('7日記録', recordedDays >= 7, '7日分の使用実績'),
      BadgeItem(
        '週間目標達成',
        metrics.weekTotal >= store.dailyGoalGrams * 7,
        '今週の合計が目標量に到達',
      ),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('達成バッジ'),
          ...badges.map(
            (badge) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: badge.done
                    ? const Color(0xFFE7F6EF)
                    : const Color(0xFFF1F4F7),
                child: Icon(badge.done ? Icons.check : Icons.lock_outline),
              ),
              title: Text(badge.title),
              subtitle: Text(badge.detail),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsTab extends StatefulWidget {
  const SettingsTab({
    required this.store,
    required this.onSave,
    required this.onReset,
    super.key,
  });

  final AppStore store;
  final Future<void> Function(AppStore store) onSave;
  final Future<void> Function() onReset;

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  late final goalController = TextEditingController(
    text: widget.store.dailyGoalGrams.toStringAsFixed(1),
  );
  late final morningController = TextEditingController(
    text: widget.store.morningReminder,
  );
  late final eveningController = TextEditingController(
    text: widget.store.eveningReminder,
  );
  late var remindersEnabled = widget.store.remindersEnabled;

  @override
  void dispose() {
    goalController.dispose();
    morningController.dispose();
    eveningController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionTitle('治療設定'),
              TextField(
                controller: goalController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: '1日の目標使用量 g'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('通知予定を有効にする'),
                value: remindersEnabled,
                onChanged: (value) => setState(() => remindersEnabled = value),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: morningController,
                      decoration: const InputDecoration(labelText: '朝'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: eveningController,
                      decoration: const InputDecoration(labelText: '夜'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('設定を保存'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionTitle('開発メモ'),
              const Text(
                '現時点ではデータは端末内に保存されます。Bluetooth LE、医師共有、クラウド同期は次フェーズで追加します。',
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: widget.onReset,
                icon: const Icon(Icons.delete_outline),
                label: const Text('ローカルデータをリセット'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final goal = double.tryParse(goalController.text);
    if (goal == null || goal <= 0) {
      _showMessage(context, '1日の目標量を数値で入力してください。');
      return;
    }
    await widget.onSave(
      widget.store.copyWith(
        dailyGoalGrams: goal,
        remindersEnabled: remindersEnabled,
        morningReminder: morningController.text,
        eveningReminder: eveningController.text,
      ),
    );
    if (mounted) _showMessage(context, '設定を保存しました。');
  }
}

class StatTile extends StatelessWidget {
  const StatTile({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.sizeOf(context).width - 44) / 2,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 10),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class WeekChart extends StatelessWidget {
  const WeekChart({
    required this.days,
    required this.records,
    required this.goal,
    super.key,
  });

  final List<String> days;
  final List<UsageRecord> records;
  final double goal;

  @override
  Widget build(BuildContext context) {
    final totals = days
        .map(
          (day) => records
              .where((record) => record.date == day)
              .fold<double>(0, (sum, record) => sum + record.amountGrams),
        )
        .toList();
    final maxValue = [...totals, goal, 1.0].reduce((a, b) => a > b ? a : b);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('直近7日'),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < days.length; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: 104,
                            alignment: Alignment.bottomCenter,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F4F7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: FractionallySizedBox(
                              heightFactor: (totals[i] / maxValue).clamp(
                                0.08,
                                1,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF16845B),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            shortDateJa(days[i]),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ScoreSlider extends StatelessWidget {
  const ScoreSlider({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label ${value.round()}/10'),
        Slider(
          value: value,
          min: 0,
          max: 10,
          divisions: 10,
          label: value.round().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({required this.icon, required this.text, super.key});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Center(
        child: Column(
          children: [
            Icon(icon, color: Colors.grey.shade600, size: 32),
            const SizedBox(height: 8),
            Text(text),
          ],
        ),
      ),
    );
  }
}

class BadgeItem {
  BadgeItem(this.title, this.done, this.detail);

  final String title;
  final bool done;
  final String detail;
}

String _id(String prefix) =>
    '${prefix}_${DateTime.now().millisecondsSinceEpoch}';
String todayKey() => DateFormat('yyyy-MM-dd').format(DateTime.now());

List<String> lastNDays(int count) {
  final now = DateTime.now();
  return List.generate(
    count,
    (index) => DateFormat(
      'yyyy-MM-dd',
    ).format(now.subtract(Duration(days: count - 1 - index))),
  );
}

String formatDateJa(String dateKey) =>
    DateFormat('M/d(E)', 'ja_JP').format(DateTime.parse(dateKey));
String shortDateJa(String dateKey) =>
    DateFormat('M/d').format(DateTime.parse(dateKey));

String conditionLabel(String value) {
  if (value == 'better') return '改善';
  if (value == 'worse') return '悪化';
  return '変化なし';
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
