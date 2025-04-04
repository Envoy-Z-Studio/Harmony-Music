import 'dart:io';

Future<void> generate() async {
  const filename = './lib/utils/get_localization.dart';

  String allLangData = "";

  var myDir = Directory('./lib/Localization');
  myDir.listSync(recursive: true, followLinks: false).forEach((entity) {
    if (entity.uri.toString().contains("generator")) {
      return;
    }
    String fileContent = (entity as File).readAsStringSync();
    allLangData =
        """$allLangData"${entity.uri.pathSegments.last.split(".")[0]}" : $fileContent,""";
  });

  String content = """
// This is auto generated file 
// Do not modify this file manually

import 'package:get/get.dart';
class Languages extends Translations {

@override
Map<String, Map<String, String>> get keys => {
  $allLangData
 };
}""";

  await File(filename).writeAsString(content, mode: FileMode.writeOnly);
}

void main() {
  generate();
}
