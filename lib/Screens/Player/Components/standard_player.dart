import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:harmonymusic/Screens/Player/Components/albumart_lyrics.dart';
import 'package:harmonymusic/Screens/Player/Components/lyrics_switch.dart';
import 'package:harmonymusic/Screens/Player/Components/player_control.dart';
import 'package:harmonymusic/Screens/Player/player_controller.dart';
import 'package:harmonymusic/CustomWidgets/Common/songinfo_bottom_sheet.dart';
import 'package:harmonymusic/Theme/theme_controller.dart'; // Import the theme controller

class StandardPlayer extends StatefulWidget {
  const StandardPlayer({Key? key}) : super(key: key);

  @override
  State<StandardPlayer> createState() => _StandardPlayerState();
}

class _StandardPlayerState extends State<StandardPlayer> with SingleTickerProviderStateMixin {
  late PlayerController playerController;
  late AnimationController _animationController;
  late ThemeController themeController;  // Add ThemeController

  @override
  void initState() {
    super.initState();
    playerController = Get.find<PlayerController>();
    themeController = Get.find<ThemeController>(); // Find the theme controller
    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    double playerArtImageSize = size.width - 60;
    final spaceAvailableForArtImage =
        size.height - (70 + Get.mediaQuery.padding.bottom + 330);
    playerArtImageSize = playerArtImageSize > spaceAvailableForArtImage
        ? spaceAvailableForArtImage
        : playerArtImageSize;

    return Stack(
      children: [
        /// Animated Gradient Background
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Obx(() => Container(  // Using Obx to listen for theme changes
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1 + math.sin(_animationController.value * 2 * math.pi), 0), // Animate begin
                  end: Alignment(1 + math.cos(_animationController.value * 2 * math.pi), 0),   // Animate end
                  colors: [
                    themeController.themedata.value?.primaryColor ?? Colors.grey.shade800,
                    (themeController.themedata.value?.primaryColorDark ?? Colors.grey.shade900),
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ));
          },
        ),

        /// Stack child
        /// Blur effect on background
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Reduced blur
          child: Stack(
            children: [
              /// opacity effect on background
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.05), //Reduced opacity
                  ),
                ),
              ),

              /// used to hide queue header when player is minimized
              /// gradient to used here
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 65 + Get.mediaQuery.padding.bottom + 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.2), //Reduced opacity
                        Theme.of(context).primaryColor.withOpacity(0.1), //Reduced opacity
                        Theme.of(context).primaryColor.withOpacity(0.05), //Reduced opacity
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

        /// Stack child
        /// Player content in landscape mode
        Padding(
          padding: const EdgeInsets.only(left: 25, right: 25),
          child: (context.isLandscape)
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// Album art with lyrics in .45 of width
                    SizedBox(
                      width: size.width * .45,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: 90.0,
                        ),
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

                    /// Player controls in .48 of width
                    SizedBox(
                        width: size.width * .48,
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 10.0,
                              right: 10,
                              bottom: Get.mediaQuery.padding.bottom),
                          child: const PlayerControlWidget(),
                        ))
                  ],
                )
              :

              /// Player content in portrait mode
              Column(
                  children: [
                    /// Work as top padding depending on the lyrics visibility and screen size
                    Obx(
                      () => playerController.showLyricsflag.value
                          ? SizedBox(
                              height: size.height < 750 ? 60 : 90,
                            )
                          : SizedBox(
                              height: size.height < 750 ? 110 : 140,
                            ),
                    ),

                    /// Contains the lyrics switch and album art with lyrics
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const LyricsSwitch(),
                        ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 500),
                            child: AlbumArtNLyrics(
                                playerArtImageSize: playerArtImageSize)),
                      ],
                    ),

                    /// Extra space container
                    Expanded(child: Container()),

                    /// Contains the player controls
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: 80 + Get.mediaQuery.padding.bottom),
                      child: Container(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: const PlayerControlWidget()),
                    )
                  ],
                ),
        ),

        /// Stack child
        /// Contains [Minimize button], Playing from [Album name], [More button] for current song context
        /// This is not visible in mobile devices in landscape mode
        if (!(context.isLandscape && GetPlatform.isMobile))
          Padding(
            padding: EdgeInsets.only(
                top: Get.mediaQuery.padding.top + 20, left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Minimize button
                IconButton(
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 28,
                  ),
                  onPressed: playerController.playerPanelController.close,
                ),

                /// Playing from [Album name]
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

                /// More button for current song context
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
          )
      ],
    );
  }
}
