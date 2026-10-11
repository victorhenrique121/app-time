import 'package:flutter/material.dart';

class PlayersPage extends StatelessWidget {
  const PlayersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final members = [
      ('João', 'Ativo'),
      ('Mateus', 'Ativo'),
      ('Pedro', 'Lista de espera'),
      ('Rafael', 'Inativo'),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: members.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final member = members[index];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person_outline_rounded),
            ),
            title: Text(member.$1),
            subtitle: Text('Posição: Atacante • Última presença: 2 dias'),
            trailing: Chip(
              label: Text(member.$2),
              visualDensity: VisualDensity.compact,
            ),
          ),
        );
      },
    );
  }
}
