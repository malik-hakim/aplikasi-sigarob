import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/common/common_widgets.dart';

class RiwayatScreen extends ConsumerStatefulWidget {
  const RiwayatScreen({super.key});

  @override
  ConsumerState<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends ConsumerState<RiwayatScreen> {
  String _levelFilter = '';
  int    _page        = 1;

  @override
  Widget build(BuildContext context) {
    final params = RiwayatParams(page: _page, level: _levelFilter);
    final async  = ref.watch(riwayatProvider(params));

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text('Riwayat Banjir Rob'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () => ref.invalidate(riwayatProvider(params)),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:   (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(riwayatProvider(params)),
        ),
        data: (data) {
          final items = (data['items'] as List<dynamic>? ?? [])
              .map((e) => FloodEvent.fromJson(e as Map<String, dynamic>))
              .toList();
          final stats  = RiwayatStats.fromJson(
              (data['stats'] as Map<String, dynamic>?) ?? {});
          final pages  = data['pages'] as int? ?? 1;

          return _RiwayatContent(
            items:       items,
            stats:       stats,
            pages:       pages,
            currentPage: _page,
            levelFilter: _levelFilter,
            onLevelChanged: (v) => setState(() { _levelFilter = v; _page = 1; }),
            onPageChanged:  (v) => setState(() => _page = v),
          );
        },
      ),
    );
  }
}

class _RiwayatContent extends StatelessWidget {
  final List<FloodEvent> items;
  final RiwayatStats     stats;
  final int              pages;
  final int              currentPage;
  final String           levelFilter;
  final void Function(String) onLevelChanged;
  final void Function(int)    onPageChanged;

  static const _levels = ['', 'WASPADA', 'SIAGA', 'EVAKUASI'];
  static const _levelLabels = {
    '':         'Semua',
    'WASPADA':  'Waspada',
    'SIAGA':    'Siaga',
    'EVAKUASI': 'Evakuasi',
  };

  const _RiwayatContent({
    required this.items,
    required this.stats,
    required this.pages,
    required this.currentPage,
    required this.levelFilter,
    required this.onLevelChanged,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Stats Row ─────────────────────────────────────────────────────
        _StatsRow(stats: stats)
          .animate().fadeIn(duration: 400.ms),

        const SizedBox(height: 16),

        // ── Filter chips ──────────────────────────────────────────────────
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _levels.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final lv     = _levels[i];
              final active = lv == levelFilter;
              final color  = lv.isEmpty ? AppColors.primary : AlertColors.forLevel(lv);

              return FilterChip(
                label: Text(_levelLabels[lv] ?? lv),
                selected: active,
                onSelected: (_) => onLevelChanged(lv),
                selectedColor: color.withValues(alpha: 0.15),
                checkmarkColor: color,
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active ? color : AppColors.textSub,
                ),
                side: BorderSide(color: active ? color : AppColors.border),
                backgroundColor: AppColors.bgCard,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                showCheckmark: false,
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // ── Timeline ──────────────────────────────────────────────────────
        if (items.isEmpty)
          const SigapCard(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.history_outlined, size: 40, color: AppColors.textMuted),
                  SizedBox(height: 12),
                  Text('Belum ada riwayat kejadian.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                ],
              ),
            ),
          )
        else
          _Timeline(items: items),

        // ── Pagination ────────────────────────────────────────────────────
        if (pages > 1) ...[
          const SizedBox(height: 16),
          _Pagination(
            current: currentPage,
            total:   pages,
            onChanged: onPageChanged,
          ),
        ],

        const SizedBox(height: 16),
      ],
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final RiwayatStats stats;
  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatBox(
          label: 'Total Kejadian',
          value: stats.totalKejadian.toString(),
          color: AppColors.primary,
          icon:  Icons.history,
        )),
        const SizedBox(width: 10),
        Expanded(child: _StatBox(
          label: 'Level Siaga',
          value: stats.totalSiaga.toString(),
          color: AlertColors.siaga,
          icon:  Icons.warning_amber_outlined,
        )),
        const SizedBox(width: 10),
        Expanded(child: _StatBox(
          label: 'Evakuasi',
          value: stats.totalEvakuasi.toString(),
          color: AlertColors.evakuasi,
          icon:  Icons.crisis_alert,
        )),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String   label;
  final String   value;
  final Color    color;
  final IconData icon;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SigapCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppText.label(size: 10)),
              Icon(icon, size: 14, color: color.withValues(alpha: 0.5)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppText.mono(size: 24, weight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

// ── Timeline ──────────────────────────────────────────────────────────────────
class _Timeline extends StatelessWidget {
  final List<FloodEvent> items;
  const _Timeline({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.asMap().entries.map((e) {
        final i     = e.key;
        final event = e.value;
        final isLast = i == items.length - 1;

        return _TimelineItem(
          event:  event,
          isLast: isLast,
          delay:  Duration(milliseconds: 60 * i),
        );
      }).toList(),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final FloodEvent event;
  final bool       isLast;
  final Duration   delay;

  const _TimelineItem({
    required this.event,
    required this.isLast,
    required this.delay,
  });

  String _formatDurasi(int? menit) {
    if (menit == null) return 'Berlangsung';
    if (menit < 60) return '$menit menit';
    final jam  = menit ~/ 60;
    final sisa = menit % 60;
    return sisa > 0 ? '$jam jam $sisa mnt' : '$jam jam';
  }

  String _formatTanggal(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dt);
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AlertColors.forLevel(event.maxLevel);
    final bg    = AlertColors.bgForLevel(event.maxLevel);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Garis timeline ──────────────────────────────────────────────
          SizedBox(
            width: 32,
            child: Column(
              children: [
                // Dot
                Container(
                  width: 14, height: 14,
                  margin: const EdgeInsets.only(top: 18),
                  decoration: BoxDecoration(
                    shape:       BoxShape.circle,
                    color:       color,
                    boxShadow: [
                      BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 6, spreadRadius: 1),
                    ],
                  ),
                ),
                // Garis vertikal
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.border,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ── Kartu event ─────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: SigapCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        AlertBadge(level: event.maxLevel),
                        const Spacer(),
                        Text(
                          '${event.maxWaterLevelCm.toStringAsFixed(1)} cm',
                          style: AppText.mono(
                            size: 16, weight: FontWeight.w700, color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Waktu mulai
                    _InfoRow(
                      icon:  Icons.play_circle_outline,
                      label: 'Mulai',
                      value: _formatTanggal(event.startedAt),
                    ),

                    // Waktu selesai
                    if (event.endedAt != null) ...[
                      const SizedBox(height: 4),
                      _InfoRow(
                        icon:  Icons.stop_circle_outlined,
                        label: 'Selesai',
                        value: _formatTanggal(event.endedAt!),
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Durasi badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: color.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.timer_outlined, size: 13, color: color),
                          const SizedBox(width: 5),
                          Text(
                            'Durasi: ${_formatDurasi(event.durationMinutes)}',
                            style: TextStyle(
                              fontSize: 12, color: color, fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Catatan
                    if (event.notes != null && event.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        event.notes!,
                        style: const TextStyle(
                          fontSize: 12, color: AppColors.textSub,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ).animate(delay: delay).fadeIn(duration: 350.ms).slideX(begin: 0.05),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text('$label: ', style: AppText.label(size: 11)),
        Expanded(
          child: Text(value,
            style: const TextStyle(fontSize: 12, color: AppColors.textSub)),
        ),
      ],
    );
  }
}

// ── Pagination ────────────────────────────────────────────────────────────────
class _Pagination extends StatelessWidget {
  final int     current;
  final int     total;
  final void Function(int) onChanged;

  const _Pagination({
    required this.current,
    required this.total,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton.icon(
          onPressed: current > 1 ? () => onChanged(current - 1) : null,
          icon:  const Icon(Icons.chevron_left),
          label: const Text('Sebelumnya'),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            'Hal. $current / $total',
            style: AppText.label(size: 12, color: AppColors.textSub),
          ),
        ),
        TextButton.icon(
          onPressed: current < total ? () => onChanged(current + 1) : null,
          icon:  const Text('Berikutnya'),
          label: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
