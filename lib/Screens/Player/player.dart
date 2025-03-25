import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:harmonymusic/Screens/Player/Components/gesture_player.dart';
import 'package:harmonymusic/Screens/Player/Components/standard_player.dart';
import 'package:harmonymusic/Screens/Player/player_controller.dart';
import 'package:harmonymusic/Screens/Settings/settings_screen_controller.dart';
import 'package:harmonymusic/CustomWidgets/Common/sliding_up_panel.dart';
import 'package:harmonymusic/CustomWidgets/Common/snackbar.dart';
import 'package:harmonymusic/CustomWidgets/Common/up_next_queue.dart';
import 'package:harmonymusic/Utilities/helper.dart';

/// Player screen
/// Displays the player interface
///
/// The player interface can be either a standard player or a gesture-based player
class Player extends StatelessWidget {
  const Player({super.key});

  @override
  Widget build(BuildContext context) {
    printINFO("player");
    final size = MediaQuery.of(context).size;
    final PlayerController playerController = Get.find<PlayerController>();
    final settingsScreenController = Get.find<SettingsScreenController>();
    return Scaffold(
      /// SlidingUpPanel creates a panel that can be swiped up and down
      /// It is used to display the queue panel on mobile
      body: Obx(
        () => SlidingUpPanel(
          boxShadow: const [],
          minHeight: settingsScreenController.playerUi.value == 0
              ? 65 + Get.mediaQuery.padding.bottom
              : 0,
          maxHeight: size.height,
          isDraggable: !GetPlatform.isDesktop,
          controller: GetPlatform.isDesktop
              ? null
              : playerController.queuePanelController,

          /// This is the header of the minimized panel
          /// Contains the ^ button to expand the queue panel
          collapsed: InkWell(
            onTap: () {
              /// Queue opens in end drawer on desktop
              if (GetPlatform.isDesktop) {
                playerController.homeScaffoldkey.currentState!.openEndDrawer();
              } else {
                playerController.queuePanelController.open();
              }
            },
            child: Container(
                color: Theme.of(context).primaryColor,
                child: Column(
                  children: [
                    SizedBox(
                      height: 65,
                      child: Center(
                          child: Icon(
                        color: Theme.of(context).textTheme.titleMedium!.color,
                        Icons.keyboard_arrow_up,
                        size: 40,
                      )),
                    ),
                  ],
                )),
          ),

          /// Panel displaying the queue
          panelBuilder: (ScrollController sc, onReorderStart, onReorderEnd) {
            playerController.scrollController = sc;
            return Stack(
              children: [
                /// First child of Stack
                /// UpNextQueue widget displays the list of songs in the queue
                UpNextQueue(
                  onReorderEnd: onReorderEnd,
                  onReorderStart: onReorderStart,
                ),

                /// Second child of Stack
                /// This contains the bottom bar with options to loop the queue, shuffle, clear queue
                /// and shows the total number of songs in the queue
                /// BackdropFilter applies a blur effect to the background
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 80.0, sigmaY: 80.0),
                      child: Container(
                        padding: const EdgeInsets.only(
                            top: 15, bottom: 10, left: 10, right: 10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.5),
                        ),
                        height: 60 + Get.mediaQuery.padding.bottom,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              /// Displays the total number of songs in the queue
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

                              /// Queue loop toggle button
                              InkWell(
                                onTap: () {
                                  playerController.toggleQueueLoopMode();
                                },
                                child: Obx(
                                  () => Container(
                                    height: 30,
                                    padding: const EdgeInsets.symmetric(horizontal: 15),
                                    decoration: BoxDecoration(
                                      color: playerController.isQueueLoopModeEnabled.isFalse
                                          ? Colors.white24
                                          : Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(child: Text("queueLoop".tr)),
                                  ),
                                ),
                              ),

                              /// Shuffle queue button
                              InkWell(
                                onTap: () {
                                  if (playerController.isShuffleModeEnabled.isTrue) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        snackbar(context,
                                            "queueShufflingDeniedMsg".tr,
                                            size: SanckBarSize.BIG));
                                    return;
                                  }
                                  playerController.shuffleQueue();
                                },
                                child: Container(
                                  height: 30,
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Center(
                                      child: Icon(Icons.shuffle, color: Colors.black)),
                                ),
                              ),

                              /// Clear queue button
                              InkWell(
                                onTap: () {
                                  playerController.clearQueue();
                                },
                                child: Container(
                                  height: 30,
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Center(
                                      child: Icon(Icons.playlist_remove, color: Colors.black)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },

          /// Displays the player interface based on the selected player UI in settings
          /// Gesture-based player is only applicable for mobile
          body: settingsScreenController.playerUi.value == 0
              ? const StandardPlayer()
              : const GesturePlayer(),
        ),
      ),
    );
  }
}
