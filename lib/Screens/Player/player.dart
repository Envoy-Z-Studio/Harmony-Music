import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/Screens/Player/Components/albumart_lyrics.dart';
import 'package:harmonymusic/Screens/Player/Components/background_image.dart';
import 'package:harmonymusic/Screens/Player/Components/player_control.dart';
import 'package:harmonymusic/Screens/Player/player_controller.dart';
import 'package:harmonymusic/Screens/Settings/settings_screen_controller.dart';
import 'package:harmonymusic/CustomWidgets/Common/sliding_up_panel.dart';
import 'package:harmonymusic/CustomWidgets/Common/snackbar.dart';
import 'package:harmonymusic/CustomWidgets/Common/up_next_queue.dart';
import 'package:harmonymusic/Utilities/helper.dart';

/// Main Player Screen
class Player extends StatelessWidget {
  const Player({super.key});

  @override
  Widget build(BuildContext context) {
    printINFO("player");
    final size = MediaQuery.of(context).size;
    final PlayerController playerController = Get.find<PlayerController>();
    Get.find<SettingsScreenController>();

    // Dynamically calculate album art size based on screen size
    double playerArtImageSize = size.width - 50;
    final spaceAvailableForArtImage =
        size.height - (50 + Get.mediaQuery.padding.bottom + 330);
    playerArtImageSize = playerArtImageSize > spaceAvailableForArtImage
        ? spaceAvailableForArtImage
        : playerArtImageSize;

    return Scaffold(
      body: Obx(
        () => SlidingUpPanel(
          boxShadow: const [],
          minHeight: 0,
          maxHeight: size.height,
          isDraggable: true,
          controller: GetPlatform.isDesktop
              ? null
              : playerController.queuePanelController,
          snapPoint: 0.3,
          parallaxEnabled: true,
          parallaxOffset: 0.5,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          // Collapsed Queue Panel Header
          collapsed: const SizedBox.shrink(),

          // Queue Panel Content
          panelBuilder: (ScrollController sc, onReorderStart, onReorderEnd) {
            playerController.scrollController = sc;
            return Stack(
              children: [
                // Up Next Queue List
                UpNextQueue(
                  onReorderEnd: onReorderEnd,
                  onReorderStart: onReorderStart,
                ),

                // Queue Controls Bottom Bar
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.only(
                            top: 15, bottom: 10, left: 10, right: 10),
                        decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(blurRadius: 5, color: Colors.black54)
                          ],
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.5),
                        ),
                        height: 60 + Get.mediaQuery.padding.bottom,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Song Count
                            Obx(
                              () => Text(
                                "${playerController.currentQueue.length} ${"songs".tr}",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .color),
                              ),
                            ),

                            // Loop Button
                            InkWell(
                              onTap: () =>
                                  playerController.toggleQueueLoopMode(),
                              child: Obx(
                                () => Container(
                                  height: 30,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  decoration: BoxDecoration(
                                    color: playerController
                                            .isQueueLoopModeEnabled.isFalse
                                        ? Colors.white24
                                        : Colors.white.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(child: Text("queueLoop".tr)),
                                ),
                              ),
                            ),

                            // Shuffle Button
                            InkWell(
                              onTap: () {
                                if (playerController
                                    .isShuffleModeEnabled.isTrue) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      snackbar(
                                          context, "queueShufflingDeniedMsg".tr,
                                          size: SanckBarSize.BIG));
                                  return;
                                }
                                playerController.shuffleQueue();
                              },
                              child: Container(
                                height: 30,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Center(
                                    child: Icon(CupertinoIcons.shuffle,
                                        color: Colors.black)),
                              ),
                            ),

                            // Clear Queue Button
                            InkWell(
                              onTap: () => playerController.clearQueue(),
                              child: Container(
                                height: 30,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Center(
                                    child: Icon(CupertinoIcons.text_badge_minus,
                                        color: Colors.black)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Mini Pill
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top+ 8.0),// Lower Mini Pill
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          width: 60,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade600.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },

          // Main Player UI
          body: Stack(
            children: [
              // Background Image
              BackgroudImage(
                key:
                    Key("${playerController.currentSong.value?.id}_background"),
                cacheHeight: 200,
              ),

              // Background Blur Effect
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Stack(
                  children: [
                    // Background Opacity
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.8),
                        ),
                      ),
                    ),

                    // Gradient for Queue Header
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 65 + Get.mediaQuery.padding.bottom + 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).primaryColor,
                              Theme.of(context).primaryColor.withOpacity(0.4),
                              Theme.of(context).primaryColor.withOpacity(0),
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

              // Player Content (Landscape Mode)
              Padding(
                padding: const EdgeInsets.only(left: 25, right: 25),
                child: (context.isLandscape)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Album Art and Lyrics
                          SizedBox(
                            width: size.width * .45,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                bottom: 90.0,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Center(
                                  child:  AlbumArtNLyrics(
                                      playerArtImageSize: size.width * .29,
                                    ),
                                ),
                              ),
                            ),
                          ),

                          // Player Controls
                          SizedBox(
                            width: size.width * .48,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: 10.0,
                                  right: 10,
                                  bottom: Get.mediaQuery.padding.bottom),
                              child: const PlayerControlWidget(),
                            ),
                          )
                        ],
                      )
                    :

                    // Player Content (Portrait Mode)
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Top Padding (Lyrics Visibility Dependent)
                           SizedBox(
                                height: size.height < 750 ? 75 : 100,
                              ),


                          // Lyrics Switch and Album Art
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 500),
                            child: AlbumArtNLyrics(
                                playerArtImageSize: playerArtImageSize),
                          ),

                          // Gap between album art and player controls
                          const SizedBox(height: 18),

                          // Player Controls
                          Container(
                            constraints: const BoxConstraints(maxWidth: 500),
                            child: const PlayerControlWidget(),
                          ),
                          SizedBox(height: 80 + Get.mediaQuery.padding.bottom),
                        ],
                      ),
              ),

              // Top Bar (Minimize, Playing From)
              if (!(context.isLandscape && GetPlatform.isMobile))
                Padding(
                  padding: EdgeInsets.only(
                      top: Get.mediaQuery.padding.top + 20,
                      left: 10,
                      right: 10),
                  child: Column(
                    children: [
                      // Minimize Pill
                      Container(
                        width: 60,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(width: 28),
                          // Playing From Info
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 8.0, left: 5, right: 5),
                              child: Obx(
                                () => Column(
                                  children: [
                                    Text(
                                        playerController
                                            .playinfrom.value.typeString,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                    Obx(
                                      () => Text(
                                        "\"${playerController.playinfrom.value.nameString}\"",
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 28),
                        ],
                      ),
                    ],
                  ),
                )
              // Mini Pill
              else
                Padding(
                  padding: EdgeInsets.only(
                      top: Get.mediaQuery.padding.top + 20,
                      left: 10,
                      right: 10),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top+ 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            width: 60,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade600.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
