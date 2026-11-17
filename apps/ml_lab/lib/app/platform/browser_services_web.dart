import 'dart:js_interop';

import 'browser_services_contract.dart';

@JS('document.documentElement.lang')
external set _documentLanguage(JSString value);

@JS('window.localStorage')
external _Storage get _storage;
@JS('window.open')
external JSAny? _open(JSString url, JSString target, JSString features);

@JS()
extension type _Storage(JSObject _) implements JSObject {
  external JSString? getItem(JSString key);
  external void setItem(JSString key, JSString value);
}

BrowserServices createBrowserServices() => _WebBrowser();

class _WebBrowser implements BrowserServices {
  static const _key = 'ml-engine.language';
  @override
  String? readLanguage() {
    try {
      return _storage.getItem(_key.toJS)?.toDart;
    } catch (_) {
      return null;
    }
  }

  @override
  void writeLanguage(String value) {
    try {
      _storage.setItem(_key.toJS, value.toJS);
    } catch (_) {
      /* Session language still works when storage is blocked. */
    }
  }

  @override
  void setDocumentLanguage(String value) {
    _documentLanguage = value.toJS;
  }

  @override
  void openExternal(String url) {
    _open(url.toJS, '_blank'.toJS, 'noopener,noreferrer'.toJS);
  }
}
