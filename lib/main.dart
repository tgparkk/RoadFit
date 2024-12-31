import 'package:flutter/material.dart';

import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter binding is initialized

  KakaoSdk.init(
    nativeAppKey: '83c5d637b795bf49ea13c7f63dbfc0f0', // Replace with your native app key
    loggingEnabled: true, // Enable SDK logging for debugging
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '경로 비교 앱',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}
