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

### Circular language controls

The subsequent UI follow-up replaces the dropdown with locally drawn circular Brazil and United Kingdom flags, clear selected rings/semantics, localized tooltips and 48-pixel focusable buttons. The ten affected UI tests passed sequentially, including keyboard selection, state/draft preservation and narrow-screen text scaling. Analysis and the Pages release build passed; the unchanged numerical core retains its verified 17 tests. The full app suite now contains 20 cases and is run by the publication workflow.

## Final bilingual/flag browser verification

[Successful bilingual/flag build and deploy](https://github.com/kleberandrade/ml-engine/actions/runs/44179124350) published application commit `ea6197f86e1f2753cb4f79897f270331a8b39eb5`. The same public URL was opened in Chrome, not inferred from a successful HTTP response. The navbar rendered the original rising-seed mark and recognizable circular UK/Brazil drawings, with selected rings and localized accessible names.

The real paused regression remained at **73 iterations** after selecting Portuguese, visiting Learn and returning to Laboratory; its CSV draft remained exactly `x1,x2,y` / `1,0,3` / `2,0,5`. The document language became `pt-BR`. Reloading retained Portuguese while starting a fresh experiment, as designed. A real Examples-page CSV preset opened 20 rows with a 12/4/4 split. A Learn-page experiment button opened the real seeded 150-row linear lab.

At **390×844**, the compact logo, circular flags, menu and Portuguese educational text/formulas were readable with no layout overflow. The menu was used to open Learn; five objective/completion exercises and real source-reference links were present. Keyboard flag/menu behavior is covered by the Flutter tests; this browser pass used the native accessibility/pointer controls. The Documentation button actually opened `docs/design.md` on GitHub in a separate tab. The temporary viewport override was reset, the documentation tab was closed, and the working demo was retained. No warning/error console entries were captured in the final app session.

The source now has **17 core tests and 20 Flutter tests**, both analyzers clean, an enforced architectural boundary check and a validated repository-path release artifact. The flag follow-up reran the ten affected UI cases sequentially plus analysis/build; the unchanged core evidence was reused locally and all tests were rerun by CI. Current core line coverage is **310/324 = 95.7%**. No pub.dev publication occurred.

Fresh captures of the final published UI:

- [English lab, logo and flags](images/pages-bilingual-en.jpg)
- [Portuguese lab](images/pages-bilingual-lab-pt.jpg)
- [State preserved after language/navigation](images/pages-bilingual-paused-pt.jpg)
- [Learn in Portuguese](images/pages-learn-pt.jpg)
- [Executable examples](images/pages-examples-pt.jpg)
- [Mobile Portuguese Learn](images/pages-mobile-learn-pt.jpg)


## Ridge 0.2.0 publication

[CI/Pages run 44184785601](https://github.com/kleberandrade/ml-engine/actions/runs/44184785601) passed for application commit `423fd82247fe324fae884d0260cb95916b6dfd5c`, including all 57 tests, package dry run, both analyses and the release artifact. Actual public browser checks on November 17, 2026 confirmed:

- The Ridge/linear mode, lambda slider, coefficient norms and objective-comparison caveat appear in both languages. Pausing at 71 iterations and switching PT→EN→PT kept the count at 71 and the same metrics.
- At lambda=1 after 250 iterations on seed 42, validation RMSE A/B was 1.370/0.478 and coefficient norm A/B was 1.453/2.234. Test RMSE was 1.159/0.432. These are observations on one synthetic fixture; shrinkage does not guarantee improved test error.
- Dragging lambda to zero and retraining gave validation RMSE 0.478 for both, coefficient norm 2.234 for both, and final test RMSE 0.432 for both, with overlapping curves. Exact equality is also asserted in numerical/session tests.
- Learn shows the Ridge formula, unpenalized intercept, mean-loss convention, five exercises and a working Ridge preset. Opening that preset restored lambda=1 and the ready state.
- At 390×844, Portuguese regularization controls and help fit the viewport. The temporary viewport override was reset. Captured app console warnings/errors were empty.
- The public shell and six runtime asset URLs returned successfully after deployment. The artifact contains 28 manifest entries.

Fresh actual captures: [English comparison](images/pages-ridge-en.jpg), [Portuguese lambda=1](images/pages-ridge-pt.jpg), [lambda=0](images/pages-ridge-zero.jpg), [mobile controls](images/pages-ridge-mobile.jpg).

The Dart core was also published to [pub.dev 0.2.0](https://pub.dev/packages/ml_engine/versions/0.2.0) with explicit user authorization. The public archive hash/core sources were verified and a separate hosted-dependency project executed an independently known Ridge fixture. See [publication metadata](pub-v0.2.0.json). The Flutter app remains non-publishable to pub.dev. Later evidence/README commits use the same application code and receive their own CI run.
