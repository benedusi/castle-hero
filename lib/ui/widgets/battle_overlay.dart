import 'package:flutter/material.dart';
import '../../campaign/tiers.dart';
import '../theme.dart';

class BattleOverlay extends StatelessWidget {
  final bool won;
  final bool crowned;
  final Tier tier;
  final int turns;
  final VoidCallback onContinue;

  const BattleOverlay({
    super.key,
    required this.won,
    required this.crowned,
    required this.tier,
    required this.turns,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromRGBO(18, 21, 27, 0.85),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: SiegeTheme.panel,
            border: Border.all(color: SiegeTheme.line),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                crowned
                    ? 'CROWNED KING 👑'
                    : won
                        ? 'CASTLE TAKEN'
                        : 'SIEGE REPELLED',
                style: TextStyle(
                  fontFamily: 'Oswald',
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                  color: crowned || won ? SiegeTheme.good : SiegeTheme.danger,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                _getMessage(),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: SiegeTheme.muted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SiegeTheme.attacker,
                  foregroundColor: const Color(0xFF1a1109),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  crowned
                      ? 'NEW CAMPAIGN'
                      : won
                          ? 'MARCH ON'
                          : 'REGROUP',
                  style: TextStyle(
                    fontFamily: 'Oswald',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.70,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMessage() {
    if (crowned) {
      return 'The Fortress falls on day $turns. Every castle is yours — the realm is won.';
    } else if (won) {
      return '${tier.name} falls on day $turns. The road to the crown opens further.';
    } else {
      return 'Your catapult broke on day $turns. ${tier.name} still stands — regroup and try again.';
    }
  }
}
