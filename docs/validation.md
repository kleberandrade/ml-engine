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

## Decision tree 0.4.0 validation

The tree revision passes **49 Dart tests and 38 Flutter tests (87 total)**, both analyses and the architecture gate. Hand-derived fixtures check Gini 0.5→0 at threshold 1.5 and regression MSE 26→1 with leaf means 1/11. Other cases cover zero/deeper depth, recursive leaf bounds, pure/constant data, class/split ties, greedy zero-gain XOR behavior, owned/immutable fitted state, rejected refits, invalid inputs and extreme/adjacent-double thresholds. CLI results match the same analytical values.

Session/widget tests verify training rows alone determine trees, exact depth-one comparison, no invented cost history/timer, bounded depths, binary CSV protection, cache invalidation/immutability, actual depth-slider interaction, translated root rules, retained results through locale/navigation and Portuguese 390×844 content at 150% text scale. Existing KNN/Ridge/linear/logistic/clustering behavior remains covered. No new coverage percentage is claimed. Build/publication/browser results are recorded separately after verification.


[Remote tree CI/Pages](https://github.com/kleberandrade/ml-engine/actions/runs/44191198810) passed on `5b2ec74`. Actual bilingual rules/metrics, retained state, depth-slider equivalence, mobile controls and executable Learn preset checks are recorded with fresh captures in [deployment.md](deployment.md). The public 0.4.0 archive matches the core and an isolated hosted consumer reproduced threshold=1.5, classes=[0,1], means=[1,11]. See [pub-v0.4.0.json](pub-v0.4.0.json). No new coverage or generalized performance percentage is claimed.

## Random Forest 0.5.0 local verification (November 17, 2026)

The latest suite supersedes earlier historical counts: 60 Dart tests (including 11 new forest cases) and 44 Flutter tests (including four forest session and two widget cases). Core/Flutter analyzers, architecture boundary gate and the executable CLI example pass. The forest CLI independently computes a mean of bootstrap means and recovers 4.533333333333333. Regression tests cover actual later-tree numerical failure preserving all previous roots/bags/seeds, not just invalid-input rejection. Lab tests cover train-only fitting, same-depth full-training reference, count-one non-equivalence, two varying regression inputs, seeded repeats, count/depth boundaries, immutable cache invalidation, binary CSV preservation, real sliders, locale/navigation state and 390×844 at 150% text. No coverage percentage is inferred from test count.

Compatible dependency catalog reports were refreshed: direct versions remain current for the selected toolchain; material_color_utilities 0.13.0 and test_api 0.7.14 remain constrained by Flutter 3.50.0 despite newer catalog versions. No overrides or SDK changes were applied. Tests and release build do not run concurrently; only the isolated SDK/cache was used. Public CI, Pages inspection and package evidence are recorded after verification.

Local Pages release build succeeded; the artifact gate verifies base `/ml-engine/`, 28 manifest assets, content-hashed entry point and bundled CanvasKit.

## Random Forest public verification

[Source CI and Pages 44195689312](https://github.com/kleberandrade/ml-engine/actions/runs/44195689312) succeeded for `edd52e0d270a8af581801419f3b644701575170a`, tagged v0.5.0. Pub.dev accepted 0.5.0 at 23:04:16 UTC; the 28,770-byte archive SHA-256 matches the API and all 22 core source files match locally. See [archive evidence](pub-v0.5.0.json). The package excludes app/docs/tool/GitHub workflow files. No credentials or new publishing permissions were added to GitHub.

The real public browser exercised both forest tasks, count 15→1, depth 3→6, fitting/reset, PT/EN retained scores, Learn navigation and the executable regression preset, plus 390×844 controls/menu. With seed 42 / 15 trees / depth 3, classification validation accuracy was A=90.0%, B=76.7%; regression validation RMSE was A=0.550, B=0.487. These are observations on the shipped fixture, not evidence that forests always outperform one tree. Actual screenshots are under docs/images/pages-forest-*.jpg. A separately cached bootstrap initially kept old version labels; the follow-up uses Flutter’s official inline bootstrap and checks the inline application hash. The published core is unchanged by this delivery fix.

[Cache-fix CI/Pages 44196728893](https://github.com/kleberandrade/ml-engine/actions/runs/44196728893) and [tag CI 44196273158](https://github.com/kleberandrade/ml-engine/actions/runs/44196273158) succeeded. Final browser inspection confirmed the guide identifies core 0.5.0 with exactly five exercises; the viewport override was reset. An isolated hosted dependency consumer downloaded 0.5.0 with the official Dart client and executed both forest APIs: seven-tree depth-zero regression 5.928571428571428 versus independently computed bootstrap mean 5.928571428571429 within 1e-12; class 7 recovered exactly. Initial older-index responses were retried after propagation and are not counted as successful installation.

## Gradient Boosting 0.6.0 local checks

69 core tests and 50 Flutter tests pass locally (119 total), including nine new numerical/lifecycle and six new lab tests. Regression expectations3.5/8.5, MSE/2=3.625 and second-stage2.25/9.75 are independently derived; binary stage logits±.25 and sigmoid probabilities are computed from algebra. Failure recovery covers candidate fit rejection and an overflowing residual-tree stage, preserving prior snapshots. Session/widget checks verify train-only targets, exact rate-only A/B against independent core fits, real stage counts, pause/resume/cancel, settings/CSV preservation, three actual sliders, active-control locking, PT/EN retained state and 390×844 at150% text. No coverage percentage is inferred. Public publication/browser results will be recorded only after verification.

Both analyzers and the architecture gate pass. The CLI recovers boosting predictions [3.5,8.5] and loss 3.625. The JavaScript/CanvasKit Pages release builds successfully; the artifact gate confirms the inline content-hashed bootstrap, base /ml-engine/, 28 manifest assets and bundled CanvasKit. Compatible dependency reports were refreshed; only Flutter-constrained material_color_utilities 0.13.0 and test_api 0.7.14 remain below newer catalog versions, without overrides. Final review found no unresolved correctness or dependency-direction issue; stated limits (binary first-order classification, no automatic selection, synchronous core fit) remain explicit.

## Gradient Boosting public verification

[Source CI/Pages 44207476092](https://github.com/kleberandrade/ml-engine/actions/runs/44207476092) succeeded for `bc411e8321b56ea57596b6767b59959d8b9bb40c`, identified by v0.6.0. [Tag CI 44208093996](https://github.com/kleberandrade/ml-engine/actions/runs/44208093996) also passed. Pub.dev accepted 0.6.0 at 2026-11-18 00:26:07 UTC (November 17 locally); the 32,491-byte archive SHA-256 matches the API and all 23 core source files match the validated commit. A separate hosted consumer installed the package with the official Dart client without a path dependency and recovered regression [3.5,8.5], MSE/2=3.625, classes [0,1] and positive probability 0.5621765008857981 = sigmoid(.25), within 1e-12. Initial older-index responses were retried after propagation; failed attempts are not counted as installation success. See [public archive and consumer evidence](https://github.com/kleberandrade/ml-engine/blob/main/docs/pub-v0.6.0.json). The app/docs/tool/workflow files remain excluded from the package. Later documentation/image commits do not change or republish the immutable core archive.

The real Pages browser exercised both boosting modes and all three sliders: tree count 25→1, depth 3→1, rate .20→.30 reset the previous result; training then completed exactly1/1 stage with two history points. In classification, Pause held 11/25 stages and loss 0.4384; changing language and visiting Learn preserved the paused model; Resume reached 25/25. On seed42/count25/depth3/rate .20, classification validation accuracy A/B=90.0%/76.7%, final test83.3%/80.0%, A training BCE0.2861. Regression validation RMSE A/B=0.209/0.488, final test0.332/0.614, A training MSE/2=0.0064. These observations describe the shipped synthetic fixture, not guaranteed performance or evidence to select parameters on the final test.

Actual PT/EN screenshots are pages-boost-classification-en.jpg, pages-boost-classification-pt.jpg, pages-boost-regression-pt.jpg, pages-boost-one-tree.jpg and pages-boost-mobile.jpg. Browser inspection verified 390×844 controls/menu, the 13 executable presets, Learn core version 0.6.0, the two boosting topics and exactly five final exercises. The regression Learn preset restored 25 trees/depth3/rate .20, then completed; the viewport override was reset. No captured browser warn/error console entries appeared. The public inline shell and 5 runtime URLs passed the HTTP gate; local artifact has 28 manifest assets. Mobile 150% text is verified by widget tests, not a claim that the native browser was zoomed.
