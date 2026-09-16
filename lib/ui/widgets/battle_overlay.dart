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
    // Choose result overlay art based on outcome
    String overlayAsset;
    if (crowned) {
      overlayAsset = 'assets/art/ui/result_crowned_king.png';
    } else if (won) {
      overlayAsset = 'assets/art/ui/result_castle_taken.png';
    } else {
      overlayAsset = 'assets/art/ui/result_siege_repelled.png';
    }

    return Container(
      color: SiegeTheme.background.withOpacity(0.85),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              // Result overlay art
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  overlayAsset,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              // Gradient for text readability
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      crowned
                          ? 'CROWNED KING'
                          : won
                              ? 'CASTLE TAKEN'
                              : 'SIEGE REPELLED',
                      style: TextStyle(
                        fontFamily: 'Oswald',
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                        color: crowned || won
                            ? SiegeTheme.attackerGold
                            : SiegeTheme.muted,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.8),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getMessage(),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        color: SiegeTheme.ink,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.8),
                            offset: const Offset(0, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: crowned || won
                            ? SiegeTheme.attacker
                            : SiegeTheme.muted,
                        foregroundColor: const Color(0xFF0B1020),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 14),
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
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.75,
                        ),
                      ),
                    ),
                  ],
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
