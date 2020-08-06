import 'dart:ui' as ui; // textstyle in dart ui package is different

import 'package:flutter/material.dart';

// Label1 will be on top position and label1 below. For scroll behaviour we will push label 2 down and label1 down abd vice versa
class TextScrollWidget extends StatefulWidget {
  @override
  _TextScrollWidgetState createState() => _TextScrollWidgetState();
}

class _TextScrollWidgetState extends State<TextScrollWidget>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  String _label1 = "Rajeev";
  String _label2 = "Jaiswal";
  final Curve _animationCurve = Interval(0.3, 0.7, curve: Curves.easeInOut);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('TextScroll Workshop'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              "Achieved using Custom Paint",
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
          ),
          SizedBox(
            height: 16,
          ),
          CustomPaint(
            size: Size(double.infinity,
                30), // setting height to 30 . this is the same distance between label 2 and label1
            painter: TextScrollPainter(
              label1: _label1,
              label2: _label2,
              textColor: Colors.yellow,
              fontSize: 24,
              scrollPosition:
                  _animationCurve.transform(_animationController.value),
            ),
          ),
          SizedBox(
            height: 32,
          ),
          Center(
            child: Text(
              "Achieved using shaderMask widget",
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
          ),
          SizedBox(
            height: 16,
          ),
          ClipRect(
            child: ShaderMask(
              shaderCallback: (Rect availableSpace) {
                return LinearGradient(
                    colors: [
                      Colors.yellow.withOpacity(0.0),
                      Colors.yellow,
                      Colors.yellow,
                      Colors.yellow.withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.05, 0.3, 0.7, 0.95]).createShader(availableSpace);
              },
              child: Container(
                height: 30,
                width: double.infinity,
                child: Stack(
                  children: <Widget>[
                    FractionalTranslation(
                      translation: Offset(
                          0.0,
                          _animationCurve
                                  .transform(_animationController.value) -
                              1.0),
                      child: Center(
                        child: Text(
                          _label2,
                          style: TextStyle(color: Colors.yellow, fontSize: 24),
                        ),
                      ),
                    ),
                    FractionalTranslation(
                      translation: Offset(
                          0.0,
                          _animationCurve
                              .transform(_animationController.value)),
                      child: Center(
                        child: Text(
                          _label1,
                          style: TextStyle(color: Colors.yellow, fontSize: 24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _switchLabels() {
    if (_label1 == "Rajeev") {
      _label1 = "Jaiswal";
      _label2 = "Rajeev";
    } else {
      _label1 = "Rajeev";
      _label2 = "Jaiswal";
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )
      ..addListener(() {
        setState(() {}); // update ui
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _switchLabels();
          _animationController.forward(from: 0.0); // repeat
        }
      })
      ..forward(); // start immediately
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class TextScrollPainter extends CustomPainter {
  TextScrollPainter(
      {@required this.label1,
      @required this.label2,
      @required Color textColor,
      this.fontSize = 14,
      this.scrollPosition = 0.0})
      : fadeGradient = LinearGradient(
            colors: [
              textColor.withOpacity(0.0),
              textColor,
              textColor,
              textColor.withOpacity(0.0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.05, 0.3, 0.7, 0.95]);

  final String label1;
  final String label2;
  final double fontSize;
  final double scrollPosition;
  final LinearGradient fadeGradient;

  @override
  void paint(Canvas canvas, Size size) {
    print("scroll position $scrollPosition");

    Shader fadeShader =
        fadeGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    Paint fadePaint = Paint()..shader = fadeShader;
    final ui.Paragraph paragraph1 = _buildParagraph(label1, size, fadePaint);
    // centre the text vertically => (size.height - lineHeight) / 2) => this value is good for initial position
    final lineHeight = paragraph1.height;
    final Offset label1Position = Offset(
        0, ((size.height - lineHeight) / 2) + (size.height * scrollPosition));
    canvas.drawParagraph(paragraph1, label1Position);

    final ui.Paragraph paragraph2 = _buildParagraph(label2, size, fadePaint);
    final Offset label2Position = label1Position.translate(0, -size.height);
    canvas.drawParagraph(paragraph2, label2Position);
  }

  ui.Paragraph _buildParagraph(String label, Size availableSpace, Paint paint) {
    final ui.ParagraphBuilder paragraphBuilder =
        ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: TextAlign.center,
      maxLines: 1,
    ))
          ..pushStyle(ui.TextStyle(foreground: paint, fontSize: fontSize))
          ..addText(label);

    // build the paragraph
    // paragraph constraints to take max width
    final ui.Paragraph paragraph = paragraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: availableSpace.width));
    return paragraph;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
