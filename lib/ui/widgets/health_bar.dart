import 'package:flutter/material.dart';
import '../theme.dart';

class HealthBar extends StatelessWidget {
  final String label;
  final int current;
  final int max;
  final bool isDefender;
  final List<int> fire;
  final int? infantry;

  const HealthBar({
    super.key,
    required this.label,
    required this.current,
    required this.max,
    required this.isDefender,
    this.fire = const [],
    this.infantry,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (current / max).clamp(0.0, 1.0);
    final isLow = percentage <= 0.25;
    final color = isDefender ? SiegeTheme.defender : SiegeTheme.attacker;
    final dimColor = isDefender ? SiegeTheme.defenderDim : SiegeTheme.attackerDim;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Oswald',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.52,
                color: SiegeTheme.muted,
              ),
            ),
            Row(
              children: [
                Text(
                  '$current',
                  style: TextStyle(
                    fontFamily: 'Oswald',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isLow ? SiegeTheme.danger : color,
                    height: 1.0,
                  ),
                ),
                Text(
                  '/$max',
                  style: TextStyle(
                    fontFamily: 'Oswald',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: SiegeTheme.muted,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          height: 16,
          decoration: BoxDecoration(
            color: SiegeTheme.panel2,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [dimColor, color],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (fire.isNotEmpty || (infantry != null && infantry! > 0))
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Wrap(
              spacing: 6,
              children: [
                if (fire.isNotEmpty)
                  _buildTag(
                    '🔥 ${isDefender ? 'gate' : 'catapult'} ablaze (${fire.join('·')})',
                    SiegeTheme.attacker,
                  ),
                if (infantry != null && infantry! > 0)
                  _buildTag(
                    '⚔️ infantry ×$infantry',
                    SiegeTheme.ink,
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: SiegeTheme.line),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
