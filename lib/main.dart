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
      home: MyHomePage(
        start: 0.0001,
        end: 1,
        n: 1000,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    required this.start,
    required this.end,
    required this.n,
    super.key,
  }) : assert(start < end);

  final double start;
  final double end;
  final int n;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int? _selectedXIndex;
  double x(double t) => t * math.sin(1 / t * 10 * math.pi);
  double y(double t) => t * math.cos(1 / t * 10 * math.pi);

  @override
  Widget build(BuildContext context) {
    final domain = List<double>.generate(widget.n,
        (i) => widget.start + i * (widget.end - widget.start) / (widget.n - 1));

    final values = List.generate(
      widget.n,
      (i) => math.Point<double>(x(domain[i]), y(domain[i])),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Controle deslizante 2D'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(100.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              // onPanStart: (panStart) {
              //   final panStartX = (widget.end - widget.start) *
              //           panStart.localPosition.dx /
              //           constraints.maxWidth +
              //       widget.start;
              //   final diffs = List<MapEntry<int, double>>.generate(
              //     widget.n,
              //     (i) =>
              //         MapEntry<int, double>(i, (domain[i] - panStartX).abs()),
              //   );
              //   diffs.sort((a, b) => a.value.compareTo(b.value));
              //   setState(() => _selectedXIndex = diffs.first.key);
              // },
              onPanUpdate: (panUpdate) {
                final valuesSortedByX = [...values]
                  ..sort((a, b) => a.x.compareTo(b.x));
                final valuesSortedByY = [...values]
                  ..sort((a, b) => a.y.compareTo(b.y));
                print(
                    'O gráfico vai de ${valuesSortedByX.first.x}<=x<=${valuesSortedByX.last.x}'
                    '\n${valuesSortedByY.first.y}<=y<=${valuesSortedByX.last.y}');

                final minX = valuesSortedByX.first.x;
                final maxX = valuesSortedByX.last.x;
                final minY = valuesSortedByY.first.y;
                final maxY = valuesSortedByY.last.y;
                final deltaX = maxX - minX;
                final deltaY = maxY - minY;

                final panStartX =
                    deltaX * panUpdate.localPosition.dx / constraints.maxWidth +
                        minX;

                final panStartY = deltaY *
                        (1 -
                            panUpdate.localPosition.dy /
                                constraints.maxHeight) +
                    minY;

                final diffs = List<MapEntry<int, double>>.generate(
                  widget.n,
                  (i) => MapEntry<int, double>(
                    i,
                    values[i].distanceTo(
                      math.Point<double>(panStartX, panStartY),
                    ),
                  ),
                );

                diffs.sort((a, b) => a.value.compareTo(b.value));
                setState(() => _selectedXIndex = diffs.first.key);
              },
              child: CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: Slider2DPainter(
                  values: [
                    values,
                    // values2, values3,
                  ],
                  selectedXIndex: _selectedXIndex,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class Slider2DPainter extends CustomPainter {
  final List<List<math.Point<double>>> values;
  final int? selectedXIndex;
  const Slider2DPainter({
    required this.values,
    this.selectedXIndex,
  });

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

    Offset _remap(math.Point<double> p) => Offset(
          size.width * (p.x - minX) / deltaX,
          size.height * (1 - (p.y - minY) / deltaY),
        );

    for (int i = 0; i < values.length; i++) {
      canvas.drawPoints(
        PointMode.polygon,
        values[i].map(_remap).toList(),
        paints[i],
      );
      if (selectedXIndex != null) {
        canvas.drawCircle(
            _remap(values[i][selectedXIndex!]), 10, paints[i + 1]);
      }
    }
    // canvas.drawPoints(PointMode.lines, [center, value], paint);
    // canvas.drawPoints(PointMode.points, [value], massPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
