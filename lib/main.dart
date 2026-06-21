import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simonle/screens/navigation_screen.dart';
import 'package:simonle/services/mqtt_service.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MqttService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SIMONLE',
        theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Inter'),
        home: const NavigationScreen(),
      ),
    );
  }
}
