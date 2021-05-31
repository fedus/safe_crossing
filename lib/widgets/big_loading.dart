import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BigLoading extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Stack(children: [
          Container(
              foregroundDecoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1, -1),
                  end: Alignment(-1, 1),
                  colors: [
                    Colors.transparent,
                    Colors.black54,
                    Colors.transparent
                  ],
                ),
              ),
              child: Image.asset(
                "assets/tokyogifathon04_dribbble.gif",
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.fitHeight,
              )),
          Center(child: Text('Loading', style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
            shadows: <Shadow>[
              Shadow(
                offset: Offset(0, 0),
                blurRadius: 10.0,
                color: Colors.black,
              ),
            ],
          )))
        ]));
  }
}