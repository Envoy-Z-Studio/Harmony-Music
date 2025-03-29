import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:interactive_slider/interactive_slider.dart';
import 'package:widget_marquee/widget_marquee.dart';

import 'package:harmonymusic/Screens/Player/Components/play_pause_button.dart';
import 'package:harmonymusic/Screens/Player/player_controller.dart';
import 'package:harmonymusic/CustomWidgets/Common/songinfo_bottom_sheet.dart';

class PlayerControlWidget extends StatelessWidget {
  const PlayerControlWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final PlayerController playerController = Get.find<PlayerController>();
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ShaderMask(
                shaderCallback: (rect) {
                  return const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.white, Colors.white, Colors.transparent],
                  ).createShader(Rect.fromLTWH(0, 0, rect.width, rect.height));
                },
                blendMode: BlendMode.dstIn,
                child: Obx(() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Marquee(
                        delay: const Duration(milliseconds: 300),
                        duration: const Duration(seconds: 10),
                        id: "${playerController.currentSong.value}_title",
                        child: Text(
                          playerController.currentSong.value?.title ?? "NA",
                          style: textTheme.labelMedium!,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Marquee(
                        delay: const Duration(milliseconds: 300),
                        duration: const Duration(seconds: 10),
                        id: "${playerController.currentSong.value}_subtitle",
                        child: Text(
                          playerController.currentSong.value?.artist ?? "NA",
                          style: textTheme.labelSmall,
                        ),
                      )
                    ],
                  );
                }),
              ),
            ),
            Row(
              children: [
                _buildBlurredCircle(
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: playerController.toggleFavourite,
                    child: Obx(() => Icon(
                          playerController.isCurrentSongFav.isFalse
                              ? CupertinoIcons.heart
                              : CupertinoIcons.heart_fill,
                          color: Colors.white,
                          size: 22,
                        )),
                  ),
                ),
                const SizedBox(width: 5),
                _buildBlurredCircle(
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      showModalBottomSheet(
                        constraints: const BoxConstraints(maxWidth: 500),
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(10.0)),
                        ),
                        isScrollControlled: true,
                        context: playerController
                            .homeScaffoldkey.currentState!.context,
                        barrierColor: Colors.transparent.withAlpha(100),
                        builder: (context) => SongInfoBottomSheet(
                          playerController.currentSong.value!,
                          calledFromPlayer: true,
                        ),
                      ).whenComplete(() => Get.delete<SongInfoController>());
                    },
                    child: const Icon(
                      CupertinoIcons.ellipsis,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          final status = playerController.progressBarStatus.value;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: InteractiveSlider(
                padding: EdgeInsets.zero,
                initialProgress: status.current.inSeconds.toDouble(),
                max: status.total.inSeconds.toDouble(),
                backgroundColor: Colors.grey[800]!,
                foregroundColor: Colors.grey[300]!,
                iconPosition: IconPosition.below,
                startIcon: Text(
                  _formatDuration(status.current),
                  style: textTheme.labelSmall?.copyWith(
                    color: Colors.grey[300],
                  ),
                ),
                endIcon: Text(
                  _formatDuration(status.total),
                  style: textTheme.labelSmall?.copyWith(
                    color: Colors.grey[300],
                  ),
                ),
                onChanged: (value) {
                  playerController.seek(Duration(seconds: value.toInt()));
                },
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: playerController.prev,
              child: const Icon(CupertinoIcons.backward_fill,
                  color: Colors.white, size: 40),
            ),
            const PlayPauseButton(iconSize: 65),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: playerController.next,
              child: Obx(() {
                final isLastSong = playerController.currentQueue.isEmpty ||
                    (!(playerController.isShuffleModeEnabled.isTrue ||
                            playerController.isQueueLoopModeEnabled.isTrue) &&
                        (playerController.currentQueue.last.id ==
                            playerController.currentSong.value?.id));
                return Icon(
                  CupertinoIcons.forward_fill,
                  color: isLastSong ? Colors.grey : Colors.white,
                  size: 40,
                );
              }),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Obx(() {
            return InteractiveSlider(
              padding: EdgeInsets.zero,
              initialProgress: playerController.volume.value * 100,
              max: 100,
              backgroundColor: Colors.grey[800]!,
              foregroundColor: Colors.grey[300]!,
              startIcon: const Icon(
                CupertinoIcons.speaker_fill,
                color: Colors.grey,
                size: 20,
              ),
              endIcon: const Icon(
                CupertinoIcons.speaker_3_fill,
                color: Colors.grey,
                size: 22,
              ),
              onChanged: (value) {
                playerController.setVolume(value / 100);
              },
            );
          }),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => playerController.queuePanelController.open(),
              child: const Icon(CupertinoIcons.list_bullet,
                  color: Colors.white, size: 24),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: playerController.toggleShuffleMode,
              child: Obx(() => Icon(
                    CupertinoIcons.shuffle,
                    color: playerController.isShuffleModeEnabled.value
                        ? Colors.white
                        : Colors.grey,
                    size: 24,
                  )),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: playerController.toggleLoopMode,
              child: Obx(() => Icon(
                    CupertinoIcons.repeat,
                    color: playerController.isLoopModeEnabled.value
                        ? Colors.white
                        : Colors.grey,
                    size: 24,
                  )),
            ),
          ],
        ),
      ],
    );
  }
}

Widget _buildBlurredCircle(Widget child) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(15),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        width: 35,
        height: 35,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Center(child: child),
      ),
    ),
  );
}

String _formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return "$minutes:$seconds";
}
