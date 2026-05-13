import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// A responsive image widget that handles both local assets and network images
class ResponsiveImage extends StatelessWidget {
  final String? imageUrl;
  final String? assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;

  const ResponsiveImage({
    super.key,
    this.imageUrl,
    this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 8.0,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
  }) : assert(imageUrl != null || assetPath != null, 'Either imageUrl or assetPath must be provided');

  @override
  Widget build(BuildContext context) {
    final imageWidget = imageUrl != null
        ? _buildNetworkImage()
        : _buildAssetImage();

    if (borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius.r),
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildNetworkImage() {
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width?.w,
      height: height?.h,
      fit: fit,
      placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
      errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget(),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),
    );
  }

  Widget _buildAssetImage() {
    return Image.asset(
      assetPath!,
      width: width?.w,
      height: height?.h,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? _buildErrorWidget();
      },
      // loadingBuilder removed - not supported for Image.asset
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width?.w,
      height: height?.h,
      color: backgroundColor ?? Colors.grey[200],
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.w,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width?.w,
      height: height?.h,
      color: backgroundColor ?? Colors.grey[300],
      child: Icon(
        Icons.image_not_supported,
        size: (width != null && width! < height!) ? width! * 0.4 : (height ?? 100) * 0.4,
        color: Colors.grey[600],
      ),
    );
  }
}

