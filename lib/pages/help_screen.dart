import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.deepOrange.shade200,
                Colors.orangeAccent.shade200,
              ],
            )
        ),
        child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.white),
          //foregroundColor: Colors.black,
          elevation: 0),
      body: SingleChildScrollView(
        child: ListBody(
    children: [
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: ListBody(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                    'How it\'s done',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold),)),
            Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.orange.shade50,
                  elevation: 10,
                    child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(padding: EdgeInsets.only(right: 20),
                          child: Text('1', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
                      Expanded(child: Text(
                        'Look at the map presented to you. The cross indicates '
                            'the position of the relevant pedestrian crossing, and '
                            'the blue circle has a radius of 5m.')),
                    ])))),
            Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.orange.shade50,
                    elevation: 10,
                    child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(padding: EdgeInsets.only(right: 20),
                                  child: Text('2', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
                              Expanded(child: Text(
                                  'Put the blue circle on one end of the pedestrian '
                                      'crossing by tapping on the relevant place on the map. Then, '
                                      'repeat with the other end of the pedestrian crossing.')),
                            ])))),
            Center(child: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 80.0,
            )),
            Padding(
                padding: EdgeInsets.only(top: 16, bottom: 24),
                child: Text(
                  'Is the crossing compliant with the law?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,)),
          ],
        )),
      Container(
        decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
        ),
        child: ListBody(
          children: [
            Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(padding: EdgeInsets.only(right: 20),
                        child: FloatingActionButton.extended(
                            heroTag: 100,
                            shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(28.0),
                            ),
                            label: Icon(Icons.check),
                            backgroundColor: Colors.green)),
                    Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text('Yes, all clear',  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                          Text('Tap the green button to show that all is good'),
                        ])),
                  ]),
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(padding: EdgeInsets.only(right: 20),
                        child: FloatingActionButton.extended(
                            heroTag: 101,
                            shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(28.0),
                            ),
                            label: Icon(Icons.help),
                            backgroundColor: Colors.orange)),
                    Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text('Not sure',  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                          Text("If it's impossible to tell, press the orange button."),
                        ])),
                  ]),
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(padding: EdgeInsets.only(right: 20),
                        child: FloatingActionButton.extended(
                          heroTag: 102,
                          shape: ContinuousRectangleBorder(
                            borderRadius: BorderRadius.circular(28.0),
                          ),
                          label: Icon(Icons.warning),
                          backgroundColor: Colors.red,)),
                    Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text('No, parking spaces too close',  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                          Text('Press the red button to show that there are parking spots that were too close to the pedestrian crossing'),
                        ])),
                  ]),
            ),
          ],
        ),
      ),
      ])),
    ));
  }

}