# ML Engine Laboratory

See the [root README](../../README.md) for supported SDKs, commands, CSV conventions and validation evidence. This Flutter Web application uses the pure Dart core via a local path dependency.

[Open the hosted demo](https://kleberandrade.github.io/ml-engine/).

Run `flutter pub get`, `flutter test`, `flutter analyze`, and `flutter run -d chrome` from this directory. Training is timer-driven and bounded to two features and 500 samples; long-running jobs belong in an isolate/worker. Data is pasted locally and never uploaded by the application.
