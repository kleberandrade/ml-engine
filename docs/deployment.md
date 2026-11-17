# Flutter laboratory on GitHub Pages

Demo URL: **https://kleberandrade.github.io/ml-engine/**.

## Reproduce the deployment build

From the repository root, resolve both packages, run the checks, and build the Flutter app:

```sh
dart pub get --enforce-lockfile
cd apps/ml_lab
flutter pub get --enforce-lockfile
cd ../..
dart run tool/check_architecture.dart
dart analyze
dart test
cd apps/ml_lab
flutter analyze
flutter test
flutter build web --release --no-wasm-dry-run --no-web-resources-cdn --web-content-hash --base-href /ml-engine/
cd ../..
python3 tool/check_web_build.py
```

The base href must include both slashes. This build is intended for the repository subpath, not the root of a local HTTP server. For a local root preview, omit `--base-href /ml-engine/` or mount the build directory at that subpath. The root README includes the local command.

## Deployment lifecycle

The repository's Pages source is GitHub Actions. Verify resolves the committed lockfiles, checks format/import boundaries, runs both analyzers/test suites and the CLI, and builds one release artifact. A static artifact check verifies the base href, content-hashed entry point, manifest assets and bundled CanvasKit. Only a successful main run uploads that artifact and runs the dependent Pages deployment job. PRs/tags cannot deploy; deployment permissions are restricted to the deployment job. The github-pages environment records the deployed revision and URL.

The custom Flutter bootstrap does not register Flutter's deprecated service worker. JavaScript/assets use content hashes; CanvasKit and fallback fonts are bundled. This reduces reliance on runtime CDNs and stale worker state. GitHub Pages controls HTTP caching, so a newly deployed shell may require revalidation before all clients see the new version. Offline installation is not promised.

For operational verification, use `python3 tool/check_web_build.py --url https://kleberandrade.github.io/ml-engine/`, inspect the actual browser UI and review the [workflow](https://github.com/kleberandrade/ml-engine/actions/workflows/verify.yml). HTTP success alone does not prove training or controls work; browser verification is recorded below after publication.

No pub.dev publication, backend service, account registration or paid hosting is part of this deployment. The app computes locally; CSV datasets are not submitted to a server.
