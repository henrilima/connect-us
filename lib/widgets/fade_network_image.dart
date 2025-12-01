import 'package:connect/ui/skeletons.dart';
import 'package:flutter/material.dart';

class FadeNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final AlignmentGeometry alignment;
  final Widget? errorWidget;
  final Widget? loadingWidget;

  const FadeNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.errorWidget,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        return Stack(
          fit: StackFit.passthrough,
          alignment: alignment,
          children: [
            loadingWidget ??
                Skeleton(width: width, height: height, borderRadius: 0),
            AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              child: child,
            ),
          ],
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ??
            Container(
              width: width,
              height: height,
              color: Colors.grey.withAlpha(50),
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.grey),
              ),
            );
      },
    );
  }
}
