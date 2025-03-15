import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:terminate_restart/terminate_restart.dart';

import 'package:harmonymusic/Services/audio_handler.dart';
import 'package:harmonymusic/Services/downloader.dart';
import 'package:harmonymusic/Services/music_service.dart';
import 'package:harmonymusic/Services/streamed_service.dart';
import 'package:harmonymusic/Screens/Home/home.dart';
import 'package:harmonymusic/Screens/Player/player_controller.dart';
import 'package:harmonymusic/Screens/Home/home_screen_controller.dart';
import 'package:harmonymusic/Screens/Library/library_controller.dart';
import 'package:harmonymusic/Screens/Search/search_screen_controller.dart';
import 'package:harmonymusic/Screens/Settings/settings_screen_controller.dart';
import 'package:harmonymusic/Theme/theme_controller.dart';
import 'package:harmonymusic/Utilities/app_link_controller.dart';
import 'package:harmonymusic/Utilities/get_localization.dart';
import 'package:harmonymusic/Utilities/system_tray.dart';
import 'package:harmonymusic/Utilities/update_check_flag.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();
  _setAppInitPrefs();
  startApplicationServices();
  Get.put<AudioHandler>(await initAudioService(), permanent: true);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  TerminateRestart.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if (!GetPlatform.isDesktop) Get.put(AppLinksController());
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == "AppLifecycleState.resumed") {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      } else if (msg == "AppLifecycleState.detached") {
        await Get.find<AudioHandler>().customAction("saveSession");
      }
      return null;
    });
    return GetMaterialApp(
        title: 'Harmony Music',
        home: const Home(),
        debugShowCheckedModeBanner: false,
        translations: Languages(),
        locale:
            Locale(Hive.box("AppPrefs").get('currentAppLanguageCode') ?? "en"),
        fallbackLocale: const Locale("en"),
        builder: (context, child) {
          final mQuery = MediaQuery.of(context);
          final scale =
              mQuery.textScaler.clamp(minScaleFactor: 1.0, maxScaleFactor: 1.1);
          return Stack(
            children: [
              GetX<ThemeController>(
                builder: (controller) => MediaQuery(
                  data: mQuery.copyWith(textScaler: scale),
                  child: AnimatedTheme(
                      duration: const Duration(milliseconds: 700),
                      data: controller.themedata.value!,
                      child: child!),
                ),
              ),
              GestureDetector(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: Colors.transparent,
                    height: mQuery.padding.bottom,
                    width: mQuery.size.width,
                  ),
                ),
              )
            ],
          );
        });
  }
}

Future<void> startApplicationServices() async {
  Get.lazyPut(() => PipedServices(), fenix: true);
  Get.lazyPut(() => MusicServices(), fenix: true);
  Get.lazyPut(() => ThemeController(), fenix: true);
  Get.lazyPut(() => PlayerController(), fenix: true);
  Get.lazyPut(() => HomeScreenController(), fenix: true);
  Get.lazyPut(() => LibrarySongsController(), fenix: true);
  Get.lazyPut(() => LibraryPlaylistsController(), fenix: true);
  Get.lazyPut(() => LibraryAlbumsController(), fenix: true);
  Get.lazyPut(() => LibraryArtistsController(), fenix: true);
  Get.lazyPut(() => SettingsScreenController(), fenix: true);
  Get.lazyPut(() => Downloader(), fenix: true);
  if (GetPlatform.isDesktop) {
    Get.lazyPut(() => SearchScreenController(), fenix: true);
    Get.put(DesktopSystemTray());
  }
}

initHive() async {
  String applicationDataDirectoryPath;
  if (GetPlatform.isDesktop) {
    applicationDataDirectoryPath =
        "${(await getApplicationSupportDirectory()).path}/db";
  } else {
    applicationDataDirectoryPath =
        (await getApplicationDocumentsDirectory()).path;
  }
  await Hive.initFlutter(applicationDataDirectoryPath);
  await Hive.openBox("SongsCache");
  await Hive.openBox("SongDownloads");
  await Hive.openBox('SongsUrlCache');
  await Hive.openBox("AppPrefs");
}

void _setAppInitPrefs() {
  final appPrefs = Hive.box("AppPrefs");
  if (appPrefs.isEmpty) {
    appPrefs.putAll({
      'themeModeType': 0,
      "cacheSongs": false,
      "skipSilenceEnabled": false,
      'streamingQuality': 1,
      'themePrimaryColor': 4278199603,
      'discoverContentType': "QP",
      'newVersionVisibility': updateCheckFlag,
      "cacheHomeScreenData": true
    });
  }
}
