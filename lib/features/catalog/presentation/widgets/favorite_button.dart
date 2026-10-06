import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Star button that "pops" when tapped: scale 1 → 1.3 → 1 in 300 ms, while
/// its color moves between grey and bordeaux.
///
/// Reusable: the detail screen will use the same widget.
class FavoriteButton extends StatefulWidget {
  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.assetName,
    required this.onPressed,
  });

  final bool isFavorite;

  /// Used in the screen-reader label: "Ajouter Apple aux favoris".
  final String assetName;
  final VoidCallback onPressed;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late ColorTween _color;

  static const _off = AppColors.muted;
  static const _on = AppColors.primary;

  @override
  void initState() {
    super.initState();
    // Starts at the end (value 1): no animation when the list first appears.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1,
    );
    // Two halves of equal weight: grow during 150 ms, shrink during 150 ms.
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.3,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.3,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);
    final color = widget.isFavorite ? _on : _off;
    _color = ColorTween(begin: color, end: color);
  }

  @override
  void didUpdateWidget(FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Animate only when the value really changes (tap, or another screen).
    if (oldWidget.isFavorite != widget.isFavorite) {
      _color = ColorTween(
        begin: oldWidget.isFavorite ? _on : _off,
        end: widget.isFavorite ? _on : _off,
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    // An AnimationController holds a ticker: always free it.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.isFavorite
        ? 'Retirer ${widget.assetName} des favoris'
        : 'Ajouter ${widget.assetName} aux favoris';

    return Semantics(
      // Its own node: otherwise the label merges into the row's label and
      // a screen reader cannot reach the star on its own.
      container: true,
      button: true,
      toggled: widget.isFavorite,
      label: label,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: 48,
        child: InkResponse(
          onTap: widget.onPressed,
          radius: 24,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Transform.scale(
              scale: _scale.value,
              child: Icon(
                widget.isFavorite
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                color: _color.evaluate(_controller),
                size: 26,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
