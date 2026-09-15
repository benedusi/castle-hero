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
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        children: [
          _buildHeader(state),
          const SizedBox(height: 12),
          _buildHealthBars(state),
          const SizedBox(height: 12),
          BattleLog(log: state.log),
          const SizedBox(height: 12),
          ResourceDisplay(
            stone: state.attacker.stone,
            food: state.attacker.food,
            gold: state.attacker.gold,
          ),
          const SizedBox(height: 10),
          _buildHandHeader(state),
          const SizedBox(height: 8),
          _buildHand(controller, state),
          const SizedBox(height: 12),
          _buildActions(context, controller, state),
          _buildHint(controller, state),
        ],
      ),
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

  Widget _buildHealthBars(GameState state) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: SiegeTheme.panel,
        border: Border.all(color: SiegeTheme.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          HealthBar(
            label: 'The castle — wall & gate',
            current: state.defender.wall,
            max: state.wallMax,
            isDefender: true,
            fire: state.gateFire,
          ),
          const SizedBox(height: 12),
          HealthBar(
            label: 'Your siege — catapult',
            current: state.attacker.catapult,
            max: state.catapultMax,
            isDefender: false,
            fire: state.catapultFire,
            infantry: state.infantry,
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
      height: 140,
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
