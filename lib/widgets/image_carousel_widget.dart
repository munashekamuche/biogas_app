import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';

class ImageCarouselWidget extends StatefulWidget {
  final double height;
  final List<String> imageUrls;
  final Duration autoSlideInterval;

  const ImageCarouselWidget({
    super.key,
    this.height = 200,
    this.imageUrls = const [],
    this.autoSlideInterval = const Duration(seconds: 4),
  });

  @override
  State<ImageCarouselWidget> createState() => _ImageCarouselWidgetState();
}

class _ImageCarouselWidgetState extends State<ImageCarouselWidget> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentIndex = 0;

  // Default gradient images if no URLs provided
  final List<Gradient> _defaultGradients = [
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF2E7D32), // Green
        Color(0xFF66BB6A),
        Color(0xFF4CAF50),
      ],
    ),
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF1976D2), // Blue
        Color(0xFF42A5F5),
        Color(0xFF2196F3),
      ],
    ),
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFF6F00), // Orange
        Color(0xFFFFB74D),
        Color(0xFFFF9800),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(widget.autoSlideInterval, (timer) {
      if (_pageController.hasClients) {
        final nextIndex = (_currentIndex + 1) % _getItemCount();
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  int _getItemCount() {
    return widget.imageUrls.isNotEmpty
        ? widget.imageUrls.length
        : _defaultGradients.length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height.h,
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          children: [
            // Image Carousel
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: _getItemCount(),
              itemBuilder: (context, index) {
                return _buildCarouselItem(index);
              },
            ),
            
            // Glassy Effect Overlay
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Page Indicators
            Positioned(
              bottom: 16.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _getItemCount(),
                  (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: _currentIndex == index ? 24.w : 8.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselItem(int index) {
    if (widget.imageUrls.isNotEmpty && index < widget.imageUrls.length) {
      // Use network image if URLs provided
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(widget.imageUrls[index]),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      // Use local images for Grid, Solar, and Biogas
      final imagePaths = [
        'assets/images/biogas.png',      // Index 0: Biogas
        'assets/images/grid_solar.png',  // Index 1: Solar (using grid_solar for now)
        'assets/images/grid_solar.png',  // Index 2: Grid (using grid_solar)
      ];
      
      final imageIndex = index % imagePaths.length;
      final imagePath = imagePaths[imageIndex];
      
      return Container(
        decoration: BoxDecoration(
          gradient: _defaultGradients[imageIndex],
        ),
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to gradient if image fails to load
                  return Container(
                    decoration: BoxDecoration(
                      gradient: _defaultGradients[imageIndex],
                    ),
                    child: CustomPaint(
                      painter: _PatternPainter(),
                    ),
                  );
                },
              ),
            ),
            // Overlay for better text readability
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getIconForIndex(imageIndex),
                    size: 64.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    _getTitleForIndex(imageIndex),
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    _getSubtitleForIndex(imageIndex),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withOpacity(0.9),
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.eco;
      case 1:
        return Icons.solar_power;
      case 2:
        return Icons.bolt;
      default:
        return Icons.energy_savings_leaf;
    }
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Biogas Solutions';
      case 1:
        return 'Solar Power';
      case 2:
        return 'Grid Connection';
      default:
        return 'Energy Services';
    }
  }

  String _getSubtitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Sustainable Energy for Your Home';
      case 1:
        return 'Harness the Power of the Sun';
      case 2:
        return 'Reliable Grid Connectivity';
      default:
        return 'Your Energy Partner';
    }
  }
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw diagonal lines
    for (double i = 0; i < size.width + size.height; i += 30) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i - size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

