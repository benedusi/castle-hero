import 'package:flutter/foundation.dart';
import '../engine/engine.dart';
import '../engine/game_state.dart';
import '../engine/move.dart';
import '../engine/ai.dart';
import '../campaign/campaign.dart';

class GameController extends ChangeNotifier {
  CampaignState _campaign = CampaignState.initial();
  GameState? _battleState;
  bool _isAiThinking = false;

  CampaignState get campaign => _campaign;
  GameState? get battleState => _battleState;
  bool get isInBattle => _battleState != null;
  bool get isAiThinking => _isAiThinking;

  void startBattle() {
    final tier = _campaign.getCurrentTier();
    _battleState = createInitialState(
      hp: tier.hp,
      defenderConfig: tier.defenderConfig,
      aiConfig: tier.aiConfig,
    );
    _battleState = startPlayerTurn(_battleState!, firstTurn: true);
    notifyListeners();
  }

  void exitBattle() {
    _battleState = null;
    notifyListeners();
  }

  Future<void> playCard(int handIndex) async {
    if (_battleState == null || _battleState!.phase != Phase.player) return;
    if (_isAiThinking) return;

    final card = _battleState!.attacker.hand[handIndex];
    final move = PlayAttackerCard(card: card, handIndex: handIndex);
    _applyPlayerMove(move);
  }

  Future<void> discardCard(int handIndex) async {
    if (_battleState == null || _battleState!.phase != Phase.player) return;
    if (_isAiThinking) return;

    final move = DiscardAttackerCard(handIndex: handIndex);
    _applyPlayerMove(move);
  }

  void _applyPlayerMove(Move move) async {
    _battleState = applyMove(_battleState!, move);
    notifyListeners();

    if (_battleState!.phase == Phase.over) {
      _handleBattleEnd();
      return;
    }

    if (_battleState!.phase == Phase.ai) {
      await _runAiTurn();
    }
  }

  Future<void> _runAiTurn() async {
    _isAiThinking = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    if (_battleState == null || _battleState!.phase != Phase.ai) {
      _isAiThinking = false;
      notifyListeners();
      return;
    }

    final aiMove = chooseDefenderMove(_battleState!);
    _battleState = applyMove(_battleState!, aiMove);

    _isAiThinking = false;
    notifyListeners();

    if (_battleState!.phase == Phase.over) {
      _handleBattleEnd();
    }
  }

  void _handleBattleEnd() {
    final won = _battleState!.defender.wall <= 0;

    if (won) {
      _campaign = _campaign.onVictory();
    } else {
      _campaign = _campaign.onDefeat();
    }
  }

  void restartCampaign() {
    _campaign = CampaignState.initial();
    _battleState = null;
    notifyListeners();
  }

  bool didPlayerWin() {
    if (_battleState == null || _battleState!.phase != Phase.over) {
      return false;
    }
    return _battleState!.defender.wall <= 0;
  }

  bool isCrowned() {
    return _campaign.crowned;
  }
}
