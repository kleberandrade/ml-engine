import 'package:ml_lab/app/platform/browser_services.dart';

class MemoryBrowser implements BrowserServices {
  String? language;
  final opened = <String>[];
  @override
  String? readLanguage() => language;
  @override
  void writeLanguage(String value) {
    language = value;
  }

  @override
  void setDocumentLanguage(String value) {}
  @override
  void openExternal(String url) {
    opened.add(url);
  }
}
