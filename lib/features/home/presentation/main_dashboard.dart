import 'package:flutter/material.dart';
import 'package:ka_loumo/features/chat/chat_list_screen.dart';
import 'package:ka_loumo/features/home/presentation/explore_screen.dart';
import 'package:ka_loumo/features/home/presentation/home_screen.dart';
import 'package:ka_loumo/features/products/Add_Product_screen.dart';
import 'package:ka_loumo/features/profile/profile_screen.dart';

import '../../../l10n/app_localizations.dart';


class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _index = 0;

  /// PAGES IN CORRECT ORDER
  final List<Widget> pages = const [
    HomeScreen(), // 0
    ExploreScreen(), // 1
    ChatListScreen(), // 2
    ProfileScreen(), // 3
  ];

  /// Convert BottomNav index → pages index
  int _mapBottomIndex(int i) {
    if (i == 0) return 0; // Home
    if (i == 1) return 1; // Explore
    if (i == 2) return 99; // FAB slot
    if (i == 3) return 2; // Chat
    if (i == 4) return 3; // Profile
    return 0;
  }

  int _currentBottomIndex() {
    if (_index == 99) return 0;
    if (_index == 0) return 0;
    if (_index == 1) return 1;
    if (_index == 2) return 3;
    return 4; // _index == 3
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _index == 99 ? const AddProductScreen() : pages[_index],
      ),

      floatingActionButton: FloatingActionButton(
        tooltip: l10n.addProduct,
        backgroundColor: colors.primary,
        shape: const CircleBorder(),
        child: Icon(Icons.add, color: colors.onPrimary, size: 30),
        onPressed: () => setState(() => _index = 99),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withOpacity(.3),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: colors.primary,
          unselectedItemColor: colors.onSurface.withOpacity(.5),
          currentIndex: _currentBottomIndex(),
          onTap: (i) {
            final mapped = _mapBottomIndex(i);
            setState(() => _index = mapped);
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: l10n.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.explore),
              label: l10n.explore,
            ),
            const BottomNavigationBarItem(
              icon: SizedBox.shrink(),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.chat_bubble),
              label: l10n.chat,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: l10n.profile,
            ),
          ],
        ),
      ),
    );
  }
}
