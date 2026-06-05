import 'package:flutter/material.dart';
import 'package:gym_member_app/src/features/buy/widgets/product_image_placeholder.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.inStock,
    this.compact = false,
  });

  final String? imageUrl;
  final String name;
  final bool inStock;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: compact ? null : 100,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null)
            Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return ProductImagePlaceholder(
                  colorScheme: colorScheme,
                  showProgress: true,
                  progress: progress.expectedTotalBytes == null
                      ? null
                      : progress.cumulativeBytesLoaded / progress.expectedTotalBytes!,
                );
              },
              errorBuilder: (_, _, _) => ProductImagePlaceholder(
                colorScheme: colorScheme,
                label: name,
              ),
            )
          else
            ProductImagePlaceholder(colorScheme: colorScheme, label: name),
          if (!inStock)
            Container(
              color: Colors.black.withValues(alpha: 0.35),
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'OUT OF STOCK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.18),
                  ],
                ),
              ),
              child: const SizedBox(height: 28),
            ),
          ),
        ],
      ),
    );
  }
}
