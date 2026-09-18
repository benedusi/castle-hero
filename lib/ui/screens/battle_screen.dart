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

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
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
          height: 280, // Reduced from 350 to tighten dead band
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
        // HP bars positioned L/R over battlefield assets - mock §03 chrome
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Container(
                height: 58, // Taller to accommodate bars + statuses below
                decoration: BoxDecoration(
                  // Use production chrome frame as actual panel
                  image: const DecorationImage(
                    image: AssetImage('assets/art/production/chrome/hp-strip-frame.png'),
                    fit: BoxFit.fill,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: Row(
                    children: [
                      // Catapult side (LEFT, warm)
                      Expanded(
                        child: _buildSideSlot(
                          iconAsset: 'assets/art/production/icons/icon-catapult.png',
                          current: state.attacker.catapult,
                          max: state.catapultMax,
                          isDefender: false,
                          fire: state.catapultFire,
                          infantry: null, // Infantry on wall only
                        ),
                      ),
                      // Divider between sides
                      Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                      // Wall side (RIGHT, cool)
                      Expanded(
                        child: _buildSideSlot(
                          iconAsset: 'assets/art/production/icons/icon-wall.png',
                          current: state.defender.wall,
                          max: state.wallMax,
                          isDefender: true,
                          fire: state.gateFire,
                          infantry: state.infantry,
                        ),
                      ),
                    ],
                  ),
                ),
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
                  const SizedBox(height: 8),
                  // Resources (stone/food/gold fixed order)
                  _buildResourceDisplay(state),
                  const SizedBox(height: 8),
                  // Hand header
                  _buildHandHeader(state),
                  const SizedBox(height: 6),
                  // Hand of 3
                  _buildHand(controller, state),
                  const SizedBox(height: 8),
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

  Widget _buildResourceDisplay(GameState state) {
    // No selection state - resources just show current balance
    return ResourceDisplay(
      stone: state.attacker.stone,
      food: state.attacker.food,
      gold: state.attacker.gold,
      stoneUnaffordable: false,
      foodUnaffordable: false,
      goldUnaffordable: false,
    );
  }

  Widget _buildSideSlot({
    required String iconAsset,
    required int current,
    required int max,
    required bool isDefender,
    List<int> fire = const [],
    int? infantry,
  }) {
    final percentage = (current / max).clamp(0.0, 1.0);
    final color = isDefender ? SiegeTheme.defender : SiegeTheme.attacker;
    final dimColor = isDefender ? SiegeTheme.defenderDim : SiegeTheme.attackerDim;

    final hasStatuses = fire.isNotEmpty || (infantry != null && infantry > 0);

    // Layout: HP bar on top, statuses below (not beside)
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row: [framed icon][Expanded HP bar with trough + centered text]
        Row(
          children: [
            // Framed icon (no ColorFilter)
            SizedBox(
              width: 32,
              height: 32,
              child: Image.asset(
                iconAsset,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 4),
            // HP bar with trough chrome + centered text (Expanded to fill available width)
            Expanded(
              child: Container(
                height: 32,
                decoration: BoxDecoration(
                  // Use production trough chrome as background
                  image: const DecorationImage(
                    image: AssetImage('assets/art/production/chrome/hp-bar-trough.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Stack(
                  children: [
                    // HP fill gradient
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: percentage,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [dimColor, color],
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    // Centered HP text - fully readable, never covered
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$current',
                            style: TextStyle(
                              fontFamily: 'Oswald',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.9),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            ' / ',
                            style: TextStyle(
                              fontFamily: 'Oswald',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.9),
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.9),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '$max',
                            style: TextStyle(
                              fontFamily: 'Oswald',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.9),
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.9),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        // Below: status badges (fire medallion + DoT, infantry helmet + ×N)
        if (hasStatuses) ...[
          const SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.only(left: 36), // Align below HP bar (after icon)
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Fire medallion + DoT countdown (under relevant bar)
                if (fire.isNotEmpty) ...[
                  // Flame medallion only (badge-fire tip)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Image.asset(
                      'assets/art/production/badges/badge-fire.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 2),
                  // DoT countdown: first tick only
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: SiegeTheme.danger.withOpacity(0.9),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${fire.first}',
                        style: TextStyle(
                          fontFamily: 'Oswald',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: SiegeTheme.danger,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                  if (infantry != null && infantry > 0) const SizedBox(width: 6),
                ],
                // Infantry tags (wall only, can sit next to fire)
                if (infantry != null && infantry > 0) ...[
                  // Helmet badge
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: Image.asset(
                      'assets/art/production/badges/badge-infantry.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 2),
                  // ×N tag with live Flutter text
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: SiegeTheme.attacker.withOpacity(0.9),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '×$infantry',
                      style: TextStyle(
                        fontFamily: 'Oswald',
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: SiegeTheme.attacker,
                        height: 1.0,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
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
                  // Fixed aspect ratio slot - all cards equal size
                  child: Dismissible(
                    key: ValueKey('card_$index'),
                    direction: DismissDirection.down,
                    onDismissed: (direction) {
                      if (canPlay) {
                        controller.discardCard(index);
                      }
                    },
                    child: AspectRatio(
                      aspectRatio: 2 / 3, // Portrait card slot (0.667)
                      child: GestureDetector(
                        onTap: canPlay && canAffordCard ? () {
                          controller.playCard(index);
                        } : null,
                        child: CardWidget(
                          card: def,
                          canPlay: canPlay && canAffordCard,
                          onTap: null, // Tap handled by GestureDetector above
                        ),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              // Empty slot - same fixed aspect ratio footprint
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < 2 ? 8.0 : 0,
                  ),
                  child: AspectRatio(
                    aspectRatio: 2 / 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: SiegeTheme.background.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: SiegeTheme.line.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
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
    // Simplified actions: just Retreat (tap-to-play, swipe-to-discard on cards directly)
    return TextButton(
      onPressed: () => _handleRetreat(context, controller),
      style: TextButton.styleFrom(
        foregroundColor: SiegeTheme.muted,
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
      child: Text(
        'Retreat',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildHint(GameController controller, GameState state) {
    String hint;
    if (controller.isAiThinking) {
      hint = 'The castle takes aim…';
    } else if (state.phase == Phase.player) {
      hint = 'Tap to play · swipe down to discard';
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
