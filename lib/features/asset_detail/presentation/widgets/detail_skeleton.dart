import 'package:flutter/material.dart';

import '../../../catalog/presentation/widgets/skeleton_box.dart';

/// Grey blocks shaped like the detail screen, shown while the local
/// database answers or while a first download is running.
class DetailSkeleton extends StatelessWidget {
  const DetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Chargement de la fiche',
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: const [
          Row(
            children: [
              SkeletonBox(width: 40, height: 40, radius: 14),
              SizedBox(width: 12),
              SkeletonBox(width: 180, height: 26),
            ],
          ),
          SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: SkeletonBox(width: 240, height: 14),
          ),
          SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: SkeletonBox(width: 200, height: 40, radius: 10),
          ),
          SizedBox(height: 16),
          SkeletonBox(width: double.infinity, height: 56, radius: 14),
          SizedBox(height: 12),
          SkeletonBox(width: double.infinity, height: 230, radius: 24),
          SizedBox(height: 12),
          SkeletonBox(width: double.infinity, height: 220, radius: 24),
        ],
      ),
    );
  }
}
