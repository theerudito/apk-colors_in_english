import 'dart:io';

import 'package:flutter/foundation.dart';

class AdsStrings {
  static String get bannerAdUnitId {
    if (!kIsWeb && Platform.isAndroid) {
      return 'ca-app-pub-7633493507240683/4104100763';
    } else if (!kIsWeb && Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return '';
  }
}
