import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';

class CustomLyricUI extends UINetease {
  final BuildContext context;

  CustomLyricUI(this.context)
      : super(
          lyricAlign: LyricAlign.LEFT,
          defaultSize: 30,
          otherMainSize: 27,
          defaultExtSize: 90,
          lineGap: 10,
        );

  TextStyle get baseStyle =>
      Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 30);

  @override
  Color getLyricHightlightColor() {
    return Colors.white;
  }

  @override
  TextStyle getPlayingMainTextStyle() {
    return baseStyle.copyWith(
      color: Colors.white,
      fontSize: 30,
    );
  }

  @override
  TextStyle getOtherMainTextStyle() {
    return baseStyle.copyWith(
      color: Colors.white.withOpacity(0.7),
      fontSize: 27,
    );
  }
}
