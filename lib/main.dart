import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double parabola(double x) => math.cos(2 * math.pi * x);
  double seno(double x) => math.sin(2 * math.pi * x);
  double parabolaSeno(double x) => parabola(x) * seno(x);

  @override
  Widget build(BuildContext context) {
    double start = 2;
    double end = -2;
    int n = 1000;

    final domain =
        List<double>.generate(n, (i) => start + i * (end - start) / (n - 1));

    final values1 = domain
        .map<math.Point<double>>((x) => math.Point<double>(x, parabola(x)))
        .toList();

    final values2 = domain
        .map<math.Point<double>>((x) => math.Point<double>(x, seno(x)))
        .toList();

    final values3 = domain
        .map<math.Point<double>>((x) => math.Point<double>(x, parabolaSeno(x)))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Controle deslizante 2D'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(100.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: Slider2DPainter(values: [values1, values2, values3]),
            );
          },
        ),
      ),
    );
  }
}

class Slider2DPainter extends CustomPainter {
  final List<List<math.Point<double>>> values;

  const Slider2DPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    final paints = [
      Paint()
        ..color = Colors.red
        ..strokeWidth = 3,
      Paint()
        ..color = Colors.blue
        ..strokeWidth = 3,
      Paint()
        ..color = Colors.green
        ..strokeWidth = 3,
    ];
    // final massPaint = Paint()
    //   ..color = Colors.blue
    //   ..strokeWidth = 10;
    //
    // Tela (canvas)
    // vai de 0 a
    print('Tela vai de 0<=x<=${size.width}'
        '\n0<=y<=${size.height}');
    final concat = values.reduce((value, element) => [...element, ...value]);
    final valuesSortedByX = [...concat]..sort((a, b) => a.x.compareTo(b.x));
    final valuesSortedByY = [...concat]..sort((a, b) => a.y.compareTo(b.y));
    print(
        'O gráfico vai de ${valuesSortedByX.first.x}<=x<=${valuesSortedByX.last.x}'
        '\n${valuesSortedByY.first.y}<=y<=${valuesSortedByX.last.y}');

    final minX = valuesSortedByX.first.x;
    final maxX = valuesSortedByX.last.x;
    final minY = valuesSortedByY.first.y;
    final maxY = valuesSortedByY.last.y;
    final deltaX = maxX - minX;
    final deltaY = maxY - minY;

    TextSpan span = new TextSpan(style: new TextStyle(color: Colors.grey[600]), text: 'Yrfc');



    for (int i = 0; i < values.length; i++) {
      canvas.drawPoints(
        PointMode.polygon,
        values[i]
            .map(
              (p) => Offset(
                size.width * (p.x - minX) / deltaX,
                size.height * (1 - (p.y - minY) / deltaY),
              ),
            )
            .toList(),
        paints[i],
      );
    }
    // canvas.drawPoints(PointMode.lines, [center, value], paint);
    // canvas.drawPoints(PointMode.points, [value], massPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
