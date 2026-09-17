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
  int? _selectedCardIndex;

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
                      // Infantry pressures wall, not catapult
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
                      // Infantry pressures the wall (Art Bible §8)
                      infantry: state.infantry,
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
                  const SizedBox(height: 8),
                  // Resources (stone/food/gold fixed order)
                  ResourceDisplay(
                    stone: state.attacker.stone,
                    food: state.attacker.food,
                    gold: state.attacker.gold,
                  ),
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
    
    // Icon asset based on which bar this is
    final iconAsset = isDefender 
        ? 'assets/art/production/icons/icon-wall.png'
        : 'assets/art/production/icons/icon-catapult.png';
    
    final hasBadges = fire.isNotEmpty || (infantry != null && infantry > 0);

    return Row(
      children: [
        // HUD icon (catapult LEFT warm / wall RIGHT cool) - fixed small size
        Container(
          width: 36,
          height: 48,
          decoration: BoxDecoration(
            color: SiegeTheme.background,
            border: Border.all(
              color: SiegeTheme.line.withOpacity(0.6),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              iconAsset,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              // NO color tint - draw as-authored with alpha
            ),
          ),
        ),
        const SizedBox(width: 4),
        // HP strip - MUST be Expanded to flex with available width
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              // Beveled dark frame
              color: SiegeTheme.background,
              border: Border.all(
                color: SiegeTheme.line.withOpacity(0.6),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Stack(
                children: [
                  // Background
                  Positioned.fill(
                    child: Container(
                      color: SiegeTheme.panel2,
                    ),
                  ),
                  // Filled HP bar
                  Positioned.fill(
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
                  // White centered current/max text ON the bar (never covered)
                  Positioned.fill(
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$current',
                            style: TextStyle(
                              fontFamily: 'Oswald',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.8),
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
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.7),
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.8),
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
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.85),
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.8),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Label (top-left corner, small)
                  Positioned(
                    left: 6,
                    top: 3,
                    child: Text(
                      label.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Oswald',
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.32,
                        color: Colors.white.withOpacity(0.6),
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.8),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Compact status badges to the RIGHT of the bar (never cover text, minimal width)
        if (hasBadges) ...[
          const SizedBox(width: 4),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (fire.isNotEmpty)
                _buildCompactFireBadge(fire),
              if (fire.isNotEmpty && infantry != null && infantry > 0)
                const SizedBox(height: 3),
              if (infantry != null && infantry > 0)
                _buildCompactInfantryBadge(infantry),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBarBadge(String badgeAsset, String text, Color color) {
    // Badge that sits ON the HP bar (infantry, etc.)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        border: Border.all(
          color: color.withOpacity(0.8),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            badgeAsset,
            width: 16,
            height: 16,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Oswald',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFireBadge(List<int> fire) {
    // Fire DoT badge: digit-free pill chrome + live Flutter countdown
    return Container(
      height: 24,
      padding: const EdgeInsets.only(left: 4, right: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        border: Border.all(
          color: SiegeTheme.danger.withOpacity(0.8),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Digit-free pill chrome (flame icon on left)
          Image.asset(
            'assets/art/production/badges/pill-fire-turns.png',
            height: 20,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 4),
          // Live Flutter countdown text in the empty right area
          Text(
            fire.join('→'),
            style: TextStyle(
              fontFamily: 'Oswald',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactFireBadge(List<int> fire) {
    // Ultra-compact fire badge for narrow widths: small circular badge + short countdown
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Circular fire badge (smaller for tight widths)
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: SiegeTheme.danger.withOpacity(0.8),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Image.asset(
              'assets/art/production/badges/badge-fire.png',
              width: 14,
              height: 14,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(width: 2),
        // Live countdown text beside the badge (compact)
        Text(
          fire.join('→'),
          style: TextStyle(
            fontFamily: 'Oswald',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: SiegeTheme.danger,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.8),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactInfantryBadge(int infantry) {
    // Ultra-compact infantry badge for narrow widths
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Circular infantry badge (smaller for tight widths)
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: SiegeTheme.attacker.withOpacity(0.8),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Image.asset(
              'assets/art/production/badges/badge-infantry.png',
              width: 14,
              height: 14,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(width: 2),
        // Stack count beside the badge (compact)
        Text(
          '×$infantry',
          style: TextStyle(
            fontFamily: 'Oswald',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: SiegeTheme.attacker,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.8),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
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

              final isSelected = _selectedCardIndex == index;
              
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < 2 ? 8.0 : 0,
                  ),
                  // Fixed aspect ratio slot - all cards equal size
                  child: GestureDetector(
                    onTap: canPlay ? () {
                      setState(() {
                        _selectedCardIndex = isSelected ? null : index;
                      });
                    } : null,
                    child: Transform.translate(
                      offset: isSelected ? const Offset(0, -8) : Offset.zero,
                      child: AspectRatio(
                        aspectRatio: 2 / 3, // Portrait card slot (0.667)
                        child: CardWidget(
                          card: def,
                          canPlay: canPlay && canAffordCard,
                          onTap: null, // Selection handled by GestureDetector above
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
    final canAct = state.phase == Phase.player && !controller.isAiThinking;
    final hasSelection = _selectedCardIndex != null;
    final canPlaySelected = hasSelection && 
        canAct && 
        _selectedCardIndex! < state.attacker.hand.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Primary actions: Play (warm) + Discard (cool)
        Row(
          children: [
            // Discard (cool teal/steel)
            Expanded(
              child: ElevatedButton(
                onPressed: hasSelection && canAct
                    ? () {
                        controller.discardCard(_selectedCardIndex!);
                        setState(() => _selectedCardIndex = null);
                      }
                    : (canAct && state.attacker.hand.isNotEmpty
                        ? () => _showDiscardDialog(context, controller, state)
                        : null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SiegeTheme.defender,
                  foregroundColor: SiegeTheme.ink,
                  disabledBackgroundColor: SiegeTheme.panel2,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
            // Play (warm amber - primary CTA)
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: canPlaySelected
                    ? () {
                        controller.playCard(_selectedCardIndex!);
                        setState(() => _selectedCardIndex = null);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SiegeTheme.attacker,
                  foregroundColor: SiegeTheme.background,
                  disabledBackgroundColor: SiegeTheme.panel2,
                  disabledForegroundColor: SiegeTheme.muted,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: canPlaySelected ? 4 : 0,
                ),
                child: Text(
                  'PLAY',
                  style: TextStyle(
                    fontFamily: 'Oswald',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.75,
                  ),
                ),
              ),
            ),
          ],
        ),
        // Secondary: Retreat (text button, tucked)
        TextButton(
          onPressed: () => _handleRetreat(context, controller),
          style: TextButton.styleFrom(
            foregroundColor: SiegeTheme.muted,
            padding: const EdgeInsets.symmetric(vertical: 6),
          ),
          child: Text(
            'Retreat',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              decoration: TextDecoration.underline,
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
