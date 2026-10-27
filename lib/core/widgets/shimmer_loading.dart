import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Reusable Shimmer container that animates a moving highlight gradient.
class ShimmerLoading extends StatefulWidget {
  final Widget child;

  const ShimmerLoading({super.key, required this.child});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1200));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final double value = _shimmerController.value;
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                AppColors.shimmerBase,
                AppColors.shimmerHighlight,
                AppColors.shimmerBase,
              ],
              stops: const [0.1, 0.5, 0.9],
              transform: _SlidingGradientTransform(slidePercent: value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

/// A basic placeholder box with shimmer coloring
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.shimmerBase,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Shimmer placeholder matching the exact layout of a VisitorCard
class VisitorCardShimmer extends StatelessWidget {
  const VisitorCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar circle
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.shimmerBase,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),

          // Visitor info lines
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                ShimmerBox(width: 140, height: 14),
                SizedBox(height: 6),
                ShimmerBox(width: 90, height: 11),
                SizedBox(height: 6),
                ShimmerBox(width: 120, height: 10),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Status chip placeholder
          const ShimmerBox(width: 70, height: 24, borderRadius: 12),
        ],
      ),
    );
  }
}

/// A list of multiple visitor card shimmer items
class VisitorListShimmer extends StatelessWidget {
  final int itemCount;

  const VisitorListShimmer({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) => const VisitorCardShimmer(),
      ),
    );
  }
}

/// Shimmer for Dashboard stat cards
class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerBox(width: 130, height: 36, borderRadius: 10),
            const SizedBox(height: 16),
            Row(
              children: const [
                Expanded(child: ShimmerBox(height: 125, borderRadius: 12)),
                SizedBox(width: 10),
                Expanded(child: ShimmerBox(height: 125, borderRadius: 12)),
                SizedBox(width: 10),
                Expanded(child: ShimmerBox(height: 125, borderRadius: 12)),
              ],
            ),
            const SizedBox(height: 28),
            const ShimmerBox(width: 110, height: 20),
            const SizedBox(height: 14),
            Row(
              children: const [
                Expanded(child: ShimmerBox(height: 120, borderRadius: 12)),
                SizedBox(width: 12),
                Expanded(child: ShimmerBox(height: 120, borderRadius: 12)),
                SizedBox(width: 12),
                Expanded(child: ShimmerBox(height: 120, borderRadius: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
