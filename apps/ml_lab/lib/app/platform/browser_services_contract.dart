abstract interface class BrowserServices {
  String? readLanguage();
  void writeLanguage(String value);
  void setDocumentLanguage(String value);
  void openExternal(String url);
}
