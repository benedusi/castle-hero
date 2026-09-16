import 'package:flutter/material.dart';
import '../theme.dart';

class BattleLog extends StatelessWidget {
  final List<String> log;

  const BattleLog({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final recentLog = log.length > 5 ? log.sublist(log.length - 5) : log;

    return Container(
      height: 100,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: SiegeTheme.panel.withOpacity(0.85),
        border: Border.all(color: SiegeTheme.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.builder(
        reverse: true,
        itemCount: recentLog.length,
        itemBuilder: (context, index) {
          final entry = recentLog[recentLog.length - 1 - index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Text(
              entry,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: SiegeTheme.ink,
              ),
            ),
          );
        },
      ),
    );
  }
}
