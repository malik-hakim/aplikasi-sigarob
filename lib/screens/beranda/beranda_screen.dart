import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/common/common_widgets.dart';

class BerandaScreen extends ConsumerStatefulWidget {
  const BerandaScreen({super.key});

  @override
  ConsumerState<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends ConsumerState<BerandaScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Auto-refresh setiap 30 detik
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      ref.invalidate(statusProvider);
      ref.invalidate(prakiraanProvider);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(statusProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            snap: true,
            backgroundColor: AppColors.bgCard,
            surfaceTintColor: Colors.transparent,
            title: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
                      begin: Alignment.topLeft,
                      end:   Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.waves, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('SIGAP',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                                       color: AppColors.textMain)),
                    Text('Desa Eretan, Indramayu',
                      style: AppText.label(size: 10, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
            actions: [
              statusAsync.whenOrNull(
                data: (s) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Row(
                    children: [
                      PulseDot(
                        color: s.sensorStatus == 'ONLINE'
                          ? AppColors.success
                          : s.sensorStatus == 'DELAY'
                            ? AppColors.warning
                            : AppColors.danger,
                      ),
                      const SizedBox(width: 6),
                      Text(s.sensorStatus,
                        style: AppText.label(size: 10,
                          color: s.sensorStatus == 'ONLINE'
                            ? AppColors.success : AppColors.textMuted)),
                    ],
                  ),
                ),
              ) ?? const SizedBox.shrink(),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: () {
                  ref.invalidate(statusProvider);
                  ref.invalidate(prakiraanProvider);
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppColors.border),
            ),
          ),

          // ── Konten ───────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                statusAsync.when(
                  loading: () => const StatusShimmer(),
                  error:   (e, _) => ErrorView(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(statusProvider),
                  ),
                  data: (status) => _BerandaContent(status: status),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Konten utama beranda ──────────────────────────────────────────────────────
class _BerandaContent extends ConsumerWidget {
  final StatusData status;
  const _BerandaContent({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelRank = _levelRank(status.alertLevel);
    final showWarning = levelRank >= 3; // SIAGA atau EVAKUASI

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Hero Status Card ──────────────────────────────────────────────
        _HeroStatusCard(status: status),
        const SizedBox(height: 16),

        // ── Warning Banner ────────────────────────────────────────────────
        if (showWarning) ...[
          _WarningBanner(level: status.alertLevel),
          const SizedBox(height: 16),
        ],

        // ── Quick Info Grid ───────────────────────────────────────────────
        _QuickInfoGrid(status: status),
        const SizedBox(height: 24),

        // ── Preview Prakiraan ─────────────────────────────────────────────
        SectionHeader(
          title: 'Prakiraan 3 Hari',
          subtitle: 'Sumber: Sensor IoT + BMKG',
          trailing: TextButton(
            onPressed: () => GoRouter.of(context).go('/prakiraan'),
            child: const Text('Lihat Semua'),
          ),
        ),
        const SizedBox(height: 12),
        _PrakiraanPreview(),
        const SizedBox(height: 24),

        // ── Terakhir diperbarui ───────────────────────────────────────────
        Center(
          child: Text(
            'Diperbarui ${timeAgo(status.alertUpdatedAt)}',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  int _levelRank(String level) {
    const ranks = {'AMAN': 0, 'INFO': 1, 'WASPADA': 2, 'SIAGA': 3, 'EVAKUASI': 4};
    return ranks[level.toUpperCase()] ?? 1;
  }
}

// ── Hero Status Card ──────────────────────────────────────────────────────────
class _HeroStatusCard extends StatelessWidget {
  final StatusData status;
  const _HeroStatusCard({required this.status});

  @override
  Widget build(BuildContext context) {
    final color   = AlertColors.forLevel(status.alertLevel);
    final bgColor = AlertColors.bgForLevel(status.alertLevel);
    final icon    = AlertColors.iconForLevel(status.alertLevel);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Stack(
        children: [
          // Dekorasi gelombang background
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              child: _WaveDecoration(color: color),
            ),
          ),
          // Konten
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status Banjir Rob',
                          style: AppText.label(size: 11, color: color)),
                        Text(
                          AlertColors.labelForLevel(status.alertLevel),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: color,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Ketinggian air (besar)
                Text(
                  '${status.waterLevelCm.toStringAsFixed(1)} cm',
                  style: AppText.mono(size: 44, weight: FontWeight.w700, color: color),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),

                const SizedBox(height: 4),
                Text('Ketinggian air saat ini',
                  style: TextStyle(fontSize: 13, color: color.withValues(alpha: 0.7))),

                if (status.floodProbability24h != null) ...[
                  const SizedBox(height: 16),
                  // Progress bar probabilitas
                  Row(
                    children: [
                      Text('Prob. banjir 24 jam:',
                        style: AppText.label(size: 11, color: color.withValues(alpha: 0.8))),
                      const SizedBox(width: 8),
                      Text(
                        '${(status.floodProbability24h! * 100).toStringAsFixed(0)}%',
                        style: AppText.mono(size: 13, weight: FontWeight.w700, color: color),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: status.floodProbability24h!,
                      backgroundColor: color.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 6,
                    ),
                  ),
                ],

                const SizedBox(height: 60), // ruang untuk wave
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.05);
  }
}

// Dekorasi gelombang SVG-style
class _WaveDecoration extends StatelessWidget {
  final Color color;
  const _WaveDecoration({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: CustomPaint(
        painter: _WavePainter(color: color.withValues(alpha: 0.12)),
        size: const Size(double.infinity, 60),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final Color color;
  _WavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path  = Path();
    path.moveTo(0, size.height * 0.5);
    path.cubicTo(size.width * 0.25, 0, size.width * 0.5, size.height, size.width * 0.75, size.height * 0.4);
    path.cubicTo(size.width * 0.85, size.height * 0.1, size.width * 0.95, size.height * 0.6, size.width, size.height * 0.3);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Warning Banner ────────────────────────────────────────────────────────────
class _WarningBanner extends StatelessWidget {
  final String level;
  const _WarningBanner({required this.level});

  @override
  Widget build(BuildContext context) {
    final color = AlertColors.forLevel(level);
    return GestureDetector(
      onTap: () => GoRouter.of(context).go('/panduan'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.crisis_alert, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                level == 'EVAKUASI'
                  ? 'Status EVAKUASI! Segera menuju titik kumpul.'
                  : 'Status SIAGA Rob. Lihat panduan keselamatan →',
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ).animate().shake(duration: 600.ms, delay: 300.ms),
    );
  }
}

// ── Quick Info Grid ───────────────────────────────────────────────────────────
class _QuickInfoGrid extends StatelessWidget {
  final StatusData status;
  const _QuickInfoGrid({required this.status});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.65,
      children: [
        StatItem(
          icon:       Icons.water_outlined,
          label:      'Tinggi Air',
          value:      '${status.waterLevelCm.toStringAsFixed(1)} cm',
          sublabel:   AlertColors.labelForLevel(status.alertLevel),
          iconColor:  AlertColors.forLevel(status.alertLevel),
          valueColor: AlertColors.forLevel(status.alertLevel),
        ),
        StatItem(
          icon:      Icons.thermostat_outlined,
          label:     'Suhu',
          value:     status.temperatureC != null
                       ? '${status.temperatureC!.toStringAsFixed(1)}°C'
                       : '—',
          sublabel:  'DHT22',
          iconColor: const Color(0xFFF59E0B),
        ),
        StatItem(
          icon:      Icons.water_drop_outlined,
          label:     'Kelembaban',
          value:     status.humidityPct != null
                       ? '${status.humidityPct!.toStringAsFixed(0)}%'
                       : '—',
          sublabel:  'DHT22',
          iconColor: AppColors.primary,
        ),
        StatItem(
          icon:      Icons.cloud_outlined,
          label:     'Cuaca',
          value:     status.rainfallMm != null
                       ? '${status.rainfallMm!.toStringAsFixed(1)} mm'
                       : '—',
          sublabel:  status.weatherDesc ?? 'BMKG',
          iconColor: const Color(0xFF6366F1),
        ),
      ],
    ).animate()
      .fadeIn(duration: 400.ms, delay: 200.ms)
      .slideY(begin: 0.1);
  }
}

// ── Preview Prakiraan (horizontal scroll) ─────────────────────────────────────
class _PrakiraanPreview extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(prakiraanProvider);

    return async.when(
      loading: () => SizedBox(
        height: 130,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, __) => const SizedBox(
            width: 140,
            child: ShimmerBox(height: 130),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (days) => SizedBox(
        height: 140,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: days.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) => _PrakiraanCard(day: days[i]),
        ),
      ),
    );
  }
}

class _PrakiraanCard extends StatelessWidget {
  final PrakiraanDay day;
  const _PrakiraanCard({required this.day});

  @override
  Widget build(BuildContext context) {
    final color = AlertColors.forLevel(day.alertLevel);

    return SizedBox(
      width: 150,
      child: SigapCard(
        onTap: () => GoRouter.of(context).go('/prakiraan'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(day.label,
              style: AppText.label(size: 11, color: AppColors.textSub)),
            const SizedBox(height: 8),
            AlertBadge(level: day.alertLevel),
            const SizedBox(height: 8),
            Text(
              day.predictedLevelCm != null
                ? '${day.predictedLevelCm!.toStringAsFixed(0)} cm'
                : '— cm',
              style: AppText.mono(size: 20, weight: FontWeight.w700, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              day.rainfallMm != null
                ? '🌧 ${day.rainfallMm!.toStringAsFixed(1)} mm'
                : '☀️ Cerah',
              style: const TextStyle(fontSize: 11, color: AppColors.textSub),
            ),
          ],
        ),
      ),
    );
  }
}
