import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/beranda/beranda_screen.dart';
import '../screens/prakiraan/prakiraan_screen.dart';
import '../screens/panduan/panduan_screen.dart';
import '../screens/riwayat/riwayat_screen.dart';
import '../core/theme/app_theme.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => _AppShell(child: child),
      routes: [
        GoRoute(path: '/',          builder: (_, __) => const BerandaScreen()),
        GoRoute(path: '/prakiraan', builder: (_, __) => const PrakiraanScreen()),
        GoRoute(path: '/panduan',   builder: (_, __) => const PanduanScreen()),
        GoRoute(path: '/riwayat',   builder: (_, __) => const RiwayatScreen()),
      ],
    ),
  ],
);

class _AppShell extends StatelessWidget {
  final Widget child;
  const _AppShell({required this.child});

  static const _tabs = ['/', '/prakiraan', '/panduan', '/riwayat'];

  static const _navItems = [
    BottomNavigationBarItem(
      icon:      Icon(Icons.home_outlined),
      activeIcon:Icon(Icons.home),
      label:     'Beranda',
    ),
    BottomNavigationBarItem(
      icon:      Icon(Icons.wb_sunny_outlined),
      activeIcon:Icon(Icons.wb_sunny),
      label:     'Prakiraan',
    ),
    BottomNavigationBarItem(
      icon:      Icon(Icons.shield_outlined),
      activeIcon:Icon(Icons.shield),
      label:     'Panduan',
    ),
    BottomNavigationBarItem(
      icon:      Icon(Icons.history_outlined),
      activeIcon:Icon(Icons.history),
      label:     'Riwayat',
    ),
  ];

  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    final idx = _tabs.indexOf(loc);
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: (i) => context.go(_tabs[i]),
          items: _navItems,
          selectedItemColor:   AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          backgroundColor:     AppColors.bgCard,
          type:                BottomNavigationBarType.fixed,
          elevation:           0,
          selectedFontSize:    11,
          unselectedFontSize:  11,
        ),
      ),
    );
  }
}
