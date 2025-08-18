import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SvgIcon extends StatelessWidget {
  const SvgIcon(
    this.assetPath, {
    super.key,
    this.color,
    this.height,
    this.width,
    this.size,
    this.alignment,
    this.semanticLabel,
    this.isNetwork = false,
    this.fit,
    this.colorMapper,
  });

  const SvgIcon.network(
    String url, {
    Key? key,
    Color? color,
    double? height,
    double? width,
    double? size,
    Alignment? alignment,
    String? semanticsLabel,
    BoxFit? fit,
    ColorMapper? colorMapper,
  }) : this(
         url,
         key: key,
         color: color,
         height: height,
         width: width,
         size: size,
         alignment: alignment,
         semanticLabel: semanticsLabel,
         isNetwork: true,
         fit: fit,
         colorMapper: colorMapper,
       );

  final String assetPath;
  final String? semanticLabel;
  final Color? color;
  final double? height;
  final double? width;
  final double? size;
  final Alignment? alignment;
  final bool isNetwork;
  final BoxFit? fit;
  final ColorMapper? colorMapper;

  static ColorFilter getSrcInColor(Color color) {
    return ColorFilter.mode(color, BlendMode.srcIn);
  }

  @override
  Widget build(BuildContext context) {
    if (isNetwork) {
      if (assetPath.isEmpty) {
        return SizedBox(height: size ?? height, width: size ?? width);
      }
      return SvgPicture.network(
        assetPath,
        height: size ?? height,
        semanticsLabel: semanticLabel,
        width: size ?? width,
        fit: fit ?? BoxFit.contain,
        alignment: alignment ?? Alignment.center,
        colorFilter: color != null ? getSrcInColor(color!) : null,
        colorMapper: colorMapper,
      );
    }
    return SvgPicture.asset(
      assetPath,
      height: size ?? height,
      semanticsLabel: semanticLabel,
      width: size ?? width,
      alignment: alignment ?? Alignment.center,
      colorFilter: color != null ? getSrcInColor(color!) : null,
      colorMapper: colorMapper,
    );
  }
}
