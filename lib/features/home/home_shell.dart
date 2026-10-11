import 'package:flutter/material.dart';

import '../dashboard/dashboard_page.dart';
import '../matches/matches_page.dart';
import '../players/players_page.dart';
import '../settings/settings_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _Destination {
  const _Destination({
    required this.label,
    required this.icon,
    required this.page,
  });

  final String label;
  final IconData icon;
  final Widget page;
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  static const List<_Destination> _destinations = [
    _Destination(
      label: 'Painel',
      icon: Icons.home_rounded,
      page: DashboardPage(),
    ),
    _Destination(
      label: 'Jogadores',
      icon: Icons.groups_rounded,
      page: PlayersPage(),
    ),
    _Destination(
      label: 'Partidas',
      icon: Icons.sports_soccer_rounded,
      page: MatchesPage(),
    ),
    _Destination(
      label: 'Config.',
      icon: Icons.settings_rounded,
      page: SettingsPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_destinations[_selectedIndex].label),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _destinations.map((destination) => destination.page).toList(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: _destinations
            .map(
              (destination) => NavigationDestination(
                icon: Icon(destination.icon),
                label: destination.label,
              ),
            )
            .toList(),
      ),
    );
  }
}
