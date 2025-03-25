import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:harmonymusic/Screens/Player/Components/albumart_lyrics.dart';
import 'package:harmonymusic/Screens/Player/Components/background_image.dart';
import 'package:harmonymusic/Screens/Player/Components/lyrics_switch.dart';
import 'package:harmonymusic/Screens/Player/Components/player_control.dart';
import 'package:harmonymusic/Screens/Player/player_controller.dart';
import 'package:harmonymusic/CustomWidgets/Common/songinfo_bottom_sheet.dart';

/// Standard player widget
///
/// This widget is used to display the player in the standard mode
///
/// It contains the album art image, lyrics switch, album art with lyrics and player controls
/// and is used in the [Player] widget
class StandardPlayer extends StatelessWidget {
  const StandardPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final PlayerController playerController = Get.find<PlayerController>();

    // Determine the optimal size for the album artwork  
    double playerArtImageSize = size.width - 60;
    final availableSpace =
        size.height - (70 + Get.mediaQuery.padding.bottom + 330);
    playerArtImageSize = playerArtImageSize > availableSpace
        ? availableSpace
        : playerArtImageSize;

    return Stack(
      children: [
        // Display background image  
        BackgroundImage(
          key: Key("${playerController.currentSong.value?.id}_background"),
          cacheHeight: 200,
        ),

        // Apply a blur effect over the background image  
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 80.0, sigmaY: 80.0),
          child: Stack(
            children: [
              // Apply a semi-transparent overlay to lighten the background  
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                  ),
                ),
              ),
              // Create a gradient effect at the bottom for smooth blending  
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 65 + Get.mediaQuery.padding.bottom + 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.5),
                        Theme.of(context).primaryColor.withOpacity(0.25),
                        Theme.of(context).primaryColor.withOpacity(0.1),
                        Theme.of(context).primaryColor.withOpacity(0.0),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      stops: const [0, 0.5, 0.8, 1],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Main content layout based on screen orientation  
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: (context.isLandscape)
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Album artwork and lyrics section  
                    SizedBox(
                      width: size.width * .45,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 90.0),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Center(
                            child: AlbumArtNLyrics(
                              playerArtImageSize: size.width * .29,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Player controls section  
                    SizedBox(
                      width: size.width * .48,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 10.0,
                          right: 10,
                          bottom: Get.mediaQuery.padding.bottom,
                        ),
                        child: const PlayerControlWidget(),
                      ),
                    )
                  ],
                )
              : Column(
                  children: [
                    // Adjust spacing based on lyrics visibility  
                    Obx(
                      () => playerController.showLyricsflag.value
                          ? SizedBox(height: size.height < 750 ? 60 : 90)
                          : SizedBox(height: size.height < 750 ? 110 : 140),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Toggle lyrics view  
                        const LyricsSwitch(),
                        // Display album artwork and lyrics  
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: AlbumArtNLyrics(
                              playerArtImageSize: playerArtImageSize),
                        ),
                      ],
                    ),
                    Expanded(child: Container()),
                    // Add player controls at the bottom  
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: 80 + Get.mediaQuery.padding.bottom),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: const PlayerControlWidget(),
                      ),
                    )
                  ],
                ),
        ),

        // Display top panel with back and menu buttons if not in landscape mode on mobile  
        if (!(context.isLandscape && GetPlatform.isMobile))
          Padding(
            padding: EdgeInsets.only(
                top: Get.mediaQuery.padding.top + 20, left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Close button  
                IconButton(
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 28,
                  ),
                  onPressed: playerController.playerPanelController.close,
                ),
                // Display playing source information  
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 5, right: 5),
                    child: Obx(
                      () => Column(
                        children: [
                          Text(playerController.playinfrom.value.typeString,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                          Obx(
                            () => Text(
                              "\"${playerController.playinfrom.value.nameString}\"",
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                // Menu button to show more options  
                IconButton(
                  icon: const Icon(
                    Icons.more_vert,
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
          ),
      ],
    );
  }
}
