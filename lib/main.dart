import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:teams/splashscreen.dart';
import 'package:intl/intl.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null).then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.delayed(Duration(seconds: 5)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen();
          } else {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Login(),
              theme: ThemeData(),
              builder: EasyLoading.init(),
            );
          }
        });
  }
}
