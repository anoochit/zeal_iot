import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

bool validateEmail(String value) {
  if (!value.contains(RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"))) {
    return true;
  } else {
    return false;
  }
}

int getGridSized(double scWidth) {
  return (scWidth > 1024)
      ? 6
      : (scWidth > 760)
          ? 4
          : 2;
}

void launchURL(String url) async => await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';

Future<void> deleteCacheDir() async {
  final cacheDir = await getTemporaryDirectory();

  if (cacheDir.existsSync()) {
    cacheDir.deleteSync(recursive: true);
  }
}

Future<void> deleteAppDir() async {
  final appDir = await getApplicationSupportDirectory();

  if (appDir.existsSync()) {
    appDir.deleteSync(recursive: true);
  }
}

Future<String> loadAsset(String asset) async {
  return await rootBundle.loadString(asset);
}
