import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'ui/game_controller.dart';
import 'ui/theme.dart';
import 'ui/screens/campaign_map_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const SiegeApp());
}

class SiegeApp extends StatelessWidget {
  const SiegeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameController(),
      child: MaterialApp(
        title: 'Siege',
        theme: SiegeTheme.darkTheme,
        home: const CampaignMapScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
