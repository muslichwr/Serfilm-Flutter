import 'package:flutter/material.dart';

/// Widget untuk menampilkan statistik user di halaman profil
class ProfileStats extends StatelessWidget {
  final List<Map<String, dynamic>> stats;
  const ProfileStats({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            Row(
              children: [
                Icon(
                  stats[i]['icon'] as IconData,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Text(
                  stats[i]['label'] as String,
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                Text(
                  stats[i]['value'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (i < stats.length - 1) const Divider(),
          ],
        ],
      ),
    );
  }
}
