import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/common/common_widgets.dart';

class PanduanScreen extends ConsumerWidget {
  const PanduanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final panduanAsync = ref.watch(panduanProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(title: const Text('Panduan & Evakuasi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Accordion Tips per Level ──────────────────────────────────
          _TipsAccordion(),
          const SizedBox(height: 24),

          // ── Titik Evakuasi & Kontak dari API ─────────────────────────
          panduanAsync.when(
            loading: () => const Column(children: [
              ShimmerBox(height: 180),
              SizedBox(height: 16),
              ShimmerBox(height: 200),
            ]),
            error: (e, _) => ErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(panduanProvider),
            ),
            data: (data) {
              final titik = (data['evacuation_points'] as List<dynamic>? ?? [])
                  .map((e) => EvacuationPoint.fromJson(e as Map<String, dynamic>))
                  .toList();
              final kontak = (data['emergency_contacts'] as List<dynamic>? ?? [])
                  .map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
                  .toList();

              return Column(
                children: [
                  _TitikEvakuasiSection(titik: titik),
                  const SizedBox(height: 24),
                  _KontakDaruratSection(kontak: kontak),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // ── Checklist Tas Siaga ───────────────────────────────────────
          _ChecklistSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Tips Accordion ────────────────────────────────────────────────────────────
class _TipsAccordion extends StatelessWidget {
  final _tips = const {
    'AMAN': [
      'Pantau informasi cuaca BMKG secara berkala',
      'Pastikan saluran air di sekitar rumah tidak tersumbat',
      'Simpan nomor darurat di ponsel Anda',
    ],
    'WASPADA': [
      'Pindahkan barang berharga ke tempat yang lebih tinggi',
      'Siapkan tas siaga berisi dokumen penting',
      'Pantau ketinggian air secara berkala',
      'Hubungi BPBD jika situasi memburuk',
    ],
    'SIAGA': [
      'Bersiaplah untuk evakuasi sewaktu-waktu',
      'Matikan aliran listrik jika air mulai masuk',
      'Pindahkan kendaraan ke lokasi aman',
      'Hubungi keluarga dan tetangga sekitar',
      'Ikuti arahan BPBD Indramayu',
    ],
    'EVAKUASI': [
      'SEGERA evakuasi ke titik kumpul terdekat!',
      'Jangan menunggu air semakin tinggi',
      'Bantu warga lanjut usia dan anak-anak',
      'Bawa tas siaga yang sudah disiapkan',
      'Hubungi BPBD: 0234-275547',
    ],
  };

  @override
  Widget build(BuildContext context) {
    return SigapCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SectionHeader(
              title: 'Tips Keselamatan',
              subtitle: 'Per level status banjir rob',
            ),
          ),
          ..._tips.entries.map((e) => _TipsItem(
            level: e.key,
            tips:  e.value,
          )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _TipsItem extends StatefulWidget {
  final String       level;
  final List<String> tips;
  const _TipsItem({required this.level, required this.tips});

  @override
  State<_TipsItem> createState() => _TipsItemState();
}

class _TipsItemState extends State<_TipsItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final color = AlertColors.forLevel(widget.level);
    final bg    = AlertColors.bgForLevel(widget.level);

    return Column(
      children: [
        const Divider(height: 1, color: AppColors.border),
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Level ${AlertColors.labelForLevel(widget.level)}',
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600, color: color,
                    ),
                  ),
                ),
                AlertBadge(level: widget.level, fontSize: 10),
                const SizedBox(width: 8),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.textMuted, size: 20,
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          Container(
            color: bg.withValues(alpha: 0.5),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.tips.map((tip) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline, size: 16, color: color),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(tip,
                        style: const TextStyle(fontSize: 13, color: AppColors.textMain)),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.05),
      ],
    );
  }
}

// ── Titik Evakuasi ────────────────────────────────────────────────────────────
class _TitikEvakuasiSection extends StatelessWidget {
  final List<EvacuationPoint> titik;
  const _TitikEvakuasiSection({required this.titik});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Titik Evakuasi',
          subtitle: 'Lokasi pengungsian terdekat',
        ),
        const SizedBox(height: 12),
        if (titik.isEmpty)
          const SigapCard(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Belum ada data titik evakuasi.',
                  style: TextStyle(color: AppColors.textMuted)),
              ),
            ),
          )
        else
          ...titik.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _EvakuasiCard(point: e.value)
              .animate(delay: Duration(milliseconds: 80 * e.key))
              .fadeIn().slideX(begin: -0.05),
          )),
      ],
    );
  }
}

class _EvakuasiCard extends StatelessWidget {
  final EvacuationPoint point;
  const _EvakuasiCard({required this.point});

  Future<void> _openMaps() async {
    final url = Uri.parse(
      'https://maps.google.com/?q=${point.latitude},${point.longitude}',
    );
    if (await canLaunchUrl(url)) launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return SigapCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ikon
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(point.name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                                         color: AppColors.textMain)),
                const SizedBox(height: 2),
                Text(point.address,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSub)),
                if (point.description != null) ...[
                  const SizedBox(height: 4),
                  Text(point.description!,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted,
                                           fontStyle: FontStyle.italic)),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    _Chip(
                      icon: Icons.people_outline,
                      label: '${point.capacity} jiwa',
                    ),
                    const SizedBox(width: 8),
                    _Chip(
                      icon: Icons.map_outlined,
                      label: 'Buka Maps',
                      onTap: _openMaps,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Kontak Darurat ────────────────────────────────────────────────────────────
class _KontakDaruratSection extends StatelessWidget {
  final List<EmergencyContact> kontak;
  const _KontakDaruratSection({required this.kontak});

  static const _catColor = {
    'BPBD':           Color(0xFFEF4444),
    'BASARNAS':       Color(0xFFF97316),
    'POLSEK_KORAMIL': Color(0xFF2196F3),
    'PMI':            Color(0xFFEF4444),
    'PUSKESMAS':      Color(0xFF10B981),
    'LAINNYA':        Color(0xFF6B7280),
  };

  static const _catLabel = {
    'BPBD':           'BPBD',
    'BASARNAS':       'Basarnas',
    'POLSEK_KORAMIL': 'Polsek/Koramil',
    'PMI':            'PMI',
    'PUSKESMAS':      'Puskesmas',
    'LAINNYA':        'Lainnya',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Kontak Darurat',
          subtitle: 'Tekan tombol telepon untuk menghubungi',
        ),
        const SizedBox(height: 12),
        if (kontak.isEmpty)
          const SigapCard(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Belum ada data kontak darurat.',
                  style: TextStyle(color: AppColors.textMuted)),
              ),
            ),
          )
        else
          SigapCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: kontak.asMap().entries.map((e) {
                final k     = e.value;
                final color = _catColor[k.category] ?? const Color(0xFF6B7280);
                final label = _catLabel[k.category] ?? k.category;
                final isLast = e.key == kontak.length - 1;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          // Avatar inisial
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                k.name.split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join(),
                                style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700, color: color,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(k.name,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                                                          color: AppColors.textMain)),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    _CategoryBadge(label: label, color: color),
                                    if (k.description != null) ...[
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text('• ${k.description}',
                                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                          overflow: TextOverflow.ellipsis),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Tombol telepon
                          GestureDetector(
                            onTap: () async {
                              final uri = Uri.parse('tel:${k.phoneNumber}');
                              if (await canLaunchUrl(uri)) launchUrl(uri);
                            },
                            child: Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.phone, color: AppColors.success, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      const Divider(height: 1, color: AppColors.border, indent: 68),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

// ── Checklist Tas Siaga ───────────────────────────────────────────────────────
class _ChecklistSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checked  = ref.watch(checklistProvider);
    final notifier = ref.read(checklistProvider.notifier);
    final count    = notifier.checkedCount;
    final total    = checklistItems.length;
    final progress = count / total;

    return SigapCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: SectionHeader(
                  title: '✅ Checklist Tas Siaga',
                  subtitle: 'Siapkan sebelum bencana terjadi',
                ),
              ),
              TextButton(
                onPressed: notifier.reset,
                child: const Text('Reset', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value:           progress,
                    backgroundColor: AppColors.border,
                    valueColor:      const AlwaysStoppedAnimation(AppColors.success),
                    minHeight:       8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$count/$total',
                style: AppText.mono(size: 13, weight: FontWeight.w700,
                  color: count == total ? AppColors.success : AppColors.textSub),
              ),
            ],
          ),

          if (count == total) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.successBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 16),
                  SizedBox(width: 8),
                  Text('Tas siaga sudah lengkap! 🎉',
                    style: TextStyle(fontSize: 13, color: AppColors.success,
                                     fontWeight: FontWeight.w600)),
                ],
              ),
            ).animate().scale(duration: 300.ms, curve: Curves.elasticOut),
          ],

          const SizedBox(height: 12),
          const Divider(color: AppColors.border),
          const SizedBox(height: 4),

          ...checklistItems.asMap().entries.map((e) => CheckboxListTile(
            value:     checked[e.key],
            onChanged: (_) => notifier.toggle(e.key),
            title:     Text(e.value,
              style: TextStyle(
                fontSize:        13,
                color:           checked[e.key] ? AppColors.textMuted : AppColors.textMain,
                decoration:      checked[e.key] ? TextDecoration.lineThrough : null,
              ),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            dense:  true,
            activeColor: AppColors.success,
            contentPadding: EdgeInsets.zero,
          )),
        ],
      ),
    );
  }
}

// ── Komponen kecil ────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final IconData icon;
  final String   label;
  final VoidCallback? onTap;
  final Color?   color;

  const _Chip({required this.icon, required this.label, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSub;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: c.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: c),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String label;
  final Color  color;
  const _CategoryBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}
