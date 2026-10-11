import 'package:flutter/material.dart';

class MatchesPage extends StatelessWidget {
  const MatchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final matches = [
      ('Sábado • 20:00', 'Arena Vila Nova', 'Fut7', 'Confirmada'),
      ('Quarta • 19:30', 'Centro Esportivo', 'Fut6', 'Lista de espera'),
      ('Domingo • 18:00', 'Campo do Parque', 'Fut7', 'Planejada'),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: matches.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final match = matches[index];

        return Card(
          child: ListTile(
            title: Text(match.$1),
            subtitle: Text('${match.$2} • ${match.$3}'),
            trailing: Chip(
              label: Text(match.$4),
              visualDensity: VisualDensity.compact,
            ),
          ),
        );
      },
    );
  }
}
