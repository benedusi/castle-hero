import 'tiers.dart';

enum NodeStatus {
  locked,
  current,
  completed,
}

class CampaignNode {
  final Tier tier;
  final NodeStatus status;

  CampaignNode({required this.tier, required this.status});
}

class CampaignState {
  final int currentNode;
  final List<CampaignNode> nodes;
  final bool crowned;

  CampaignState({
    required this.currentNode,
    required this.nodes,
    required this.crowned,
  });

  factory CampaignState.initial() {
    final nodes = tiers.asMap().entries.map((entry) {
      final index = entry.key;
      final tier = entry.value;
      final status = index == 0
          ? NodeStatus.current
          : NodeStatus.locked;
      return CampaignNode(tier: tier, status: status);
    }).toList();

    return CampaignState(
      currentNode: 0,
      nodes: nodes,
      crowned: false,
    );
  }

  CampaignState onVictory() {
    if (currentNode >= nodes.length - 1) {
      return CampaignState(
        currentNode: currentNode,
        nodes: nodes.asMap().entries.map((entry) {
          return CampaignNode(
            tier: entry.value.tier,
            status: NodeStatus.completed,
          );
        }).toList(),
        crowned: true,
      );
    }

    final updatedNodes = nodes.asMap().entries.map((entry) {
      final index = entry.key;
      final node = entry.value;

      if (index == currentNode) {
        return CampaignNode(tier: node.tier, status: NodeStatus.completed);
      } else if (index == currentNode + 1) {
        return CampaignNode(tier: node.tier, status: NodeStatus.current);
      } else {
        return node;
      }
    }).toList();

    return CampaignState(
      currentNode: currentNode + 1,
      nodes: updatedNodes,
      crowned: false,
    );
  }

  CampaignState onDefeat() {
    return this;
  }

  CampaignState restart() {
    return CampaignState.initial();
  }

  Tier getCurrentTier() {
    return nodes[currentNode].tier;
  }
}
