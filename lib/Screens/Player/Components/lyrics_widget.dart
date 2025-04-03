import 'package:flutter/material.dart';

import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:get/get.dart';

import 'package:harmonymusic/Screens/Player/player_controller.dart';
import 'package:harmonymusic/CustomWidgets/Common/loader.dart';

class LyricsWidget extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  const LyricsWidget({super.key, required this.padding});

  @override
  Widget build(BuildContext context) {
    final playerController = Get.find<PlayerController>();
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

        TextStyle baseStyle =
            Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 30);

        return hasSyncedLyrics
            ? IgnorePointer(
                child: LyricsReader(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  lyricUi: playerController.lyricUi,
                  position: playerController
                      .progressBarStatus.value.current.inMilliseconds,
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
                    style: baseStyle.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              );
      },
    );
  }
}
