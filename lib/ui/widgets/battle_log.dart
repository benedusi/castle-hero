import 'package:flutter/material.dart';
import '../theme.dart';

class BattleLog extends StatelessWidget {
  final List<String> log;

  const BattleLog({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final recentLog = log.length > 2 ? log.sublist(log.length - 2) : log;

    return Container(
      height: 52, // Compact: 1-2 lines max
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: SiegeTheme.panel.withOpacity(0.85),
        border: Border.all(color: SiegeTheme.line),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListView.builder(
        reverse: true,
        itemCount: recentLog.length,
        itemBuilder: (context, index) {
          final entry = recentLog[recentLog.length - 1 - index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              entry,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: SiegeTheme.ink,
                height: 1.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
    );
  }
}
