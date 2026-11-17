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

## Published browser verification — November 17, 2026

[First successful build and deploy](https://github.com/kleberandrade/ml-engine/actions/runs/44173523525) published commit `91ee1e5`. The deployed shell had the expected `/ml-engine/` base href. The bootstrap, hashed JavaScript entry point, Web manifest and bundled CanvasKit JS/Wasm returned HTTP 200. The local artifact check verified all 32 manifest entries. The repository homepage and README link point to the actual HTTPS demo.

Actual Chrome verification on the public URL, using only synthetic/fixture data:

- Regression completed 250 iterations and reported test RMSE 0.389 for both models. Pause froze the counter at 76; Resume and Cancel preserved a partial 92-iteration run. Restart restored READY and zero history.
- A CSV containing NaN was rejected with a row-specific error while the preceding dataset/results remained intact. A valid 20-row `y=2*x1+1` fixture imported into a 12/4/4 split; training completed with displayed test RMSE A 0.000 and B 0.130.
- Binary classification completed with seed-42 synthetic test accuracy A 93.3%, B 86.7%; the boundary and scores were readable at 390×844.
- K-means++ converged in three updates, with displayed test mean squared distance 0.207 for A/B; centroids and held-out rows rendered correctly.
- No warning/error console entries were captured during this initial browser session. The viewport override was reset after mobile inspection.

The mobile transition exposed a CSV-editor draft-loss regression. A new widget test first reproduced it; the page now preserves the stateful controls while the layout reparents them. Local analysis was clean and all 13 Flutter tests passed after the fix. Numerical core tests still total 16, with the existing independent fixtures and 95.3% line coverage. The test explicitly asserts actual 150% text scaling, rather than only wrapping a MediaQuery.

Visual evidence from the published site:

- [Regression and cost curve](images/pages-regression.jpg)
- [Paused training](images/pages-paused.jpg)
- [CSV rejection](images/pages-csv-error.jpg)
- [Mobile classification](images/pages-mobile-classification.jpg)
- [Clustering](images/pages-clustering.jpg)
