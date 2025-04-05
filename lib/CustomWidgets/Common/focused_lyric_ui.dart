// lib/CustomWidgets/Lyrics/focused_lyric_ui.dart
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyric_ui/lyric_ui.dart';
import 'package:google_fonts/google_fonts.dart'; // Make sure you have this package

/// A LyricUI implementation that emphasizes the currently playing line
/// with larger size and brighter color, while de-emphasizing other lines.
/// Mimics modern music app lyric styles.
class FocusedLyricUI extends LyricUI {
  final double defaultFontSize;
  final double defaultExtFontSize;
  final double playingFontSize;
  final double playingExtFontSize;
  final Color inactiveColor;
  final Color activeColor;
  final Color inactiveExtColor;
  final Color activeExtColor;
  final bool highLight;

  FocusedLyricUI({
    this.defaultFontSize = 18.0,
    this.defaultExtFontSize = 16.0,
    this.playingFontSize = 28.0,
    this.playingExtFontSize = 16.0,
    this.inactiveColor = Colors.grey,
    this.activeColor = Colors.white,
    this.inactiveExtColor = Colors.grey,
    this.activeExtColor = Colors.white70,
    this.highLight = true,
  });

  final _fontFamily = GoogleFonts.inter().fontFamily;

  @override
  TextStyle getPlayingExtTextStyle() => TextStyle(
        color: activeExtColor,
        fontSize: playingExtFontSize,
        fontFamily: _fontFamily,
      );

  @override
  TextStyle getPlayingMainTextStyle() => TextStyle(
        color: activeColor,
        fontSize: playingFontSize,
        fontWeight: FontWeight.bold,
        fontFamily: _fontFamily,
      );

  @override
  TextStyle getOtherExtTextStyle() => TextStyle(
        color: inactiveExtColor.withOpacity(0.8),
        fontSize: defaultExtFontSize,
        fontFamily: _fontFamily,
      );

  @override
  TextStyle getOtherMainTextStyle() => TextStyle(
        color: inactiveColor.withOpacity(0.7),
        fontSize: defaultFontSize,
        fontWeight: FontWeight.w500,
        fontFamily: _fontFamily,
      );

  @override
  double getInlineSpace() => 10.0;

  @override
  double getLineSpace() => 20.0;

  @override
  double getPlayingLineBias() => 0.4;

  @override
  bool enableHighlight() => highLight;

  @override
  HighlightDirection getHighlightDirection() => HighlightDirection.LTR;

  @override
  LyricAlign getLyricHorizontalAlign() {
    // TODO: implement getLyricHorizontalAlign
    throw UnimplementedError();
  }
}
