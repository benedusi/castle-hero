import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../campaign/campaign.dart';
import '../game_controller.dart';
import '../theme.dart';
import 'battle_screen.dart';

class CampaignMapScreen extends StatelessWidget {
  const CampaignMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<GameController>(
          builder: (context, controller, _) {
            return Stack(
              children: [
                // Campaign map background
                Positioned.fill(
                  child: Image.asset(
                    'assets/art/campaign/campaign-map.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                // Dark gradient for readability
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          SiegeTheme.background.withOpacity(0.5),
                          SiegeTheme.background.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),
                // Content overlay
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(controller),
                        const SizedBox(height: 24),
                        _buildNodeList(context, controller),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(GameController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'CAMPAIGN',
              style: TextStyle(
                fontFamily: 'Oswald',
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.56,
                color: SiegeTheme.ink,
              ),
            ),
            if (controller.isCrowned())
              const Text(
                '👑',
                style: TextStyle(fontSize: 24),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'March to the crown',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: SiegeTheme.muted,
          ),
        ),
      ],
    );
  }

  Widget _buildNodeList(BuildContext context, GameController controller) {
    final nodes = controller.campaign.nodes;

    return Column(
      children: nodes.asMap().entries.map((entry) {
        final index = entry.key;
        final node = entry.value;
        final isLast = index == nodes.length - 1;

        return _CampaignNode(
          node: node,
          isLast: isLast,
          onTap: node.status == NodeStatus.current
              ? () => _startBattle(context, controller)
              : null,
        );
      }).toList(),
    );
  }

  void _startBattle(BuildContext context, GameController controller) {
    controller.startBattle();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: controller,
          child: const BattleScreen(),
        ),
      ),
    );
  }
}

class _CampaignNode extends StatelessWidget {
  final CampaignNode node;
  final bool isLast;
  final VoidCallback? onTap;

  const _CampaignNode({
    required this.node,
    required this.isLast,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = node.status == NodeStatus.completed;
    final isCurrent = node.status == NodeStatus.current;
    final isLocked = node.status == NodeStatus.locked;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBadge(isCompleted, isCurrent, isLocked),
          const SizedBox(width: 16),
          Expanded(
            child: _buildInfo(context, isCompleted, isCurrent, isLocked),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(bool isCompleted, bool isCurrent, bool isLocked) {
    // Choose production node state asset
    String assetPath;
    if (isCompleted) {
      assetPath = 'assets/art/production/nodes/node-conquered.png';
    } else if (isLast) {
      assetPath = 'assets/art/production/nodes/node-throne.png';
    } else if (isCurrent) {
      assetPath = 'assets/art/production/nodes/node-current.png';
    } else {
      assetPath = 'assets/art/production/nodes/node-locked.png';
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: SiegeTheme.attacker.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildInfo(
      BuildContext context, bool isCompleted, bool isCurrent, bool isLocked) {
    return Opacity(
      opacity: isLocked ? 0.5 : 1.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            node.tier.name,
            style: TextStyle(
              fontFamily: 'Oswald',
              fontSize: 19,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.38,
              color: isLocked ? SiegeTheme.muted : SiegeTheme.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isCompleted
                ? 'Conquered'
                : isCurrent
                    ? 'HP ${node.tier.hp} • Sight ${node.tier.aiConfig.sight}'
                    : 'Locked',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: SiegeTheme.muted,
            ),
          ),
          if (isCurrent) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: SiegeTheme.attacker,
                foregroundColor: const Color(0xFF1a1109),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              child: Text(
                'LAY SIEGE',
                style: TextStyle(
                  fontFamily: 'Oswald',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.52,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
