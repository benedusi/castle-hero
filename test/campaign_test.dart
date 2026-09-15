import 'package:flutter_test/flutter_test.dart';
import 'package:castle_hero/campaign/campaign.dart';
import 'package:castle_hero/campaign/tiers.dart';

void main() {
  group('Campaign Tests', () {
    test('Initial campaign state', () {
      final campaign = CampaignState.initial();

      expect(campaign.currentNode, 0);
      expect(campaign.nodes.length, tiers.length);
      expect(campaign.nodes[0].status, NodeStatus.current);
      expect(campaign.nodes[1].status, NodeStatus.locked);
      expect(campaign.crowned, false);
    });

    test('Victory advances to next node', () {
      var campaign = CampaignState.initial();

      campaign = campaign.onVictory();

      expect(campaign.currentNode, 1);
      expect(campaign.nodes[0].status, NodeStatus.completed);
      expect(campaign.nodes[1].status, NodeStatus.current);
      expect(campaign.nodes[2].status, NodeStatus.locked);
      expect(campaign.crowned, false);
    });

    test('Defeat keeps same node', () {
      var campaign = CampaignState.initial();

      campaign = campaign.onDefeat();

      expect(campaign.currentNode, 0);
      expect(campaign.nodes[0].status, NodeStatus.current);
    });

    test('Victory at final node crowns player', () {
      var campaign = CampaignState.initial();

      for (int i = 0; i < tiers.length; i++) {
        campaign = campaign.onVictory();
      }

      expect(campaign.crowned, true);
      expect(
          campaign.nodes.every((n) => n.status == NodeStatus.completed), true);
    });

    test('Restart resets campaign', () {
      var campaign = CampaignState.initial();

      campaign = campaign.onVictory();
      campaign = campaign.onVictory();

      campaign = campaign.restart();

      expect(campaign.currentNode, 0);
      expect(campaign.nodes[0].status, NodeStatus.current);
      expect(campaign.nodes[1].status, NodeStatus.locked);
      expect(campaign.crowned, false);
    });

    test('Get current tier', () {
      var campaign = CampaignState.initial();

      final tier1 = campaign.getCurrentTier();
      expect(tier1.name, 'The Outpost');

      campaign = campaign.onVictory();

      final tier2 = campaign.getCurrentTier();
      expect(tier2.name, 'The Garrison');
    });

    test('Full campaign progression', () {
      var campaign = CampaignState.initial();

      expect(campaign.getCurrentTier().name, 'The Outpost');
      expect(campaign.crowned, false);

      campaign = campaign.onVictory();
      expect(campaign.getCurrentTier().name, 'The Garrison');
      expect(campaign.crowned, false);

      campaign = campaign.onVictory();
      expect(campaign.getCurrentTier().name, 'The Keep');
      expect(campaign.crowned, false);

      campaign = campaign.onVictory();
      expect(campaign.getCurrentTier().name, 'The Stronghold');
      expect(campaign.crowned, false);

      campaign = campaign.onVictory();
      expect(campaign.getCurrentTier().name, 'The Fortress');
      expect(campaign.crowned, false);

      campaign = campaign.onVictory();
      expect(campaign.crowned, true);
    });
  });
}
