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
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(controller),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _buildNodeList(context, controller),
                  ),
                ],
              ),
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

    return ListView.builder(
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        final node = nodes[index];
        final isLast = index == nodes.length - 1;

        return _CampaignNode(
          node: node,
          isLast: isLast,
          onTap: node.status == NodeStatus.current
              ? () => _startBattle(context, controller)
              : null,
        );
      },
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
    final icon = isCompleted ? '🏳️' : (isLast ? '👑' : '🏰');
    final color = isCompleted
        ? SiegeTheme.good
        : isCurrent
            ? SiegeTheme.attacker
            : SiegeTheme.line;

    return Stack(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: SiegeTheme.panel,
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        if (isCompleted)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: SiegeTheme.good,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.check,
                  size: 12,
                  color: SiegeTheme.background,
                ),
              ),
            ),
          ),
      ],
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
