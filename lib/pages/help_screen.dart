import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Safe Crossing help")),
      body: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                    'Look at the map presented to you. The cross indicates '
                        'the position of the relevant pedestrian crossing, and '
                        'the blue circle has a radius of 5m.')),
            Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                    'First, put the blue circle on one end of the pedestrian '
                        'crossing by tapping on the relevant place on the map. Then, '
                        'repeat with the other end of the pedestrian crossing.')),
            Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                    'Did you see parking spots in the 5m radius higlighted '
                        'by the circle on either end of the pedestrian crossing?')),
            Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                    'If no, tap the green button to show that all is good! If '
                        'you did see parking spots that were too close to the pedestrian '
                        'crossing, tap the red button.')),
            Text("If it's impossible to tell, press the orange button.")
          ],
        ),
      ),
    );
  }

}