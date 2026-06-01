import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../models/models.dart';

// ── Status Provider (auto-refresh 30 detik) ───────────────────────────────────
final statusProvider = FutureProvider.autoDispose<StatusData>((ref) async {
  final json = await PublicApi.getStatus();
  return StatusData.fromJson(json);
});

// ── Prakiraan Provider ────────────────────────────────────────────────────────
final prakiraanProvider = FutureProvider.autoDispose<List<PrakiraanDay>>((ref) async {
  final json = await PublicApi.getPrakiraan();
  final days = (json['days'] as List<dynamic>?) ?? [];
  return days.map((d) => PrakiraanDay.fromJson(d as Map<String, dynamic>)).toList();
});

// ── Riwayat Provider dengan filter ───────────────────────────────────────────
class RiwayatParams {
  final int    page;
  final String level;
  const RiwayatParams({this.page = 1, this.level = ''});

  @override
  bool operator ==(Object other) =>
    other is RiwayatParams && other.page == page && other.level == level;

  @override
  int get hashCode => Object.hash(page, level);
}

final riwayatProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, RiwayatParams>((ref, params) async {
  return PublicApi.getRiwayat(
    page:    params.page,
    perPage: 10,
    level:   params.level.isEmpty ? null : params.level,
  );
});

// ── Panduan Provider ──────────────────────────────────────────────────────────
final panduanProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return PublicApi.getPanduan();
});

// ── Riwayat Sensor Provider (untuk grafik) ────────────────────────────────────
final sensorHistoryProvider = FutureProvider.autoDispose
    .family<List<SensorPoint>, int>((ref, jam) async {
  final json = await PublicApi.getRiwayatSensor(jam: jam);
  final items = (json['items'] as List<dynamic>?) ?? [];
  return items
      .map((i) => SensorPoint.fromJson(i as Map<String, dynamic>))
      .toList();
});

// ── Checklist Provider (local state) ─────────────────────────────────────────
final checklistProvider = StateNotifierProvider<ChecklistNotifier, List<bool>>((ref) {
  return ChecklistNotifier();
});

class ChecklistNotifier extends StateNotifier<List<bool>> {
  ChecklistNotifier() : super(List.filled(checklistItems.length, false));

  void toggle(int index) {
    final next = [...state];
    next[index] = !next[index];
    state = next;
  }

  void reset() => state = List.filled(checklistItems.length, false);

  int get checkedCount => state.where((v) => v).length;
}

// Item tas siaga
const List<String> checklistItems = [
  'KTP & dokumen penting (dalam plastik kedap air)',
  'Uang tunai secukupnya',
  'Obat-obatan pribadi & P3K',
  'Pakaian ganti (3 hari)',
  'Senter & baterai cadangan',
  'Air minum (2 liter per orang)',
  'Makanan siap saji / biskuit',
  'Ponsel & charger / power bank',
  'Peluit darurat',
  'Selimut atau jas hujan',
];
