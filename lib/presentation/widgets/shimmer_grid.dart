import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerGrid extends StatelessWidget {
  const ShimmerGrid({super.key});
  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
    highlightColor: Theme.of(context).colorScheme.surface,
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: List.generate(2, (col) => Expanded(
      child: Padding(padding: const EdgeInsets.all(6), child: Column(children: List.generate(3, (i) => Container(
        height: 150 + ((i + col) % 2) * 65, margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18))))))))));
}
