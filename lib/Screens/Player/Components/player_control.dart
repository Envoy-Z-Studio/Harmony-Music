import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dart:ui';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:get/get.dart';
import 'package:widget_marquee/widget_marquee.dart';

import 'package:harmonymusic/Screens/Player/Components/play_pause_button.dart';
import 'package:harmonymusic/Screens/Player/player_controller.dart';
import 'package:harmonymusic/CustomWidgets/Common/songinfo_bottom_sheet.dart';

class PlayerControlWidget extends StatelessWidget {
  const PlayerControlWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final PlayerController playerController = Get.find<PlayerController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Top Section: Song Title, Artist, Favorite & More Button
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
                          style: Theme.of(context).textTheme.labelMedium!,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Marquee(
                        delay: const Duration(milliseconds: 300),
                        duration: const Duration(seconds: 10),
                        id: "${playerController.currentSong.value}_subtitle",
                        child: Text(
                          playerController.currentSong.value?.artist ?? "NA",
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      )
                    ],
                  );
                }),
              ),
            ),
            // Favorite & More Button with Blur Background
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
        const SizedBox(height: 20),

        // Progress Bar
        GetX<PlayerController>(builder: (controller) {
          return ProgressBar(
            thumbRadius: 0,
            barHeight: 4.5,
            baseBarColor: Colors.grey[800],
            bufferedBarColor: Colors.grey[600],
            progressBarColor: Colors.grey[300],
            thumbColor: Colors.transparent,
            timeLabelTextStyle:
                TextStyle(fontSize: 14, color: Colors.grey[300]),
            progress: controller.progressBarStatus.value.current,
            total: controller.progressBarStatus.value.total,
            buffered: controller.progressBarStatus.value.buffered,
            onSeek: controller.seek,
          );
        }),
        const SizedBox(height: 25),

        // Player Controls: Previous, Play/Pause, Next
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
        const SizedBox(height: 10),

        // Volume Control
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(CupertinoIcons.speaker_fill,
                  color: Colors.grey, size: 20),
              Expanded(
                child: Obx(() {
                  return SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4.5,
                      activeTrackColor: Colors.grey[300],
                      inactiveTrackColor: Colors.grey[800],
                      thumbColor: Colors.transparent,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 0),
                    ),
                    child: CupertinoSlider(
                      min: 0,
                      max: 1,
                      value: playerController.volume.value,
                      onChanged: (double newValue) =>
                          playerController.setVolume(newValue),
                      activeColor: Colors.grey[300],
                    ),
                  );
                }),
              ),
              const Icon(CupertinoIcons.speaker_3_fill,
                  color: Colors.grey, size: 22),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Bottom Controls: Queue, Shuffle, Loop
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

  // Helper method for blurred circular background
  Widget _buildBlurredCircle(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: child,
        ),
      ),
    );
  }
}
