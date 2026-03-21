import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';

/// Shimmer effect wrapper for loading states
class ShimmerWrapper extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerWrapper({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? AppTheme.border.withValues(alpha: 0.5),
      highlightColor: highlightColor ?? AppTheme.surfaceHover,
      child: child,
    );
  }
}

/// Basic skeleton box for shimmer effects
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final bool isCircle;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.isCircle = false,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.border,
        borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }
}

/// Skeleton card for feed posts with shimmer animation
class ShimmerPostCard extends StatelessWidget {
  const ShimmerPostCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author row skeleton
            Row(
              children: [
                const SkeletonBox(width: 40, height: 40, isCircle: true),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonBox(width: 100, height: 12),
                    SizedBox(height: 4),
                    SkeletonBox(width: 60, height: 10),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Content skeleton
            const SkeletonBox(width: double.infinity, height: 14),
            const SizedBox(height: 8),
            const SkeletonBox(width: 250, height: 14),
            const SizedBox(height: 8),
            const SkeletonBox(width: 180, height: 14),
            const SizedBox(height: 16),
            // Actions row skeleton
            Row(
              children: const [
                SkeletonBox(width: 60, height: 24),
                SizedBox(width: 16),
                SkeletonBox(width: 60, height: 24),
                Spacer(),
                SkeletonBox(width: 24, height: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton card for bot grid items with shimmer animation
class ShimmerBotGridCard extends StatelessWidget {
  const ShimmerBotGridCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SkeletonBox(width: 60, height: 60, isCircle: true),
            SizedBox(height: 12),
            SkeletonBox(width: 80, height: 14),
            SizedBox(height: 6),
            SkeletonBox(width: 50, height: 10),
            SizedBox(height: 8),
            SkeletonBox(width: 100, height: 24, borderRadius: 12),
          ],
        ),
      ),
    );
  }
}

/// Skeleton card for bot list items with shimmer animation
class ShimmerBotListCard extends StatelessWidget {
  const ShimmerBotListCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            const SkeletonBox(width: 50, height: 50, isCircle: true),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: 120, height: 14),
                  SizedBox(height: 6),
                  SkeletonBox(width: 80, height: 10),
                  SizedBox(height: 6),
                  SkeletonBox(width: double.infinity, height: 10),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const SkeletonBox(width: 70, height: 32, borderRadius: 16),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for chat messages with shimmer animation
class ShimmerChatMessage extends StatelessWidget {
  final bool isRight;

  const ShimmerChatMessage({
    super.key,
    this.isRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          mainAxisAlignment: isRight ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isRight) ...[
              const SkeletonBox(width: 32, height: 32, isCircle: true),
              const SizedBox(width: 8),
            ],
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.65,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isRight ? AppTheme.semanticBlue.withValues(alpha: 0.2) : AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isRight)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: SkeletonBox(width: 60, height: 10),
                    ),
                  SkeletonBox(width: isRight ? 100 : 150, height: 12),
                  const SizedBox(height: 6),
                  SkeletonBox(width: isRight ? 80 : 120, height: 12),
                ],
              ),
            ),
            if (isRight) ...[
              const SizedBox(width: 8),
              const SkeletonBox(width: 32, height: 32, isCircle: true),
            ],
          ],
        ),
      ),
    );
  }
}

/// Skeleton for notification items with shimmer animation
class ShimmerNotificationItem extends StatelessWidget {
  const ShimmerNotificationItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            const SkeletonBox(width: 44, height: 44, isCircle: true),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: double.infinity, height: 12),
                  SizedBox(height: 6),
                  SkeletonBox(width: 150, height: 10),
                  SizedBox(height: 6),
                  SkeletonBox(width: 80, height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for comment items with shimmer animation
class ShimmerCommentItem extends StatelessWidget {
  const ShimmerCommentItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(width: 36, height: 36, isCircle: true),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: 100, height: 12),
                  SizedBox(height: 6),
                  SkeletonBox(width: double.infinity, height: 10),
                  SizedBox(height: 4),
                  SkeletonBox(width: 180, height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for DM conversation items with shimmer animation
class ShimmerConversationItem extends StatelessWidget {
  const ShimmerConversationItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const SkeletonBox(width: 50, height: 50, isCircle: true),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: 120, height: 14),
                  SizedBox(height: 6),
                  SkeletonBox(width: double.infinity, height: 10),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                SkeletonBox(width: 40, height: 10),
                SizedBox(height: 6),
                SkeletonBox(width: 20, height: 20, isCircle: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for bot profile with shimmer animation
class ShimmerBotProfile extends StatelessWidget {
  const ShimmerBotProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header area
            Container(
              height: 200,
              color: AppTheme.surface,
            ),
            const SizedBox(height: 16),
            // Avatar
            Transform.translate(
              offset: const Offset(0, -50),
              child: const SkeletonBox(width: 100, height: 100, isCircle: true),
            ),
            // Name and handle
            Column(
              children: const [
                SkeletonBox(width: 150, height: 20),
                SizedBox(height: 8),
                SkeletonBox(width: 100, height: 14),
                SizedBox(height: 16),
                // Bio
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      SkeletonBox(width: double.infinity, height: 12),
                      SizedBox(height: 6),
                      SkeletonBox(width: 250, height: 12),
                      SizedBox(height: 6),
                      SkeletonBox(width: 200, height: 12),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SkeletonBox(width: 60, height: 40),
                    SizedBox(width: 32),
                    SkeletonBox(width: 60, height: 40),
                    SizedBox(width: 32),
                    SkeletonBox(width: 60, height: 40),
                  ],
                ),
                SizedBox(height: 24),
                // Action buttons
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(child: SkeletonBox(width: double.infinity, height: 44, borderRadius: 12)),
                      SizedBox(width: 12),
                      Expanded(child: SkeletonBox(width: double.infinity, height: 44, borderRadius: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
