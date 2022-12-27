import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pizzapp/model/pizza.dart';
import 'package:pizzapp/model/preset.dart';
import 'package:pizzapp/services/pizza_service.dart';

class PizzaView extends StatelessWidget {
  const PizzaView({
    required this.sections,
    required this.slices,
    super.key,
  });

  final List<PizzaSection> sections;
  final int slices;

  Widget _perspective(Widget input, double rotateZ) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.fromList([
        1.0, 0.0, 0.0, 0.0,
        0.0, 0.8, 0.0, -0.001,
        0.0, 0.0, 1.0, 0.0,
        0.0, -18.0, 0.0, 1.0,
      ])..rotateZ(rotateZ),
      child: input,
    );
  }

  Widget _sections() {
    final widgets = <Widget>[];

    int offset = 0;
    // compute offsets
    for (var section in sections) {
      section.offset = offset;
      offset += section.pieces;
    }

    for (var section in sections) {
      widgets.add(
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween(begin: 0.0, end: section.pieces.toDouble()),
          curve: Curves.easeInOutCubicEmphasized,
          builder: (_, x, __) {
            return TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: section.offset.toDouble()),
              curve: Curves.easeInOutCubicEmphasized,
              builder: (_, y, __) {
                return ClipPath(
                  clipper: _PizzaSliceClipper(slices, y, x + y),
                  child: Image.asset('assets/flavors/${section.flavor.imagem}'),
                );
              },
            );
          },
        ),
      );
    }
    return Stack(children: widgets);
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeInOutCubicEmphasized,
      duration: const Duration(milliseconds: 1200),
      builder: (_, value, child) {
        final rot = (1.0 - value) * pi * 2.5;
        return Opacity(
          opacity: value,
          child: Stack(
            children: [
              // shadow
              ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0, tileMode: TileMode.decal),
                child: Transform.translate(
                  offset: const Offset(0.0, 20.0),
                  child: _perspective(Image.asset('assets/pizza_base.png', color: Colors.black45), rot),
                ),
              ),
        
              // base
              Transform.translate(
                offset: Offset(0.0, -80.0 * (1.0 - value)),
                child: _perspective(Image.asset('assets/pizza_base.png'), rot),
              ),
        
              // fatias
              RepaintBoundary(
                child: Transform.translate(
                  offset: Offset(0.0, -80.0 * (1.0 - value)),
                  child: _perspective(_sections(), rot),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PizzaViewSimple extends StatelessWidget {
  const PizzaViewSimple({
    required this.sections,
    required this.slices,
    super.key,
  });

  final List<PizzaSection> sections;
  final int slices;

  Widget _sections() {
    final widgets = <Widget>[];
    int offset = 0;
    for (var section in sections) {
      widgets.add(ClipPath(
        clipper: _PizzaSliceClipper(slices, offset.toDouble(), section.pieces.toDouble()),
        child: Image.asset('assets/flavors/${section.flavor.imagem}'),
      ));
      offset += section.pieces;
    }
    return Stack(children: widgets);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // base
        Image.asset('assets/pizza_base.png'),
  
        // fatias
        _sections(),
      ],
    );
  }
}

class PizzaViewSimpleAsync extends StatelessWidget {
  const PizzaViewSimpleAsync({
    required this.sections,
    required this.slices,
    super.key,
  });

  final List<PresetSabor> sections;
  final int slices;

  Widget _sections() {
    final widgets = <Widget>[];
    int offset = 0;
    for (var section in sections) {
      widgets.add(ClipPath(
        clipper: _PizzaSliceClipper(slices, offset.toDouble(), (offset + section.fatias).toDouble()),
        child: FutureBuilder<Pizza?>(
          future: PizzaService.getPizza(section.id),
          builder: (_, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return Container();
            }
            final pizza = snap.data!;
            return Image.asset('assets/flavors/${pizza.imagem}');
          },
        ),
      ));
      offset += section.fatias;
    }
    return Stack(children: widgets);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // base
        Image.asset('assets/pizza_base.png'),
  
        // fatias
        _sections(),
      ],
    );
  }
}

class PizzaViewSimpleSingleFlavor extends StatelessWidget {
  const PizzaViewSimpleSingleFlavor({
    required this.flavor,
    super.key,
  });

  final Pizza flavor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // base
        Image.asset('assets/pizza_base.png'),
  
        // fatias
        Image.asset('assets/flavors/${flavor.imagem}'),
      ],
    );
  }
}

class _PizzaSliceClipper extends CustomClipper<Path> {

  final int maxSlices;
  final double startSlice, endSlice;

  _PizzaSliceClipper(this.maxSlices, this.startSlice, this.endSlice);

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final path = Path();

    final sliceSizeAngle = (pi * 2) / maxSlices;
    final from = startSlice * sliceSizeAngle - pi / 2;
    final to = ((endSlice - startSlice) * sliceSizeAngle);

    path.moveTo(center.dx, center.dy);
    path.arcTo(
      Rect.fromLTWH(0, 0, size.width, size.height),
      from,
      to - 1e-7,
      false,
    );
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
