import 'package:flutter/material.dart';

import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:get/get.dart';

import 'package:harmonymusic/Screens/Player/player_controller.dart';
import 'package:harmonymusic/CustomWidgets/Common/loader.dart';
import 'package:harmonymusic/CustomWidgets/Common/lyrics_ui.dart';

class LyricsWidget extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  const LyricsWidget({super.key, required this.padding});

  @override
  Widget build(BuildContext context) {
    final playerController = Get.find<PlayerController>();
    final customLyricUI = CustomLyricUI(context);

    return Obx(
      () {
        if (playerController.isLyricsLoading.isTrue) {
          return const Center(child: LoadingIndicator());
        }

        // Get synced lyrics, fallback to plain if unavailable
        String syncedLyrics = playerController.lyrics['synced'].toString();
        String plainLyrics = playerController.lyrics["plainLyrics"];
        bool hasSyncedLyrics = syncedLyrics.isNotEmpty && syncedLyrics != "NA";
        bool hasPlainLyrics = plainLyrics.isNotEmpty && plainLyrics != "NA";

        if (!hasSyncedLyrics && !hasPlainLyrics) {
          return Padding(
            padding: padding,
            child: Center(
              child: Text(
                "lyricsNotAvailable".tr,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontSize: 16,
                      color: Colors.white,
                    ),
              ),
            ),
          );
        }

        return hasSyncedLyrics
            ? IgnorePointer(
                child: LyricsReader(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  lyricUi: customLyricUI, // Use customLyricUI
                  position: playerController
                      .progressBarStatus.value.current.inMilliseconds
                      .toInt(),
                  model: LyricsModelBuilder.create()
                      .bindLyricToMain(syncedLyrics)
                      .getModel(),
                ),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: padding,
                child: TextSelectionTheme(
                  data: Theme.of(context).textSelectionTheme,
                  child: SelectableText(
                    plainLyrics,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontSize: 30,
                          color: Colors.white.withOpacity(0.7),
                        ),
                  ),
                ),
              );
      },
    );
  }
}
