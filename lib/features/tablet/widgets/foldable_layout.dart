import 'dart:ui';
import 'package:flutter/material.dart';

class FoldableAdaptiveLayout extends StatelessWidget {
  final Widget leftChild;
  final Widget rightChild;
  final Widget? singleScreenChild;

  const FoldableAdaptiveLayout({
    super.key,
    required this.leftChild,
    required this.rightChild,
    this.singleScreenChild,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final displayFeatures = mediaQuery.displayFeatures;
    
    // Check for fold or hinge
    final hinge = _getHinge(displayFeatures);
    
    if (hinge == null) {
      // Not a foldable or not folded
      return singleScreenChild ?? Row(
        children: [
          Expanded(child: leftChild),
          Expanded(child: rightChild),
        ],
      );
    }

    // Hinge-aware layout
    return Row(
      children: [
        SizedBox(
          width: hinge.bounds.left,
          child: leftChild,
        ),
        SizedBox(width: hinge.bounds.width), // The gap for the hinge
        Expanded(
          child: rightChild,
        ),
      ],
    );
  }

  DisplayFeature? _getHinge(List<DisplayFeature> displayFeatures) {
    for (final feature in displayFeatures) {
      if (feature.type == DisplayFeatureType.hinge || 
          feature.type == DisplayFeatureType.fold) {
        return feature;
      }
    }
    return null;
  }
}
