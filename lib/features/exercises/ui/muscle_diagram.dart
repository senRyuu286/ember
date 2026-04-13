import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ember/core/theme/app_colors.dart';

class MuscleDiagram extends StatelessWidget {
  const MuscleDiagram({
    super.key,
    required this.primaryMuscleIds,
    required this.secondaryMuscleIds,
    required this.isFront,
    this.height = 280,
  });

  final List<String> primaryMuscleIds;
  final List<String> secondaryMuscleIds;
  final bool isFront;
  final double height;

  static const Color _primaryHighlight = AppColors.primary;
  static const Color _secondaryHighlight = Color(0xFFD19E15);

  String get _assetPath =>
      isFront ? 'assets/body/body_front.svg' : 'assets/body/body_back.svg';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: FutureBuilder<String>(
        future: DefaultAssetBundle.of(context).loadString(_assetPath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 40,
              ),
            );
          }

          final svgString = _applyHighlights(snapshot.data!);
          return SvgPicture.string(svgString, fit: BoxFit.contain);
        },
      ),
    );
  }

  String _applyHighlights(String svgSource) {
    var result = svgSource;

    for (final id in primaryMuscleIds) {
      result = _setFill(result, id, _primaryHighlight);
    }
    for (final id in secondaryMuscleIds) {
      if (!primaryMuscleIds.contains(id)) {
        result = _setFill(result, id, _secondaryHighlight);
      }
    }
    return result;
  }

  String _colorToHex(Color color) {
    return '#'
        '${(color.r * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0')}'
        '${(color.g * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0')}'
        '${(color.b * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0')}';
  }

  String _setFill(String svg, String id, Color color) {
    final hex = _colorToHex(color);

    // Strategy: find the entire opening tag that contains this id,
    // then modify its fill however it is expressed.
    final tagPattern = RegExp(
      r'<(path|rect|circle|ellipse|polygon)[^>]*id="' +
          RegExp.escape(id) +
          r'"[^>]*/?>',
      dotAll: true,
    );

    return svg.replaceAllMapped(tagPattern, (match) {
      var tag = match.group(0)!;

      // Case 1: fill inside style="...fill:COLOR..."
      if (tag.contains('style=')) {
        // Replace fill inside style attribute
        if (RegExp(r'fill\s*:\s*[^;}"]+').hasMatch(tag)) {
          tag = tag.replaceAllMapped(
            RegExp(r'(fill\s*:\s*)([^;}"]+)'),
            (m) => '${m.group(1)}$hex',
          );
        } else {
          // Add fill to existing style attribute
          tag = tag.replaceAllMapped(
            RegExp(r'(style="[^"]*)(")', dotAll: true),
            (m) => '${m.group(1)};fill:$hex${m.group(2)}',
          );
        }
        return tag;
      }

      // Case 2: fill="COLOR" attribute directly on the element
      if (tag.contains('fill=')) {
        return tag.replaceAllMapped(
          RegExp(r'fill="[^"]*"'),
          (_) => 'fill="$hex"',
        );
      }

      // Case 3: no fill attribute at all -- inject before closing > or />
      if (tag.endsWith('/>')) {
        return '${tag.substring(0, tag.length - 2)} fill="$hex"/>';
      }
      return '${tag.substring(0, tag.length - 1)} fill="$hex">';
    });
  }
}