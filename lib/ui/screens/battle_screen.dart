import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../engine/game_state.dart';
import '../../engine/cards.dart';
import '../../engine/engine.dart';
import '../game_controller.dart';
import '../theme.dart';
import '../widgets/health_bar.dart';
import '../widgets/resource_display.dart';
import '../widgets/card_widget.dart';
import '../widgets/battle_log.dart';
import '../widgets/battle_overlay.dart';

class BattleScreen extends StatelessWidget {
  const BattleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<GameController>(
          builder: (context, controller, _) {
            final state = controller.battleState;

            if (state == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return Stack(
              children: [
                _buildBattleContent(context, controller, state),
                if (state.phase == Phase.over)
                  BattleOverlay(
                    won: controller.didPlayerWin(),
                    crowned: controller.isCrowned(),
                    tier: controller.campaign.getCurrentTier(),
                    turns: state.turn,
                    onContinue: () => _handleBattleEnd(context, controller),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBattleContent(
      BuildContext context, GameController controller, GameState state) {
    // Choose background based on game state - using production 9:16 plates
    String backgroundAsset = 'assets/art/production/plates/stage-calm-9x16.png';
    if (state.gateFire.isNotEmpty || state.turn > 5) {
      // Use pressure plate for fire or later turns (dedicated fire plate coming in batch 2)
      backgroundAsset = 'assets/art/production/plates/stage-pressure-9x16.png';
    }

    return Stack(
      children: [
        // Full-bleed 9:16 battle plate background
        Positioned.fill(
          child: Image.asset(
            backgroundAsset,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        // Subtle gradient at bottom for chrome readability
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 350,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
        ),
        // Header and day label (top safe area)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: _buildHeader(state),
            ),
          ),
        ),
        // HP bars positioned L/R over battlefield assets
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Catapult HP (LEFT, warm)
                  Expanded(
                    child: _buildSingleHealthBar(
                      label: 'Catapult',
                      current: state.attacker.catapult,
                      max: state.catapultMax,
                      isDefender: false,
                      fire: state.catapultFire,
                      infantry: state.infantry,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Wall/Gate HP (RIGHT, cool)
                  Expanded(
                    child: _buildSingleHealthBar(
                      label: 'Wall & Gate',
                      current: state.defender.wall,
                      max: state.wallMax,
                      isDefender: true,
                      fire: state.gateFire,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Bottom chrome bar: log → resources → hand → actions
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Battle log (1-2 lines)
                  BattleLog(log: state.log),
                  const SizedBox(height: 10),
                  // Resources (stone/food/gold fixed order)
                  ResourceDisplay(
                    stone: state.attacker.stone,
                    food: state.attacker.food,
                    gold: state.attacker.gold,
                  ),
                  const SizedBox(height: 10),
                  // Hand header
                  _buildHandHeader(state),
                  const SizedBox(height: 6),
                  // Hand of 3
                  _buildHand(controller, state),
                  const SizedBox(height: 10),
                  // Play / Discard (thumb zone)
                  _buildActions(context, controller, state),
                  _buildHint(controller, state),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(GameState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'SIEGE',
          style: TextStyle(
            fontFamily: 'Oswald',
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.56,
            color: SiegeTheme.ink,
          ),
        ),
        Text(
          'Day ${state.turn}',
          style: TextStyle(
            fontFamily: 'Oswald',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: SiegeTheme.muted,
          ),
        ),
      ],
    );
  }

  Widget _buildSingleHealthBar({
    required String label,
    required int current,
    required int max,
    required bool isDefender,
    List<int> fire = const [],
    int? infantry,
  }) {
    final percentage = (current / max).clamp(0.0, 1.0);
    final isLow = percentage <= 0.25;
    final color = isDefender ? SiegeTheme.defender : SiegeTheme.attacker;
    final dimColor = isDefender ? SiegeTheme.defenderDim : SiegeTheme.attackerDim;

    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: SiegeTheme.panel.withOpacity(0.85),
        border: Border.all(
          color: isDefender ? SiegeTheme.defender.withOpacity(0.5) : SiegeTheme.attacker.withOpacity(0.5),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Oswald',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.44,
                  color: SiegeTheme.muted,
                ),
              ),
              Row(
                children: [
                  Text(
                    '$current',
                    style: TextStyle(
                      fontFamily: 'Oswald',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isLow ? SiegeTheme.danger : color,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    '/$max',
                    style: TextStyle(
                      fontFamily: 'Oswald',
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: SiegeTheme.muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          // HP bar
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: SiegeTheme.background,
              borderRadius: BorderRadius.circular(6),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
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
          // Status indicators
          if (fire.isNotEmpty || (infantry != null && infantry > 0))
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (fire.isNotEmpty)
                    _buildCompactStatus(
                      'assets/art/ui/status_fire.png',
                      fire.join('·'),
                      SiegeTheme.danger,
                    ),
                  if (infantry != null && infantry > 0)
                    _buildCompactStatus(
                      'assets/art/ui/status_infantry.png',
                      '×$infantry',
                      SiegeTheme.attacker,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompactStatus(String assetPath, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: SiegeTheme.background.withOpacity(0.7),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            assetPath,
            width: 14,
            height: 14,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Oswald',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandHeader(GameState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'YOUR HAND',
          style: TextStyle(
            fontFamily: 'Oswald',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.65,
            color: SiegeTheme.muted,
          ),
        ),
        Text(
          'deck ${state.attacker.deck.length} • discard ${state.attacker.discard.length}',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: SiegeTheme.muted,
          ),
        ),
      ],
    );
  }

  Widget _buildHand(GameController controller, GameState state) {
    final hand = state.attacker.hand;
    final canPlay = state.phase == Phase.player && !controller.isAiThinking;

    return SizedBox(
      height: 160, // Taller for proper card aspect ratio
      child: Row(
        children: List.generate(
          3,
          (index) {
            if (index < hand.length) {
              final card = hand[index];
              final def = attackerCards[card]!;
              final canAffordCard = canAfford(
                state.attacker.stone,
                state.attacker.food,
                state.attacker.gold,
                def.cost,
              );

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < 2 ? 8.0 : 0,
                  ),
                  child: CardWidget(
                    card: def,
                    canPlay: canPlay && canAffordCard,
                    onTap: canPlay ? () => controller.playCard(index) : null,
                  ),
                ),
              );
            } else {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < 2 ? 8.0 : 0),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildActions(
      BuildContext context, GameController controller, GameState state) {
    final canAct = state.phase == Phase.player && !controller.isAiThinking;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: canAct && state.attacker.hand.isNotEmpty
                ? () => _showDiscardDialog(context, controller, state)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: SiegeTheme.panel,
              foregroundColor: SiegeTheme.ink,
              disabledBackgroundColor: SiegeTheme.panel2,
              padding: const EdgeInsets.symmetric(vertical: 11),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: SiegeTheme.line),
              ),
            ),
            child: Text(
              'DISCARD',
              style: TextStyle(
                fontFamily: 'Oswald',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.52,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _handleRetreat(context, controller),
            style: ElevatedButton.styleFrom(
              backgroundColor: SiegeTheme.panel,
              foregroundColor: SiegeTheme.ink,
              padding: const EdgeInsets.symmetric(vertical: 11),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: SiegeTheme.line),
              ),
            ),
            child: Text(
              'RETREAT',
              style: TextStyle(
                fontFamily: 'Oswald',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.52,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHint(GameController controller, GameState state) {
    String hint;
    if (controller.isAiThinking) {
      hint = 'The castle takes aim…';
    } else if (state.phase == Phase.player) {
      hint = 'Play or discard one card to end your turn.';
    } else {
      hint = '';
    }

    return Container(
      height: 32,
      alignment: Alignment.center,
      child: Text(
        hint,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          color: controller.isAiThinking ? SiegeTheme.defender : SiegeTheme.muted,
          fontWeight: controller.isAiThinking ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  void _showDiscardDialog(
      BuildContext context, GameController controller, GameState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SiegeTheme.panel,
        title: Text(
          'Discard a card',
          style: TextStyle(color: SiegeTheme.ink),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            state.attacker.hand.length,
            (index) {
              final card = state.attacker.hand[index];
              final def = attackerCards[card]!;
              return ListTile(
                title: Text(
                  def.name,
                  style: TextStyle(color: SiegeTheme.ink),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  controller.discardCard(index);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: SiegeTheme.muted),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRetreat(BuildContext context, GameController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SiegeTheme.panel,
        title: Text(
          'Retreat?',
          style: TextStyle(color: SiegeTheme.ink),
        ),
        content: Text(
          'Abandon this siege and return to the campaign map?',
          style: TextStyle(color: SiegeTheme.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: SiegeTheme.muted),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.exitBattle();
              Navigator.of(context).pop();
            },
            child: Text(
              'Retreat',
              style: TextStyle(color: SiegeTheme.danger),
            ),
          ),
        ],
      ),
    );
  }

  void _handleBattleEnd(BuildContext context, GameController controller) {
    controller.exitBattle();
    Navigator.of(context).pop();
  }
}
