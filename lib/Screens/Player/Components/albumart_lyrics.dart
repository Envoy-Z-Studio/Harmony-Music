import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:harmonymusic/Screens/Player/Components/lyrics_widget.dart';
import 'package:harmonymusic/Screens/Player/player_controller.dart';
import 'package:harmonymusic/CustomWidgets/Common/image_widget.dart';
import 'package:harmonymusic/CustomWidgets/Common/sleep_timer_bottom_sheet.dart';

class AlbumArtNLyrics extends StatelessWidget {
  const AlbumArtNLyrics({super.key, required this.playerArtImageSize});
  final double playerArtImageSize;

  @override
  Widget build(BuildContext context) {
    final PlayerController playerController = Get.find<PlayerController>();
    return Obx(() => playerController.currentSong.value != null
        ? Stack(
            children: [
              // Album Art / Lyrics Display
              Obx(() => SizedBox(
                    height: playerArtImageSize,
                    width: playerArtImageSize,
                    child: playerController.showLyricsflag.isTrue
                        ? LyricsWidget(
                            padding: EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: playerArtImageSize / 3.5))
                        : ImageWidget(
                            size: playerArtImageSize,
                            song: playerController.currentSong.value!,
                            isPlayerArtImage: true,
                          ),
                  )),

              // Lyrics/Close Button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(width: 1.3, color: Colors.white),
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withAlpha(150)),
                    child: IconButton(
                      onPressed: () {
                        playerController.showLyrics();
                      },
                      icon: Icon(
                        playerController.showLyricsflag.isTrue
                            ? Icons.close
                            : Icons.lyrics,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // Sleep Timer Button
              if (playerController.isSleepTimerActive.isTrue)
                SizedBox(
                  width: playerArtImageSize,
                  height: playerArtImageSize,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 50,
                        width: 60,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(width: 1.3, color: Colors.white),
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withAlpha(150)),
                        child: IconButton(
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
                              builder: (context) =>
                                  const SleepTimerBottomSheet(),
                            );
                          },
                          icon: const Icon(
                            Icons.timer,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
            ],
          )
        : Container());
  }
}
