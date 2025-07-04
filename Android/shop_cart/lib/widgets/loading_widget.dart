import 'package:flutter/material.dart';

enum LoadingType {
  circular,
  dots,
  pulse,
}

class LoadingWidget extends StatefulWidget {
  final LoadingType type;
  final double size;
  final Color? color;
  final String? message;

  const LoadingWidget({
    super.key,
    this.type = LoadingType.circular,
    this.size = 30,
    this.color,
    this.message,
  });

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget loadingWidget;
    final color = widget.color ?? Theme.of(context).primaryColor;

    switch (widget.type) {
      case LoadingType.circular:
        loadingWidget = SizedBox(
          width: widget.size,
          height: widget.size,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        );
        break;
      case LoadingType.dots:
        loadingWidget = _buildDotsLoader(color);
        break;
      case LoadingType.pulse:
        loadingWidget = _buildPulseLoader(color);
        break;
    }

    if (widget.message != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          loadingWidget,
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return loadingWidget;
  }

  Widget _buildDotsLoader(Color color) {
    return SizedBox(
      width: widget.size,
      height: widget.size * 0.3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final delay = index * 0.2;
              final progress = (_animation.value + delay) % 1.0;
              final scale = 0.5 + 0.5 * (1 - (progress - 0.5).abs() * 2);
              
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size * 0.15,
                  height: widget.size * 0.15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.7 + 0.3 * scale),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildPulseLoader(Color color) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final scale = 0.7 + 0.3 * _animation.value;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.3 + 0.7 * (1 - _animation.value)),
            ),
          ),
        );
      },
    );
  }
}
