import 'package:flutter/material.dart';
import 'package:safe_crossing/widgets/fade_on_scroll.dart';

class HelpScreen extends StatelessWidget {
  static ScrollController scrollController = new ScrollController();

  SingleChildScrollView mainContent = SingleChildScrollView(
      controller: scrollController,
      child: ListBody(
          children: [
            Card(
              margin: EdgeInsets.zero,
              elevation: 20,
                color: Colors.orange.shade200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                ),
                child: SafeArea(child: Padding(padding: EdgeInsets.all(16), child: ListBody(
                  children: [
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
                            elevation: 0,
                            child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Padding(padding: EdgeInsets.only(right: 20),
                                          child: Text('1', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
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
                            elevation: 0,
                            child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Padding(padding: EdgeInsets.only(right: 20),
                                          child: Text('2', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
                                      Expanded(child: Text(
                                          'Put the blue circle on one end of the pedestrian '
                                              'crossing by tapping on the relevant place on the map. Then, '
                                              'repeat with the other end of the pedestrian crossing.')),
                                    ])))),
                  ],
                )))),
            Padding(
                padding: EdgeInsets.all(16),
                child: ListBody(
                  children: <Widget>[
                    Center(child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 80.0,
                    )),
                    Padding(
                        padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                        child: Text(
                          'Is the crossing compliant with the law?',
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,)),
                  ],
                )),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 40),
                child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.orange.shade50,
              elevation: 10,
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
            )),
            Text("Crossing data: (c) OpenStreetMaps", textAlign: TextAlign.center),
            Text("Aerial imagery: (c) Geoportail", textAlign: TextAlign.center),
            Padding(padding: EdgeInsets.only(bottom: 24), child: Text("Aerial imagery: (c) Ville de Luxembourg", textAlign: TextAlign.center)),
            Padding(padding: EdgeInsets.only(bottom: 24), child: Text("A project by the Center for Urban Justice", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
          ]));

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            //Colors.black,
            Colors.orangeAccent,
            Colors.orangeAccent,
            Colors.deepOrange.shade100
          ],
        )),
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(children: [
              mainContent,
              Positioned(
                  top: 10,
                  left: 20,
                  child: SafeArea(child: FadeOnScroll(
                    scrollController: scrollController,
                    fullOpacityOffset: 0,
                    zeroOpacityOffset: 10,
                    child: BackButton(),
                  ))),
            ])));
  }
}