import 'package:flatpak_manager/networking.dart';
import 'package:flutter/material.dart';

import 'package:window_size/window_size.dart';

void main() {
  runApp(const FlatpakManager());
}

class FlatpakManager extends StatelessWidget {
  const FlatpakManager({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    setWindowTitle("Flathub Manager");
    setWindowMinSize(Size(800, 600));
    return MaterialApp(
      title: "Flathub Desktop",
      theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(
              primarySwatch: const MaterialColor(
        0xff4a86cf, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
        const <int, Color>{
          50: const Color(0xff4379ba), //10%
          100: const Color(0xff3b6ba6), //20%
          200: const Color(0xff345e91), //30%
          300: const Color(0xff2c507c), //40%
          400: const Color(0xff254368), //50%
          500: const Color(0xff1e3653), //60%
          600: const Color(0xff16283e), //70%
          700: const Color(0xff0f1b29), //80%
          800: const Color(0xff070d15), //90%
          900: const Color(0xff000000), //100%
        },
      ))),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            // bottom: const TabBar(
            //   tabs: [
            //     Tab(icon: Icon(Icons.download)),
            //     Tab(icon: Icon(Icons.check)),
            //   ],
            // ),
            title: const Text('Flathub Desktop'),
            leading: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Image(
                image: AssetImage('assets/images/flathub_logo.png'),
              ),
            ),
          ),
          // body: TabBarView(
          //   children: [
          //     AllFlatpaksView(false),
          //     AllFlatpaksView(true),
          //   ],
          // ),
          body: AllFlatpaksView(false),
        ),
      ),
    );
  }
}
