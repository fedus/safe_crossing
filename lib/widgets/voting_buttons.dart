import 'package:flutter/material.dart';

class VotingButtons extends StatelessWidget {
  final VoidCallback okCallback;
  final VoidCallback notSureCallback;
  final VoidCallback tooCloseCallback;

  VotingButtons({
    @required this.okCallback,
    @required this.notSureCallback,
    @required this.tooCloseCallback
  });

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = MediaQuery
        .of(context)
        .size
        .width * 0.3;

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
              width: buttonWidth,
              child: FittedBox(
                  child: FloatingActionButton.extended(
                      shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(28.0),
                      ),
                      label: Icon(Icons.check),
                      backgroundColor: Colors.green,
                      onPressed: okCallback))),
          Container(
              width: buttonWidth,
              child: FittedBox(
                  child: FloatingActionButton.extended(
                      shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(28.0),
                      ),
                      label: Icon(Icons.help),
                      backgroundColor: Colors.orange,
                      onPressed: notSureCallback))),
          Container(
              width: buttonWidth,
              child: FittedBox(
                  child: FloatingActionButton.extended(
                      shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(28.0),
                      ),
                      label: Icon(Icons.warning),
                      backgroundColor: Colors.red,
                      onPressed: tooCloseCallback))),
        ]);
  }
}