import 'package:flutter/material.dart';
import '../theme.dart';

class ResourceDisplay extends StatelessWidget {
  final int stone;
  final int food;
  final int gold;
  final bool stoneUnaffordable;
  final bool foodUnaffordable;
  final bool goldUnaffordable;

  const ResourceDisplay({
    super.key,
    required this.stone,
    required this.food,
    required this.gold,
    this.stoneUnaffordable = false,
    this.foodUnaffordable = false,
    this.goldUnaffordable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildResourceChip(
            iconPath: 'assets/art/production/icons/icon-stone.png',
            value: stone,
            isUnaffordable: stoneUnaffordable,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildResourceChip(
            iconPath: 'assets/art/production/icons/icon-food.png',
            value: food,
            isUnaffordable: foodUnaffordable,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildResourceChip(
            iconPath: 'assets/art/production/icons/icon-gold.png',
            value: gold,
            isUnaffordable: goldUnaffordable,
          ),
        ),
      ],
    );
  }

  Widget _buildResourceChip({
    required String iconPath,
    required int value,
    required bool isUnaffordable,
  }) {
    // Resource HUD Batch 6: chip frame + icon left + Flutter number right (smaller for top layout)
    final frameAsset = isUnaffordable
        ? 'assets/art/production/chrome/resource-chip-unaffordable.png'
        : 'assets/art/production/chrome/resource-chip-frame.png';

    return Container(
      height: 42, // Smaller for top position (was 56)
      decoration: BoxDecoration(
        // Use production chrome chip frame as actual panel
        image: DecorationImage(
          image: AssetImage(frameAsset),
          fit: BoxFit.fill,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6), // Reduced from 8
        child: Row(
          children: [
            // Icon left (smaller)
            Image.asset(
              iconPath,
              width: 28, // Reduced from 40
              height: 28,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 6), // Reduced from 8
            // Flutter number right
            Expanded(
              child: Text(
                '$value',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'Oswald',
                  fontSize: 22, // Reduced from 28
                  fontWeight: FontWeight.w700,
                  color: isUnaffordable ? SiegeTheme.danger : SiegeTheme.ink,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
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
    );
  }
}
