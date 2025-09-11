import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// A widget that provides hover effects on web/desktop and tap feedback on mobile.
///
/// This widget automatically detects the platform and uses the appropriate
/// interaction method:
/// - MouseRegion for web/desktop platforms
/// - GestureDetector for mobile platforms
class HoverWidget extends StatefulWidget {
  final Widget Function(bool isHovered) builder;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enableFeedback;

  const HoverWidget({
    super.key,
    required this.builder,
    this.onTap,
    this.onLongPress,
    this.enableFeedback = true,
  });

  @override
  _HoverWidgetState createState() => _HoverWidgetState();
}

class _HoverWidgetState extends State<HoverWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // On web/desktop, use MouseRegion for hover effects
    if (kIsWeb || Theme.of(context).platform == TargetPlatform.macOS) {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          behavior: HitTestBehavior.opaque,
          child: widget.builder(_isHovered),
        ),
      );
    }

    // On mobile, use GestureDetector for tap feedback
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      behavior: HitTestBehavior.opaque,
      child: widget.builder(_isHovered),
    );
  }
}
