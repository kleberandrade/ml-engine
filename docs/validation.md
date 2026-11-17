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

## Architecture and Pages follow-up

The active layout is documented in [architecture.md](architecture.md) and the live demo in [deployment.md](deployment.md). Core source and tests now follow responsibility-based folders while preserving the public export facade. The Flutter app is in `apps/ml_lab`, with pure sessions, typed scores, timer commands and immutable chart inputs separated from widgets. Both analyzers and the architecture gate pass. That initial restructuring stage had 16 core tests and 13 Flutter tests after the responsive-draft regression fix. The new Pages workflow deploys only its successfully tested artifact. See the deployment record for public HTTP/browser checks and captures, distinct from the original local evidence above.

## Bilingual navigation and learning validation

The expanded version has **17 passing core tests** and **19 passing Flutter tests**, clean analyses and a successful repository-path release build. Current core line coverage is **310/324 = 95.7%** after adding locale-neutral CSV error metadata. The app tests cover a paused experiment and draft surviving locale/Learn navigation, all four real presets, stored language, keyboard menu navigation, translated row errors, translation placeholder contracts, exactly five bilingual exercises, and Portuguese learning/navigation at actual 150% text scale on 390×844. Browser adapters are injected in VM tests; live storage, SVG branding and Web navigation are verified on the actual deployment as recorded in deployment.md.

The final circular-flag follow-up brings the app suite to **20 cases**. [Remote run 44179124350](https://github.com/kleberandrade/ml-engine/actions/runs/44179124350) passed the complete verification and Pages deployment. The actual public desktop/mobile, language persistence, unchanged paused state, examples and source-link checks are recorded with fresh screenshots in [deployment.md](deployment.md). Subsequent evidence-only commits do not change application code; their own CI/deploy runs remain available through the README badge.


## Final architecture review — November 17, 2026

The failure-recovery revision passes **23 Dart tests and 21 Flutter tests (44 total)**, both analyzers, formatting and the architecture gate. The CLI numerical examples retain their recorded results. The sequential release build succeeds with `/ml-engine/`, bundled CanvasKit and a content-hashed entry point; the artifact checker verifies all 28 manifest entries. Dependency catalog checks are unchanged: no compatible upgrades are available. Previous coverage percentages above belong to their stated revisions; coverage was not remeasured for this patch.

Four newly written recovery scenarios failed against the previous code and passed after correction. Additional tests cover later-iteration divergence, clustering cost overflow and seed/preset UI consistency. Atomic operations preserve completed state; failed pipeline refits require a successful fit before use. See [ADR 0004](adr/0004-reject-partial-training-state.md). No visual UI change was made; earlier actual desktop/mobile captures remain historical evidence rather than a new browser test. Publication is gated by the repository's Verify workflow, whose current result is linked by the README badge.


## Ridge 0.2.0 validation

The Ridge revision has **31 passing core tests and 26 passing Flutter tests (57 total)**. Both analyzers and the architecture gate pass. Core fixtures independently derive w=(1,−1.5), b=1 and J=3.25 for an orthogonal system with lambda=1; the second one-feature step gives w=.17 and J=.37335 at lambda=2. Tests also cover exact zero-lambda history equality, duplicated-row invariance, collinear columns, an unpenalized constant-target intercept, invalid lambda/shapes/targets, penalized objective overflow and pipeline/CV integration.

Lab tests prove identical histories/coefficients/validation scores at lambda=0, smaller coefficient norm for lambda=3, equal iteration budgets, train-only scaling and continuous-target CSV. Widget tests exercise the actual slider, its disabled state while paused, locale/state preservation, the executable Ridge preset and Portuguese 390×844 content at 150% text scale. No new coverage percentage is claimed. Publication verification is tracked by the Verify workflow and package release endpoints; no upload is counted from a dry run.


The remote [Ridge CI and Pages run](https://github.com/kleberandrade/ml-engine/actions/runs/44184785601) passed on `423fd82`. Actual desktop/mobile, language, pause, zero-lambda and preset checks plus fresh captures are in [deployment.md](deployment.md). Pub.dev accepted ml_engine 0.2.0; its archive hash and matching core sources were checked, and an independent consumer installed the hosted package and obtained w≈0.5, b=0 for a known lambda=1 fixture. See [pub-v0.2.0.json](pub-v0.2.0.json). These are real upload/consumer checks, not dry-run evidence.

## KNN 0.3.0 validation

The KNN revision passes **39 core tests and 32 Flutter tests (71 total)**. Numerical fixtures verify Euclidean versus Manhattan ranking, uniform means/votes, k=1/k=n, row-order boundary ties, smallest-label class ties, duplicate/exact-match behavior, owned training data, rejected-refit recovery, invalid k/shapes/nonfinite data, distance overflow and a representable large-target mean. A CLI fixture predicts 5 from the two nearest targets 0 and 10.

New session/widget checks verify that held-out labels never vote, both tasks match their k=1 comparison, scaling is train-only, oversized-k and nonbinary CSV errors preserve completed results, and immutable sampled plots are cached/invalidate on changes. The actual slider, direct evaluation with no iterative controls/history, locale/navigation state and Portuguese mobile content at 150% text scale are covered. No new coverage or device-wide timing percentage is claimed. Live/publication evidence is recorded separately after deployment; a local test or dry run is not an upload.


The [remote KNN CI/Pages run](https://github.com/kleberandrade/ml-engine/actions/runs/44187769406) passed on `05557d4`. Actual live bilingual classification/regression, slider/k=1 equality, retained results, mobile controls and Learn preset checks are recorded with captures in [deployment.md](deployment.md). Pub.dev accepted 0.3.0; its public archive hash and exact core-source match were checked. An independent hosted consumer installed the public package and produced class=1.0 and regression=5.0. Initial index propagation failures were resolved through an explicit official-client refresh/download before claiming successful consumption. No new coverage percentage is claimed.
