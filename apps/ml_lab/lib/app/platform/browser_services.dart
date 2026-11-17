import 'browser_services_contract.dart';
import 'browser_services_stub.dart'
    if (dart.library.js_interop) 'browser_services_web.dart'
    as platform;
export 'browser_services_contract.dart';

BrowserServices createBrowserServices() => platform.createBrowserServices();
