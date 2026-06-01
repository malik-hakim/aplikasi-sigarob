import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/common/common_widgets.dart';

class PrakiraanScreen extends ConsumerWidget {
  const PrakiraanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(prakiraanProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text('Prakiraan 3 Hari'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () => ref.invalidate(prakiraanProvider),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:   (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(prakiraanProvider),
        ),
        data: (days) => _PrakiraanContent(days: days),
      ),
    );
  }
}

class _PrakiraanContent extends StatelessWidget {
  final List<PrakiraanDay> days;
  const _PrakiraanContent({required this.days});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Sumber data info ──────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.infoBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: AppColors.primary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sumber: Sensor IoT Eretan + Prakiraan BMKG Indramayu',
                  style: TextStyle(fontSize: 12, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Bar Chart ─────────────────────────────────────────────────────
        SigapCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'Perbandingan Ketinggian Air',
                subtitle: 'Prediksi per hari (cm)',
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 180,
                child: _WaterLevelBarChart(days: days),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms),

        const SizedBox(height: 16),

        // ── Kartu per hari ────────────────────────────────────────────────
        ...days.asMap().entries.map((entry) {
          final i   = entry.key;
          final day = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _DayCard(day: day)
              .animate(delay: Duration(milliseconds: 100 * i))
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1),
          );
        }),

        const SizedBox(height: 8),
        const Center(
          child: Text(
            '* Prediksi dihasilkan dari model rule-based SIGAP.\n'
            'Akurasi meningkat seiring bertambahnya data historis.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ── Bar Chart ─────────────────────────────────────────────────────────────────
class _WaterLevelBarChart extends StatelessWidget {
  final List<PrakiraanDay> days;
  const _WaterLevelBarChart({required this.days});

  @override
  Widget build(BuildContext context) {
    final bars = days.asMap().entries.map((e) {
      final day   = e.value;
      final color = AlertColors.forLevel(day.alertLevel);
      final value = day.predictedLevelCm ?? 0;

      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY:      value,
            color:    color,
            width:    40,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            backDrawRodData: BackgroundBarChartRodData(
              show:  true,
              toY:   100,
              color: AppColors.border,
            ),
          ),
        ],
      );
    }).toList();

    final maxY = (days
            .map((d) => d.predictedLevelCm ?? 0)
            .fold<double>(0, (a, b) => a > b ? a : b) *
        1.3)
      .clamp(20.0, 120.0);

    return BarChart(
      BarChartData(
        maxY:          maxY,
        barGroups:     bars,
        gridData:      FlGridData(
          show:             true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AppColors.border,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i < 0 || i >= days.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    days[i].label,
                    style: AppText.label(size: 11),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, _) => Text(
                '${value.toInt()}',
                style: AppText.label(size: 10),
              ),
            ),
          ),
          topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toStringAsFixed(1)} cm',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              );
            },
          ),
        ),
      ),
      swapAnimationDuration: const Duration(milliseconds: 800),
      swapAnimationCurve: Curves.easeInOut,
    );
  }
}

// ── Kartu detail per hari ─────────────────────────────────────────────────────
class _DayCard extends StatelessWidget {
  final PrakiraanDay day;
  const _DayCard({required this.day});

  @override
  Widget build(BuildContext context) {
    final color = AlertColors.forLevel(day.alertLevel);

    return SigapCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(day.label,
                      style: Theme.of(context).textTheme.titleSmall),
                    Text(day.date,
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
              AlertBadge(level: day.alertLevel, fontSize: 12),
            ],
          ),

          const Divider(height: 24, color: AppColors.border),

          // Stats row
          Row(
            children: [
              _MiniStat(
                icon:  Icons.water_outlined,
                label: 'Ketinggian',
                value: day.predictedLevelCm != null
                         ? '${day.predictedLevelCm!.toStringAsFixed(1)} cm'
                         : '—',
                color: color,
              ),
              const SizedBox(width: 12),
              _MiniStat(
                icon:  Icons.beach_access_outlined,
                label: 'Hujan',
                value: day.rainfallMm != null
                         ? '${day.rainfallMm!.toStringAsFixed(1)} mm'
                         : '—',
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              _MiniStat(
                icon:  Icons.air,
                label: 'Angin',
                value: day.windSpeedKmh != null
                         ? '${day.windSpeedKmh!.toStringAsFixed(0)} km/h'
                         : '—',
                color: const Color(0xFF6366F1),
              ),
            ],
          ),

          // Probabilitas bar
          if (day.floodProbability != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Probabilitas banjir rob', style: AppText.label()),
                Text(
                  '${(day.floodProbability! * 100).toStringAsFixed(0)}%',
                  style: AppText.mono(size: 13, weight: FontWeight.w700, color: color),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value:            day.floodProbability!,
                backgroundColor:  color.withValues(alpha: 0.12),
                valueColor:       AlwaysStoppedAnimation(color),
                minHeight:        6,
              ),
            ),
          ],

          // Deskripsi cuaca
          if (day.weatherDesc != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.bgPage,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud_outlined, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text(day.weatherDesc!,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSub)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final Color    color;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.bgPage,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(height: 6),
            Text(label, style: AppText.label(size: 10)),
            Text(value, style: AppText.mono(size: 13, weight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}
