import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class CatTax extends StatefulWidget {
  @override
  _CatTaxState createState() => _CatTaxState();
}

class _CatTaxState extends State<CatTax> {
  ConfettiController _controller;

  @override
  void initState() {
    _controller = ConfettiController(duration: const Duration(seconds: 10));
    _controller.play();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Stack(children: [
      Container(
          foregroundDecoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1, -1.5),
              end: Alignment(-1, 0.5),
              colors: [Colors.transparent, Colors.black54, Colors.transparent],
            ),
          ),
          child: Image.asset(
            "assets/cat_tax.jpg",
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          )),
      Positioned(
          top: 80,
          left: 0,
          width: MediaQuery.of(context).size.width - 80,
          height: 200,
          child: Stack(fit: StackFit.expand, children: [
            Center(child: Text.rich(
              TextSpan(
                  text: 'Hooray!\n',
                  style: TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    shadows: <Shadow>[
                      Shadow(
                        offset: Offset(0, 0),
                        blurRadius: 20.0,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  children: [
                    TextSpan(
                        text: 'You did it!\n\n',
                        style: TextStyle(
                          color: Colors.orangeAccent.shade100,
                          fontSize: 40,
                          fontWeight: FontWeight.normal,
                          shadows: <Shadow>[
                            Shadow(
                              offset: Offset(0, 0),
                              blurRadius: 20.0,
                              color: Colors.black,
                            ),
                          ],
                        )),
                    TextSpan(
                        text: "Here's your cat tax.",
                        style: TextStyle(
                          color: Colors.orangeAccent.shade100,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          shadows: <Shadow>[
                            Shadow(
                              offset: Offset(0, 0),
                              blurRadius: 20.0,
                              color: Colors.black,
                            ),
                          ],
                        ))
                  ]),
              textAlign: TextAlign.center,
            )),
            Center(child: ConfettiWidget(
              confettiController: _controller,
              blastDirectionality: BlastDirectionality
                  .explosive, // don't specify a direction, blast randomly
              shouldLoop: true, // start again as soon as the animation is finished
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ], // manually specify the colors to be used
            ))
          ])),
    ]));
  }
}
