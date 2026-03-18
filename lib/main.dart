import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() => runApp(
  const MaterialApp(debugShowCheckedModeBanner: false, home: VolantePage()),
);

class VolantePage extends StatefulWidget {
  const VolantePage({super.key});
  @override
  State<VolantePage> createState() => _VolantePageState();
}

class _VolantePageState extends State<VolantePage> {
  double _angulo = 0.0;
  double _aceleracion = 0.0;
  double _inclinacionX = 0.0;

  static const double _maxGiro = pi * 1.2;
  static const double _suavizado = 0.15;

  @override
  void initState() {
    super.initState();
    accelerometerEventStream().listen((event) {
      setState(() {
        _inclinacionX += (event.x - _inclinacionX) * _suavizado;
        _aceleracion += (event.y - _aceleracion) * _suavizado;
        _angulo = (_inclinacionX / 10.0).clamp(-1.0, 1.0) * _maxGiro;
      });
    });
  }

  Color get _colorDireccion {
    final abs = _angulo.abs();
    if (abs < 0.3) return Colors.greenAccent;
    if (abs < 0.9) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  String get _etiquetaDireccion {
    if (_angulo < -0.25) return '◀  IZQUIERDA';
    if (_angulo > 0.25) return 'DERECHA  ▶';
    return '▲  RECTO';
  }

  double get _velocidadSimulada {
    return ((-_aceleracion + 10) / 20).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final grados = (_angulo * 180 / pi).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(
              _etiquetaDireccion,
              style: TextStyle(
                color: _colorDireccion,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
              ),
            ),
            Text(
              '$grados°',
              style: const TextStyle(
                color: Colors.white24,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Center(
                child: Transform.rotate(
                  angle: _angulo,
                  child: _Volante(color: _colorDireccion),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ACELERACIÓN',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        '${(_velocidadSimulada * 100).toInt()} %',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _velocidadSimulada,
                      minHeight: 6,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation<Color>(_colorDireccion),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _Volante extends StatelessWidget {
  final Color color;
  const _Volante({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(260, 260),
      painter: _VolantePainter(color: color),
    );
  }
}

class _VolantePainter extends CustomPainter {
  final Color color;
  _VolantePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radio = size.width / 2 - 10;

    final pintura = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final pinturaFondo = Paint()
      ..color = color.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radio, pinturaFondo);
    canvas.drawCircle(center, radio, pintura);
    canvas.drawCircle(center, 22, pintura..strokeWidth = 6);

    final angulos = [pi / 2, pi / 2 + 2 * pi / 3, pi / 2 + 4 * pi / 3];
    for (final a in angulos) {
      canvas.drawLine(
        center + Offset(cos(a) * 22, sin(a) * 22),
        center + Offset(cos(a) * radio, sin(a) * radio),
        pintura..strokeWidth = 7,
      );
    }

    canvas.drawLine(
      center + Offset(0, -(radio - 8)),
      center + Offset(0, -(radio + 8)),
      pintura..strokeWidth = 4,
    );
  }

  @override
  bool shouldRepaint(_VolantePainter old) => old.color != color;
}