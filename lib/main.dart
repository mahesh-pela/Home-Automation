import 'package:flutter/material.dart'
    show BuildContext, MaterialApp, StatelessWidget, Widget, runApp;
import 'package:home_automation/SelecionarDispositivoPage.dart';
import 'package:home_automation/main.dart';
import 'package:provider/provider.dart';
import 'package:home_automation/provider/status.dart';

import 'HomePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<StatusConexaoProvider>.value(
              value: StatusConexaoProvider()),
        ],
        child: MaterialApp(
          title: 'Xerocasa',
          initialRoute: '/',
          routes: {
            '/': (context) => HomePage(),
            '/selectDevice': (context) => const SelecionarDispositivoPage(),
          },
        ));
  }
}