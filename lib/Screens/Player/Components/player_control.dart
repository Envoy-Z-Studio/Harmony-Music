import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dart:ui';

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
        // Song Information (Title, Artist, Favorite, More)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ShaderMask(
                    shaderCallback: (rect) {
                      return const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.white,
                          Colors.white,
                          Colors.transparent
                        ],
                      ).createShader(
                          Rect.fromLTWH(0, 0, rect.width, rect.height));
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
                              playerController.currentSong.value?.artist ??
                                  "NA",
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
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
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10.0)),
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
        ),

        const SizedBox(height: 35),

        // Progress Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 6,
                  activeTrackColor: Colors.grey[300],
                  inactiveTrackColor: Colors.grey[800],
                  thumbColor: Colors.grey[300],
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 8),
                  overlayShape: SliderComponentShape.noOverlay,
                ),
                child: Obx(
                  () => Slider(
                    min: 0,
                    max: playerController
                        .progressBarStatus.value.total.inSeconds
                        .toDouble(),
                    value: playerController
                        .progressBarStatus.value.current.inSeconds
                        .toDouble(),
                    onChanged: (double newValue) {
                      playerController
                          .seek(Duration(seconds: newValue.toInt()));
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Text(
                          _formatDuration(
                              playerController.progressBarStatus.value.current),
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[300]),
                        )),
                    Obx(() => Text(
                          _formatDuration(
                              playerController.progressBarStatus.value.total),
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[300]),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // Player Controls
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

        const SizedBox(height: 28),

        // Volume Control
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(CupertinoIcons.speaker_fill,
                  color: Colors.grey, size: 20),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6,
                    activeTrackColor: Colors.grey[300],
                    inactiveTrackColor: Colors.grey[800],
                    thumbColor: Colors.grey[300],
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 8),
                    overlayShape: SliderComponentShape.noOverlay,
                  ),
                  child: Obx(() {
                    return Slider(
                      min: 0,
                      max: 1,
                      value: playerController.volume.value,
                      onChanged: (double newValue) =>
                          playerController.setVolume(newValue),
                    );
                  }),
                ),
              ),
              const Icon(CupertinoIcons.speaker_3_fill,
                  color: Colors.grey, size: 22),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Bottom Controls
        Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 2.0),
          child: Row(
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
        ),
      ],
    );
  }

  // Helper method for blurred circular background
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

  // Utility function to format duration
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
