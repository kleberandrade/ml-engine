# Verified local validation — November 17, 2026

## Environment and scope

Dart 3.14.0 and Flutter 3.50.0 (`ab2912035e`), macOS. The globally installed Flutter attempted to write to its shared SDK and was not used. A copy-on-write copy of the existing stable SDK was used at `/tmp/ml-engine-flutter`; the package cache was also copied into `/tmp/ml-engine-pub-cache`. The source SDK was not modified. Flutter analytics/tool state was redirected or suppressed. The compiled release is JavaScript/CanvasKit; Wasm dry-run was disabled after the optional probe stalled in the restricted environment. No Wasm, mobile or desktop app validation is claimed.

## Results

- `dart analyze`: no issues.
- `dart test`: 16 passing tests. Line coverage: **303/318 = 95.3%**, collected with `dart test --coverage=coverage` and `coverage:format_coverage --report-on=lib`. This is line coverage, not branch or mutation coverage.
- `dart run example/main.dart`: test RMSE 4.481562076656638e-14, prediction at x=50 approximately 152, five-fold MSE on the order of 1e-27; logistic classes [0,1]; cluster inertia 4.
- `flutter analyze`: no issues.
- `flutter test`: 5 passing tests: pause/resume/cancel/restart; all experiments completing; rejected CSV preservation/import cancellation; desktop interaction and 390×844 layout at 1.5 text scale; labeled touch targets, text contrast and Android touch-target guidelines.
- `flutter build web --release --no-pub --no-wasm-dry-run`: successful. `--no-pub` used after resolving committed lockfiles.
- Actual Chrome inspection at local port 8769: regression completed 250 updates (test RMSE A/B 0.389), classification completed (test accuracy A 93.3%, B 86.7%), clustering converged in 3 updates (test mean squared distance A/B 0.207). These are observations for seed 42's synthetic fixture, not general performance claims.
- Actual browser Pause kept the classification counter fixed; Resume advanced it; Cancel preserved its partial curve. 390×844 setup and results screens were inspected, then the viewport override was reset.

The first mobile test exposed a header overflow. Replacing its single horizontal row with a wrapping layout fixed it; all five widget tests subsequently passed. The initial widget run could not bind its required localhost socket, so the runner was reexecuted with local socket access. No failed attempt is counted as a pass.

## Independent expected values and tolerances

Tests derive regression predictions and multivariate orthogonal coefficients algebraically, not from the implementation. GD tolerances range from 1e-7 for an extrapolated fitted prediction to 1e-12 for the orthogonal design after 400 iterations; the remaining geometric optimizer error is below those bounds. The one-step logistic fixture derives w=0.1 and cross entropy `log(1+exp(-0.1))` independently (1e-14 tolerance). Cluster centroids are means of two separated pairs; the exact expected inertia is 4 (1e-10 tolerance). Metric fractions use manually calculated residuals/confusion counts with 1e-12 tolerance. Seeds are checked for reproducibility, and folds are checked for disjointness, coverage and class balance. Constant targets/features, all-identical points, invalid labels, NaN, wrong shapes, reused pipelines and unfitted objects are covered.

## Dependencies

`dart pub outdated --json` reported no outdated packages for the core. The lab was upgraded to vector_math 2.4.4. `material_color_utilities` remains 0.13.0 (catalog 0.13.1) and `test_api` remains 0.7.14 (catalog 0.7.15), constrained by the chosen Flutter 3.50 toolchain and its UI/test packages. No overrides force incompatible versions. Direct dependencies test 1.33.0, material_ui 1.11.1 and flutter_lints 6.0.0 match the resolved stable catalog at validation time. JSON catalog reports are stored alongside this record.

## Responsiveness evidence and limits

[Native benchmark](benchmark-native.json) and [JavaScript benchmark](benchmark-js.json) measure two logistic updates on 500×2 data plus a 600-point probability grid, repeated 500 times. Native median 52 μs / p95 75 μs; Node/V8 JS p95 1 ms, maximum including warmup 2 ms. JS timer resolution produces a zero median; that means below timer resolution, not zero work. These microbenchmarks exclude Flutter layout, painting, accessibility, browser scheduling and slower devices. The lab yields every iteration and caps input size; the browser controls were exercised during training. This does not promise a frame-time budget on all devices or arbitrary datasets. The synchronous core `fit` is unsuitable for prolonged main-thread work.

## Publication status

The user explicitly authorized public repository creation and main-branch push on November 17, 2026. [kleberandrade/ml-engine](https://github.com/kleberandrade/ml-engine) is now public with the prepared description and eight topics. At the repository-publication stage, no hosted demo was deployed. The subsequent Pages publication is recorded in [deployment.md](deployment.md). No pub.dev upload or Medium publication was created; `publish_to: none` remains in both manifests.

The first remote run exposed a clean-checkout setup bug: formatting the lab before resolving its package configuration changed formatter behavior. This was reproduced locally in an archive without `.dart_tool`, then corrected by resolving both packages before checking formatting. No formatting gate was removed. [CI run 44170406586](https://github.com/kleberandrade/ml-engine/actions/runs/44170406586) passed on commit `037c521`: format checks, both analyzers, Dart and Flutter tests, CLI examples and release Web build. The main-branch CI badge links to subsequent runs, including the publication documentation commit. GitHub release notes are in [release-v0.1.0.md](release-v0.1.0.md); no pub.dev release is part of this publication.

Public endpoint requests initially returned 404 for the package and repository names. The repository has since been created with explicit authorization; the package lookup does not reserve a pub.dev name. CI uses actions/checkout@v6 and subosito/flutter-action@v2 (see [upstream examples](https://github.com/subosito/flutter-action)).

## Visual evidence

Screenshots are actual Chrome captures of the release build. The SVG cover is an original conceptual vector illustration and is labeled accordingly.

- [Regression](images/regression-desktop.jpg)
- [Classification](images/classification-desktop.jpg)
- [Paused classification](images/classification-paused.jpg)
- [Mobile setup](images/mobile-setup.jpg)
- [Mobile results](images/mobile-results.jpg)
- [Clustering](images/clustering-desktop.jpg)
