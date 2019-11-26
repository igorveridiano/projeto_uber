import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ubsir_app/bloc/home/bloc_directions_provider.dart';
import 'package:ubsir_app/views/login/login_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      builder: (_) => BlocDirectionsProvider(),
      child: MaterialApp(
        title: 'UBSIR',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Color(0xFF000000),
        ),
        home: LoginPage(),
      ),
    );
  }
}

