import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

// ── AlertBadge ────────────────────────────────────────────────────────────────
class AlertBadge extends StatelessWidget {
  final String level;
  final double fontSize;

  const AlertBadge({super.key, required this.level, this.fontSize = 11});

  @override
  Widget build(BuildContext context) {
    final color = AlertColors.forLevel(level);
    final bg    = AlertColors.bgForLevel(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        AlertColors.labelForLevel(level),
        style: AppText.label(size: fontSize, color: color),
      ),
    );
  }
}

// ── SigapCard ─────────────────────────────────────────────────────────────────
class SigapCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;

  const SigapCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.bgCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ── StatItem (quick info grid) ────────────────────────────────────────────────
class StatItem extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final String?  sublabel;
  final Color?   iconColor;
  final Color?   valueColor;

  const StatItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.sublabel,
    this.iconColor,
    this.valueColor,
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
              Text(label.toUpperCase(), style: AppText.label()),
              Icon(icon, size: 16, color: iconColor ?? AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppText.mono(size: 22, weight: FontWeight.w700, color: valueColor ?? AppColors.textMain),
          ),
          if (sublabel != null) ...[
            const SizedBox(height: 4),
            Text(sublabel!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ],
      ),
    );
  }
}

// ── Pulse Dot (sensor status) ─────────────────────────────────────────────────
class PulseDot extends StatelessWidget {
  final Color color;
  final double size;

  const PulseDot({super.key, required this.color, this.size = 8});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 2.5,
      height: size * 2.5,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 2.5,
            height: size * 2.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.2),
            ),
          ).animate(onPlay: (c) => c.repeat()).scale(
            begin: const Offset(0.6, 0.6),
            end:   const Offset(1.2, 1.2),
            duration: 1500.ms,
            curve: Curves.easeOut,
          ).fadeOut(duration: 1500.ms),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        ],
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String  title;
  final String? subtitle;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              if (subtitle != null)
                Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ── Loading Shimmer ───────────────────────────────────────────────────────────
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor:      const Color(0xFFE5E9F0),
      highlightColor: const Color(0xFFF5F5F5),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class StatusShimmer extends StatelessWidget {
  const StatusShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ShimmerBox(height: 200, radius: 20),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: List.generate(4, (_) => const ShimmerBox(height: 90)),
        ),
      ],
    );
  }
}

// ── Error View ────────────────────────────────────────────────────────────────
class ErrorView extends StatelessWidget {
  final String  message;
  final VoidCallback onRetry;

  const ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat data',
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 13, color: AppColors.textSub),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Utility: format tanggal WIB ───────────────────────────────────────────────
String formatWIB(String? iso) {
  if (iso == null) return '—';
  try {
    final dt = DateTime.parse(iso).toLocal();
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dt);
  } catch (_) {
    return iso;
  }
}

String timeAgo(String? iso) {
  if (iso == null) return '—';
  try {
    final dt    = DateTime.parse(iso).toLocal();
    final diff  = DateTime.now().difference(dt);
    if (diff.inSeconds < 60)  return '${diff.inSeconds} detik lalu';
    if (diff.inMinutes < 60)  return '${diff.inMinutes} menit lalu';
    if (diff.inHours   < 24)  return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  } catch (_) {
    return iso;
  }
}
