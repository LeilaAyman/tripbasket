import 'package:flutter/foundation.dart';
import 'web_utils_stub.dart' if (dart.library.html) 'web_utils_web.dart';

class WebUtils {
  static void openUrlInNewTab(String url) {
    WebUtilsImpl.openUrlInNewTab(url);
  }
  
  static void addWindowFocusListener(void Function() onFocus) {
    WebUtilsImpl.addWindowFocusListener(onFocus);
  }
}