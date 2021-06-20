import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safe_crossing/util/util.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback helpCallback;
  final VoidCallback streetViewCallback;
  final VoidCallback rewindCallback;
  final VoidCallback toggleCallback;
  final bool canRewind;

  final double percentOk;
  final double percentNotSure;
  final double percentTooClose;
  final double percentTie;
  final double percentPlaceholder;

  ActionButtons(
      {@required this.helpCallback,
      @required this.streetViewCallback,
      @required this.rewindCallback,
      @required this.toggleCallback,
      @required this.canRewind,
      @required this.percentOk,
      @required this.percentNotSure,
      @required this.percentTooClose,
      @required this.percentTie,
      @required this.percentPlaceholder});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
          top: 20,
          right: 20,
          child: Column(
              children: wrapAllWidgetsInPadding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  widgetsToWrap: [
                FloatingActionButton(
                  child: Icon(Icons.help),
                  backgroundColor: Colors.blue,
                  heroTag: 1,
                  onPressed: helpCallback,
                ),
                FloatingActionButton(
                  child: Icon(Icons.streetview),
                  backgroundColor: Colors.green,
                  heroTag: 2,
                  onPressed: streetViewCallback,
                ),
                Visibility(
                    visible: percentPlaceholder < 100,
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: Material(
                          type: MaterialType.circle,
                          color: Colors.blue.withAlpha(1),
                          elevation: 10,
                          child: PieChart(
                            PieChartData(
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                sectionsSpace: 0,
                                centerSpaceRadius: 15,
                                sections: [
                                  PieChartSectionData(
                                    color: Colors.green,
                                    value: percentOk,
                                    showTitle: false,
                                    radius: 10,
                                  ),
                                  PieChartSectionData(
                                    color: Colors.orange,
                                    value: percentNotSure,
                                    showTitle: false,
                                    radius: 10,
                                  ),
                                  PieChartSectionData(
                                    color: Colors.red,
                                    value: percentTooClose,
                                    showTitle: false,
                                    radius: 10,
                                  ),
                                  PieChartSectionData(
                                    color: Colors.white60,
                                    value: percentTie,
                                    radius: 10,
                                    showTitle: false,
                                  ),
                                  PieChartSectionData(
                                    color: const Color(0xff0293ee).withAlpha(1),
                                    value: percentPlaceholder,
                                    radius: 10,
                                    showTitle: false,
                                  ),
                                ]),
                          )),
                    )),
                FloatingActionButton(
                  child: Icon(Icons.satellite),
                  backgroundColor: Colors.purple,
                  heroTag: 4,
                  onPressed: toggleCallback,
                ),
                Visibility(
                    visible: canRewind,
                    child: FloatingActionButton(
                      child: Icon(Icons.undo),
                      backgroundColor: Colors.orange,
                      heroTag: 3,
                      onPressed: rewindCallback,
                    ))
              ])))
    ]);
  }
}
