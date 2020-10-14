import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:music/pages/Walkthrough.dart';
import 'package:music/sc_model/model.dart';
import 'package:scoped_model/scoped_model.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (brightness) =>
        new ThemeData(
          primarySwatch: Colors.deepOrange,
          accentColor: Colors.deepOrangeAccent,
          fontFamily: 'Bitter',
          brightness: brightness,
        ),
        themedWidgetBuilder: (context, theme) {
          return ScopedModel<SongModel>(
            model: new SongModel(),
            child: new MaterialApp(
              title: 'Music Player',
              theme: theme,
              debugShowCheckedModeBanner: false,
              home: new SplashScreen(),
            ),
          );
        });
  }
}
