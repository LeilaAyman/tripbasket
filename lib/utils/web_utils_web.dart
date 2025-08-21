import 'dart:html' as html;

class WebUtilsImpl {
  static void openUrlInNewTab(String url) {
    html.window.open(url, '_blank');
  }
  
  static void addWindowFocusListener(void Function() onFocus) {
    html.window.addEventListener('focus', (event) {
      onFocus();
    });
  }
}