import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:safe_crossing/pages/crossings_swiper.dart';
import 'package:safe_crossing/widgets/big_loading.dart';

void main() {
  runApp(SafeCrossingApp());
}

class SafeCrossingApp extends StatefulWidget {
  @override
  _SafeCrossingAppState createState() => _SafeCrossingAppState();
}

class _SafeCrossingAppState extends State<SafeCrossingApp> {

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safe Crossing',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        // Initialize FlutterFire:
        future: _initialization,
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return Scaffold(
                appBar: AppBar(
                  title: Text("Safe Crossing"),
                ),
                body: Center(
                    child: Text("Something went wrong. Please restart the application.")
                )
            );
          }

          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            return CrossingsSwiper();
          }

          return Scaffold(
            body: BigLoading());
          }
      )
    );
  }
}
