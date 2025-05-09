import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:get/get.dart';
import 'package:widget_marquee/widget_marquee.dart';

import 'package:harmonymusic/Screens/Player/Components/play_pause_button.dart';
import 'package:harmonymusic/Screens/Player/player_controller.dart';
import 'package:harmonymusic/CustomWidgets/Common/add_to_playlist.dart';
import 'package:harmonymusic/CustomWidgets/Common/image_widget.dart';
import 'package:harmonymusic/CustomWidgets/Common/lyrics_dialog.dart';
import 'package:harmonymusic/CustomWidgets/Common/mini_player_progress_bar.dart';
import 'package:harmonymusic/CustomWidgets/Common/sleep_timer_bottom_sheet.dart';
import 'package:harmonymusic/CustomWidgets/Common/song_download_btn.dart';
import 'package:harmonymusic/CustomWidgets/Common/song_info_dialog.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final playerController = Get.find<PlayerController>();
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 800;
    return Obx(() {
      return Visibility(
        visible: playerController.isPlayerpanelTopVisible.value,
        child: AnimatedOpacity(
          opacity: playerController.playerPaneOpacity.value,
          duration: Duration.zero,
          child: Container(
            height: playerController.playerPanelMinHeight.value,
            width: size.width,
            color: Theme.of(context).bottomSheetTheme.backgroundColor,
            child: Center(
              child: Column(
                children: [
                  // Mini Player progress bar
                  !isWideScreen
                      ? GetX<PlayerController>(
                          builder: (controller) => Container(
                              height: 3,
                              color: Theme.of(context)
                                  .progressIndicatorTheme
                                  .color,
                              child: MiniPlayerProgressBar(
                                  progressBarStatus:
                                      controller.progressBarStatus.value,
                                  progressBarColor: Theme.of(context)
                                          .progressIndicatorTheme
                                          .linearTrackColor ??
                                      Colors.white)),
                        )
                      : GetX<PlayerController>(builder: (controller) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 15.0, top: 8, right: 15, bottom: 0),
                            child: ProgressBar(
                              timeLabelLocation: TimeLabelLocation.sides,
                              thumbRadius: 7,
                              barHeight: 4,
                              thumbGlowRadius: 15,
                              baseBarColor: Theme.of(context)
                                  .sliderTheme
                                  .inactiveTrackColor,
                              bufferedBarColor: Theme.of(context)
                                  .sliderTheme
                                  .valueIndicatorColor,
                              progressBarColor: Theme.of(context)
                                  .sliderTheme
                                  .activeTrackColor,
                              thumbColor:
                                  Theme.of(context).sliderTheme.thumbColor,
                              timeLabelTextStyle:
                                  Theme.of(context).textTheme.titleMedium,
                              progress:
                                  controller.progressBarStatus.value.current,
                              total: controller.progressBarStatus.value.total,
                              buffered:
                                  controller.progressBarStatus.value.buffered,
                              onSeek: controller.seek,
                            ),
                          );
                        }),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 17.0, vertical: 7),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            playerController.currentSong.value != null
                                ? ImageWidget(
                                    size: 50,
                                    song: playerController.currentSong.value!,
                                  )
                                : const SizedBox(
                                    height: 50,
                                    width: 50,
                                  ),
                          ],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onHorizontalDragEnd: (DragEndDetails details) {
                              if (details.primaryVelocity! < 0) {
                                playerController.next();
                              } else if (details.primaryVelocity! > 0) {
                                playerController.prev();
                              }
                            },
                            onTap: () {
                              playerController.playerPanelController.open();
                            },
                            child: ColoredBox(
                              color: Colors.transparent,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 20,
                                    child: Text(
                                      playerController.currentSong.value != null
                                          ? playerController
                                              .currentSong.value!.title
                                          : "",
                                      maxLines: 1,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                    child: Marquee(
                                      id: "${playerController.currentSong.value}_mini",
                                      delay: const Duration(milliseconds: 300),
                                      duration: const Duration(seconds: 5),
                                      child: Text(
                                        playerController.currentSong.value !=
                                                null
                                            ? playerController
                                                .currentSong.value!.artist!
                                            : "",
                                        maxLines: 1,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Player control buttons
                        SizedBox(
                          width: isWideScreen ? 450 : 90,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (isWideScreen)
                                Row(
                                  children: [
                                    IconButton(
                                        iconSize: 20,
                                        onPressed:
                                            playerController.toggleFavourite,
                                        icon: Obx(() => Icon(
                                              playerController
                                                      .isCurrentSongFav.isFalse
                                                  ? CupertinoIcons.heart
                                                  : CupertinoIcons.heart_fill,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .color,
                                            ))),
                                    IconButton(
                                        iconSize: 20,
                                        onPressed:
                                            playerController.toggleShuffleMode,
                                        icon: Obx(() => Icon(
                                              CupertinoIcons.shuffle,
                                              color: playerController
                                                      .isShuffleModeEnabled
                                                      .value
                                                  ? Theme.of(context)
                                                      .textTheme
                                                      .titleLarge!
                                                      .color
                                                  : Theme.of(context)
                                                      .textTheme
                                                      .titleLarge!
                                                      .color!
                                                      .withOpacity(0.2),
                                            ))),
                                  ],
                                ),
                              if (isWideScreen)
                                SizedBox(
                                    width: 40,
                                    child: InkWell(
                                      onTap: (playerController
                                                  .currentQueue.isEmpty ||
                                              (playerController
                                                      .currentQueue.first.id ==
                                                  playerController
                                                      .currentSong.value?.id))
                                          ? null
                                          : playerController.prev,
                                      child: Icon(
                                        CupertinoIcons.backward_fill,
                                        color: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .color,
                                        size: 35,
                                      ),
                                    )),
                              isWideScreen
                                  ? Container(
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      width: 58,
                                      height: 58,
                                      child: Center(
                                          child: PlayPauseButton(
                                        iconSize: isWideScreen ? 43 : 35,
                                      )))
                                  : SizedBox.square(
                                      dimension: 50,
                                      child: Center(
                                          child: PlayPauseButton(
                                        iconSize: isWideScreen ? 43 : 35,
                                      ))),
                              SizedBox(
                                  width: 40,
                                  child: Obx(() {
                                    final isLastSong =
                                        playerController.currentQueue.isEmpty ||
                                            (!(playerController
                                                        .isShuffleModeEnabled
                                                        .isTrue ||
                                                    playerController
                                                        .isQueueLoopModeEnabled
                                                        .isTrue) &&
                                                (playerController
                                                        .currentQueue.last.id ==
                                                    playerController.currentSong
                                                        .value?.id));
                                    return InkWell(
                                      onTap: isLastSong
                                          ? null
                                          : playerController.next,
                                      child: Icon(
                                        CupertinoIcons.forward_fill,
                                        color: isLastSong
                                            ? Theme.of(context)
                                                .textTheme
                                                .titleLarge!
                                                .color!
                                                .withOpacity(0.2)
                                            : Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .color,
                                        size: 35,
                                      ),
                                    );
                                  })),
                              if (isWideScreen)
                                Row(
                                  children: [
                                    IconButton(
                                        iconSize: 20,
                                        onPressed:
                                            playerController.toggleLoopMode,
                                        icon: Icon(
                                          CupertinoIcons.repeat,
                                          color: playerController
                                                  .isLoopModeEnabled.value
                                              ? Theme.of(context)
                                                  .textTheme
                                                  .titleLarge!
                                                  .color
                                              : Theme.of(context)
                                                  .textTheme
                                                  .titleLarge!
                                                  .color!
                                                  .withOpacity(0.2),
                                        )),
                                    IconButton(
                                        iconSize: 20,
                                        onPressed: () {
                                          playerController.showLyrics();
                                          showDialog(
                                                  builder: (context) =>
                                                      const LyricsDialog(),
                                                  context: context)
                                              .whenComplete(() {
                                            playerController
                                                    .isDesktopLyricsDialogOpen =
                                                false;
                                            playerController
                                                .showLyricsflag.value = false;
                                          });
                                          playerController
                                              .isDesktopLyricsDialogOpen = true;
                                        },
                                        icon: Icon(
                                            CupertinoIcons.music_house_fill,
                                            color: Theme.of(context)
                                                .textTheme
                                                .titleLarge!
                                                .color)),
                                  ],
                                ),
                              if (isWideScreen)
                                const SizedBox(
                                  width: 20,
                                )
                            ],
                          ),
                        ),
                        if (isWideScreen)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: size.width < 1004 ? 0 : 30.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(
                                        right: 20, left: 10),
                                    height: 20,
                                    width: (size.width > 860) ? 220 : 180,
                                    child: Obx(() {
                                      final volume =
                                          playerController.volume.value;
                                      return Row(
                                        children: [
                                          SizedBox(
                                              width: 20,
                                              child: InkWell(
                                                onTap: playerController.mute,
                                                child: Icon(
                                                  volume == 0
                                                      ? CupertinoIcons
                                                          .volume_mute
                                                      : volume > 0 &&
                                                              volume < 50
                                                          ? CupertinoIcons
                                                              .volume_down
                                                          : CupertinoIcons
                                                              .volume_up,
                                                  size: 20,
                                                ),
                                              )),
                                          Expanded(
                                            child: SliderTheme(
                                              data: SliderTheme.of(context)
                                                  .copyWith(
                                                trackHeight: 2,
                                                thumbShape:
                                                    const RoundSliderThumbShape(
                                                        enabledThumbRadius:
                                                            6.0),
                                                overlayShape:
                                                    const RoundSliderOverlayShape(
                                                        overlayRadius: 10.0),
                                              ),
                                              child: Slider(
                                                value: playerController
                                                        .volume.value /
                                                    100,
                                                onChanged: (value) {
                                                  playerController
                                                      .setVolume(value * 1.0);
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                  ),
                                  SizedBox(
                                    height: 40,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            playerController
                                                .homeScaffoldkey.currentState!
                                                .openEndDrawer();
                                          },
                                          icon: const Icon(
                                              CupertinoIcons.music_note_list),
                                        ),
                                        if (size.width > 860)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0),
                                            child: IconButton(
                                              onPressed: () {
                                                showModalBottomSheet(
                                                  constraints:
                                                      const BoxConstraints(
                                                          maxWidth: 500),
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                            top:
                                                                Radius.circular(
                                                                    10.0)),
                                                  ),
                                                  isScrollControlled: true,
                                                  context: playerController
                                                      .homeScaffoldkey
                                                      .currentState!
                                                      .context,
                                                  barrierColor: Colors
                                                      .transparent
                                                      .withAlpha(100),
                                                  builder: (context) =>
                                                      const SleepTimerBottomSheet(),
                                                );
                                              },
                                              icon: Icon(playerController
                                                      .isSleepTimerActive.isTrue
                                                  ? CupertinoIcons.timer_fill
                                                  : CupertinoIcons.timer),
                                            ),
                                          ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        const SongDownloadButton(
                                          calledFromPlayer: true,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            final currentSong = playerController
                                                .currentSong.value;
                                            if (currentSong != null) {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AddToPlaylist(
                                                        [currentSong]),
                                              ).whenComplete(() => Get.delete<
                                                  AddToPlaylistController>());
                                            }
                                          },
                                          icon: const Icon(CupertinoIcons
                                              .list_bullet_below_rectangle),
                                        ),
                                        if (size.width > 965)
                                          IconButton(
                                            onPressed: () {
                                              final currentSong =
                                                  playerController
                                                      .currentSong.value;
                                              if (currentSong != null) {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      SongInfoDialog(
                                                    song: currentSong,
                                                  ),
                                                );
                                              }
                                            },
                                            icon: const Icon(
                                                CupertinoIcons.info_circle,
                                                size: 22),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
