import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'core/app_theme.dart';
import 'screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Primary Back4App Endpoint Authentication Access Keys
  const keyApplicationId = 'RnwytUszpQVleHsgRUj4iPRVq6puPjfCdlleQ3oy';
  const keyClientKey = 'KFPqyN9ZvXk3tGe5my1k9aT3B5jnVsOHlVcyi2Nn';
  const keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(
    keyApplicationId,
    keyParseServerUrl,
    clientKey: keyClientKey,
    autoSendSessionId: true,
  );

  runApp(const TaskManagementSuite());
}

class TaskManagementSuite extends StatelessWidget {
  const TaskManagementSuite({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Orchestration Framework',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.modernLightTheme,
      home: const AuthScreen(),
    );
  }
}
