// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/ui/elements/custom_flutter_logo.dart';

//import 'colors.dart';

/// The Flutter logo, in widget form. This widget respects the [IconTheme].
/// For guidelines on using the Flutter logo, visit https://flutter.dev/brand.
///
/// See also:
///
///  * [IconTheme], which provides ambient configuration for icons.
///  * [Icon], for showing icons the Material design icon library.
///  * [ImageIcon], for showing icons from [AssetImage]s or other [ImageProvider]s.
class FlutterLogoX extends StatelessWidget {
  /// Creates a widget that paints the Flutter logo.
  ///
  /// The [size] defaults to the value given by the current [IconTheme].
  const FlutterLogoX({
    Key key,
    this.size,
    this.colors,
    this.textColor = const Color(0xFF616161),
    this.style = FlutterLogoStyleX.markOnly,
    this.duration = const Duration(milliseconds: 750),
    this.curve = Curves.fastOutSlowIn,
  }) : super(key: key);

  /// The size of the logo in logical pixels.
  ///
  /// The logo will be fit into a square this size.
  ///
  /// Defaults to the current [IconTheme] size, if any. If there is no
  /// [IconTheme], or it does not specify an explicit size, then it defaults to
  /// 24.0.
  final double size;

  /// The color swatch to use to paint the logo, [Colors.blue] by default.
  ///
  /// If for some reason the default colors are impractical, then one
  /// of [Colors.amber], [Colors.red], or [Colors.indigo] swatches can be used.
  /// These are Flutter's secondary colors.
  ///
  /// In extreme cases where none of those four color schemes will work,
  /// [Colors.pink], [Colors.purple], or [Colors.cyan] swatches can be used.
  /// These are Flutter's tertiary colors.
  final MaterialColor colors;

  /// The color used to paint the "Flutter" text on the logo, if [style] is
  /// [FlutterLogoStyleX.horizontal] or [FlutterLogoStyleX.stacked]. The
  /// appropriate color is `const Color(0xFF616161)` (a medium gray), against a
  /// white background.
  final Color textColor;

  /// Whether and where to draw the "Flutter" text. By default, only the logo
  /// itself is drawn.
  final FlutterLogoStyleX style;

  /// The length of time for the animation if the [style], [colors], or
  /// [textColor] properties are changed.
  final Duration duration;

  /// The curve for the logo animation if the [style], [colors], or [textColor]
  /// change.
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final IconThemeData iconTheme = IconTheme.of(context);
    final double iconSize = size ?? iconTheme.size;
    final MaterialColor logoColors = colors ?? Colors.blue;
    return AnimatedContainer(
      width: iconSize,
      height: iconSize,
      duration: duration,
      curve: curve,
      decoration: FlutterLogoDecorationX(
        lightColor: logoColors.shade400,
        darkColor: logoColors.shade900,
        style: style,
        textColor: textColor,
      ),
    );
  }
}
