import 'package:flutter/material.dart';

class Skeleton extends StatefulWidget {
  final double? height;
  final double? width;
  final double borderRadius;
  final BoxShape shape;

  const Skeleton({
    super.key,
    this.height,
    this.width,
    this.borderRadius = 16,
    this.shape = BoxShape.rectangle,
  });

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: Colors.white.withAlpha(20),
      end: Colors.white.withAlpha(50),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            color: _colorAnimation.value,
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.rectangle
                ? BorderRadius.circular(widget.borderRadius)
                : null,
          ),
        );
      },
    );
  }
}

class SkeletonText extends StatelessWidget {
  final double width;
  final double height;
  final int lines;
  final double spacing;

  const SkeletonText({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.lines = 1,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    if (lines == 1) {
      return Skeleton(height: height, width: width, borderRadius: 4);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == lines - 1 ? 0 : spacing),
          child: Skeleton(
            height: height,
            width: index == lines - 1 && lines > 1 ? width * 0.7 : width,
            borderRadius: 4,
          ),
        );
      }),
    );
  }
}

class SkeletonAvatar extends StatelessWidget {
  final double radius;

  const SkeletonAvatar({super.key, this.radius = 48});

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      height: radius * 2,
      width: radius * 2,
      shape: BoxShape.circle,
    );
  }
}
