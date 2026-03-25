import 'package:flutter/material.dart';

/// Shared visual for login → home continuity (Hero animation).
class BrandHeroIcon extends StatelessWidget {
  const BrandHeroIcon({
    super.key,
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'mobilni_brand_icon',
      child: Material(
        color: Colors.transparent,
        child: Icon(
          Icons.layers_rounded,
          size: size,
          color: color,
        ),
      ),
    );
  }
}
