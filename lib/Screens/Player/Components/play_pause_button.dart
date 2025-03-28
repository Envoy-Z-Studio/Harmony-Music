import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:harmonymusic/Screens/Player/player_controller.dart';
import 'package:harmonymusic/CustomWidgets/Common/loader.dart';

/// A button that toggles between play and pause icons.
/// Shows a loading indicator when the audio is buffering.
class PlayPauseButton extends StatefulWidget {
  final double iconSize;

  const PlayPauseButton({super.key, this.iconSize = 40.0});

  @override
  State<PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton> {
  @override
  Widget build(BuildContext context) {
    return GetX<PlayerController>(builder: (controller) {
      final buttonState = controller.buttonState.value;
      final isPlaying = buttonState == PlayButtonState.playing;
      final isLoading = buttonState == PlayButtonState.loading;

      return IconButton(
        iconSize: widget.iconSize,
        onPressed: () {
          isPlaying ? controller.pause() : controller.play();
        },
        icon: isLoading
            ? const LoadingIndicator(dimension: 20)
            : Icon(
                isPlaying
                    ? CupertinoIcons.pause_solid
                    : CupertinoIcons.play_fill,
              ),
      );
    });
  }
}
