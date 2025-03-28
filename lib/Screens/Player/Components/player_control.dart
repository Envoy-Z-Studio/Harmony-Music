import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:get/get.dart';
import 'package:widget_marquee/widget_marquee.dart';

import 'package:harmonymusic/Screens/Player/Components/play_pause_button.dart';
import 'package:harmonymusic/Screens/Player/player_controller.dart';
import 'package:harmonymusic/CustomWidgets/Common/songinfo_bottom_sheet.dart';

class PlayerControlWidget extends StatelessWidget {
  const PlayerControlWidget({Key? key});

  @override
  Widget build(BuildContext context) {
    final PlayerController playerController = Get.find<PlayerController>();

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
                    colors: [
                      Colors.white,
                      Colors.white,
                      Colors.white,
                      Colors.white,
                      Colors.white,
                      Colors.white,
                      Colors.transparent
                    ],
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
                          playerController.currentSong.value != null
                              ? playerController.currentSong.value!.title
                              : "NA",
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.labelMedium!,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Marquee(
                        delay: const Duration(milliseconds: 300),
                        duration: const Duration(seconds: 10),
                        id: "${playerController.currentSong.value}_subtitle",
                        child: Text(
                          playerController.currentSong.value != null
                              ? playerController.currentSong.value!.artist!
                              : "NA",
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      )
                    ],
                  );
                }),
              ),
            ),
            Row(
              children: [
                CupertinoButton(
                  padding: const EdgeInsets.only(right: 5),
                  onPressed: playerController.toggleFavourite,
                  child: Obx(() => Icon(
                        playerController.isCurrentSongFav.isFalse
                            ? CupertinoIcons.heart
                            : CupertinoIcons.heart_fill,
                        color: Theme.of(context).textTheme.titleMedium!.color,
                        size: 25,
                      )),
                ),
                IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Theme.of(context).textTheme.titleMedium!.color,
                    size: 25,
                  ),
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
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        GetX<PlayerController>(builder: (controller) {
          return ProgressBar(
            thumbRadius: 7,
            barHeight: 4.5,
            baseBarColor: Colors.white.withOpacity(0.3),
            bufferedBarColor: Colors.white.withOpacity(0.5),
            progressBarColor: Colors.white,
            thumbColor: Colors.white,
            timeLabelTextStyle: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontSize: 14, color: Colors.white),
            progress: controller.progressBarStatus.value.current,
            total: controller.progressBarStatus.value.total,
            buffered: controller.progressBarStatus.value.buffered,
            onSeek: controller.seek,
          );
        }),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: playerController.prev,
              child: const Icon(
                CupertinoIcons.backward_fill,
                color: Colors.white,
                size: 40,
              ),
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
                  color:
                      isLastSong ? Colors.white.withOpacity(0.3) : Colors.white,
                  size: 40,
                );
              }),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.speaker_fill,
                  color: Colors.white, size: 18),
              Expanded(
                child: Obx(() {
                  return CupertinoSlider(
                    min: 0,
                    max: 1,
                    value: playerController.volume.value.toDouble(),
                    onChanged: (double newValue) =>
                        playerController.setVolume(newValue.toInt()),
                    activeColor: Colors.white,
                    thumbColor: Colors.white,
                  );
                }),
              ),
              const Icon(CupertinoIcons.speaker_3_fill,
                  color: Colors.white, size: 22),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => playerController.queuePanelController.open(),
              child: const Icon(
                CupertinoIcons.list_bullet,
                color: Colors.white,
                size: 24,
              ),
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
