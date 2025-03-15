import 'dart:async';

import 'package:flutter/material.dart';

import 'package:app_links/app_links.dart';
import 'package:get/get.dart';

import 'package:harmonymusic/Models/playing_from.dart';
import 'package:harmonymusic/Services/music_service.dart';
import 'package:harmonymusic/Helpers/navigation_helper.dart';
import 'package:harmonymusic/Screens/Player/player_controller.dart';
import 'package:harmonymusic/CustomWidgets/Common/loader.dart';
import 'package:harmonymusic/CustomWidgets/Common/snackbar.dart';
import 'package:harmonymusic/CustomWidgets/Common/songinfo_bottom_sheet.dart';
import 'package:harmonymusic/Utilities/helper.dart';

class AppLinksController extends GetxController with ProcessLink {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void onInit() {
    initDeepLinks();
    super.onInit();
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();

    // Check initial link if app was in cold state (terminated)
    final appLink = await _appLinks.getInitialAppLink();
    if (appLink != null) {
      await filterLinks(appLink);
    }

    // Handle link when app is in warm state (front or background)
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) async {
      await filterLinks(uri);
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }
}

mixin ProcessLink {
  Future<void> filterLinks(Uri uri) async {
    final playerController = Get.find<PlayerController>();
    if (playerController.playerPanelController.isPanelOpen) {
      playerController.playerPanelController.close();
    }

    if (Get.isRegistered<SongInfoController>()) {
      Navigator.of(Get.context!).pop();
    }

    if (uri.host == "youtube.com" ||
        uri.host == "music.youtube.com" ||
        uri.host == "youtu.be" ||
        uri.host == "www.youtube.com" ||
        uri.host == "m.youtube.com") {
      printINFO(
          "pathsegmet: ${uri.pathSegments} params:${uri.queryParameters}");
      if (uri.pathSegments[0] == "playlist" &&
          uri.queryParameters.containsKey("list")) {
        final browseId = uri.queryParameters['list'];
        await openPlaylistOrAlbum(browseId!);
      } else if (uri.pathSegments[0] == "shorts") {
        ScaffoldMessenger.of(Get.context!).showSnackBar(snackbar(
            Get.context!, "notaSongVideo".tr,
            size: SanckBarSize.MEDIUM));
      } else if (uri.pathSegments[0] == "watch") {
        final songId = uri.queryParameters['v'];
        await playSong(songId!);
      } else if (uri.pathSegments[0] == "channel") {
        final browseId = uri.pathSegments[1];
        await openArtist(browseId);
      } else if ((uri.queryParameters.isEmpty || uri.query.contains("si=")) &&
          uri.host == "youtu.be") {
        final songId = uri.pathSegments[0];
        await playSong(songId);
      }
    } else {
      ScaffoldMessenger.of(Get.context!).showSnackBar(snackbar(
          Get.context!, "notaValidLink".tr,
          size: SanckBarSize.MEDIUM));
    }
  }

  Future<void> openPlaylistOrAlbum(String browseId) async {
    if (browseId.contains("OLAK5uy")) {
      Get.toNamed(ScreenNavigationSetup.playlistNAlbumScreen,
          id: ScreenNavigationSetup.id, arguments: [true, browseId, true]);
    } else {
      Get.toNamed(ScreenNavigationSetup.playlistNAlbumScreen,
          id: ScreenNavigationSetup.id, arguments: [false, browseId, true]);
    }
  }

  Future<void> openArtist(String channelId) async {
    await Get.toNamed(ScreenNavigationSetup.artistScreen,
        id: ScreenNavigationSetup.id, arguments: [true, channelId]);
  }

  Future<void> playSong(String songId) async {
    showDialog(
        context: Get.context!,
        builder: (context) => const Center(
                child: LoadingIndicator(
              strokeWidth: 5,
            )),
        barrierDismissible: false);
    final result = await Get.find<MusicServices>().getSongWithId(songId);
    Navigator.of(Get.context!).pop();
    if (result[0]) {
      Get.find<PlayerController>().playPlayListSong(List.from(result[1]), 0,
          playfrom: PlaylingFrom(type: PlaylingFromType.SELECTION));
    } else {
      ScaffoldMessenger.of(Get.context!).showSnackBar(snackbar(
          Get.context!, "notaSongVideo".tr,
          size: SanckBarSize.MEDIUM));
    }
  }
}
