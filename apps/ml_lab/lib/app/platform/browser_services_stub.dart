import 'browser_services_contract.dart';

BrowserServices createBrowserServices() => _SessionBrowser();

class _SessionBrowser implements BrowserServices {
  String? _language;
  @override
  String? readLanguage() => _language;
  @override
  void writeLanguage(String value) {
    _language = value;
  }

  @override
  void setDocumentLanguage(String value) {}
  // Native platforms are outside this Web delivery; tests inject an opener.
  @override
  void openExternal(String url) {}
}
