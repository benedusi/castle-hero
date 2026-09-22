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
                // Clean campaign map 9:16 plate (no nodes/labels/chrome)
                Positioned.fill(
                  child: Image.asset(
                    'assets/art/production/plates/campaign-map-9x16.png',
                    fit: BoxFit.cover,
                  ),
                ),
                // Campaign path composition in Flutter
                _buildCampaignPath(context, controller),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCampaignPath(BuildContext context, GameController controller) {
    final nodes = controller.campaign.nodes;
    final size = MediaQuery.of(context).size;
    
    // Node positions based on campaign-layout-ref.png
    // Nodes are positioned along the path from bottom to top
    final nodePositions = [
      {'top': 0.82, 'left': 0.50}, // Node 0: The Outpost (bottom)
      {'top': 0.67, 'left': 0.50}, // Node 1: The Keep
      {'top': 0.52, 'left': 0.50}, // Node 2: The Citadel
      {'top': 0.37, 'left': 0.50}, // Node 3: The Bastion
      {'top': 0.15, 'left': 0.50}, // Node 4: The Fortress/Throne (top)
    ];
    
    return Stack(
      children: [
        // Header
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: _buildHeader(controller),
        ),
        // Position 5 campaign nodes using layout ref coordinates
        ...nodes.asMap().entries.map((entry) {
          final index = entry.key;
          final node = entry.value;
          final isLast = index == nodes.length - 1;
          final pos = nodePositions[index];
          
          return Positioned(
            top: size.height * pos['top']!,
            left: size.width * pos['left']!,
            child: Transform.translate(
              offset: const Offset(-60, -60), // Center the 120px node
              child: _CampaignNode(
                node: node,
                isLast: isLast,
                onTap: node.status == NodeStatus.current
                    ? () => _startBattle(context, controller)
                    : null,
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildHeader(GameController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
        ),
        if (controller.isCrowned())
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: SiegeTheme.attackerGold.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Text(
              '👑',
              style: TextStyle(fontSize: 24),
            ),
          ),
      ],
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

    return Container(
      width: 280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Production node badge (labels baked in)
          _buildBadge(isCompleted, isCurrent, isLocked),
          // Only show attack button for current node
          if (isCurrent) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: 180,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SiegeTheme.attacker,
                  foregroundColor: SiegeTheme.background,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  'ATTACK',
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
        ],
      ),
    );
  }

  Widget _buildBadge(bool isCompleted, bool isCurrent, bool isLocked) {
    // Choose production node state asset (labels baked in)
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
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: SiegeTheme.attacker.withOpacity(0.5),
                  blurRadius: 16,
                  spreadRadius: 3,
                )
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ColorFiltered(
          colorFilter: isLocked
              ? ColorFilter.mode(
                  Colors.black.withOpacity(0.5),
                  BlendMode.darken,
                )
              : const ColorFilter.mode(
                  Colors.transparent,
                  BlendMode.multiply,
                ),
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
