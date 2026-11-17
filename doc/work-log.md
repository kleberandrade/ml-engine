# Work log

## 2026-11-17

1. Read root AGENTS.md, the shared modernization standard and the explicitly requested ub-mode skill. Checked for equivalent local projects and project-specific instructions. `teachable-ml-flutter` is an image-classification app, not this classical ML toolkit; it was preserved. No existing ml-engine directory, Git history or remote was present.
2. Checked sibling repository identity without changing sibling files. Chose a new isolated ml-engine directory. No other chat's source files were touched, so no shared-file write coordination was needed.
3. The global Flutter/Dart launchers attempted shared SDK writes. Copied the existing stable Flutter 3.50.0 SDK and package cache into task-owned temporary paths instead. Suppressed analytics and redirected Flutter config state. Did not modify a shared SDK.
4. Wrote behavioral numerical fixtures before the first implementation. Initial execution was blocked by tool telemetry/cache writes; resolved those environment problems before recording any pass. Added a later pipeline transform regression test, observed the missing-method failure, implemented the method, and verified it passed.
5. Implemented validated matrix/target boundaries, seeded partitions/folds, two train-fitted scalers, reusable estimator contracts, gradient models, stable binary loss, K-means++ and evaluation. Kept every core import independent of Flutter.
6. Added independently derived single- and multi-feature regression expectations, one-step logistic likelihood, separated-pair cluster inertia, hand-calculated metrics, constant/degenerate cases, immutable results and fold reuse checks. All 16 tests passed; core analysis was clean. Ran the CLI example and collected line coverage (95.3%).
7. Built a separate Flutter lab with generated datasets and bounded CSV import, timer-driven incremental training, equal-budget A/B experiments, validation/test separation, plots and explanatory text. Added lifetime cancellation and pause/resume/restart behavior.
8. Wrote widget/controller interaction and accessibility tests. The first executable run found a mobile header overflow. Changed the header to a wrapping layout; the five tests then passed, including 1.5 text scale, touch targets and text contrast.
9. Ran stable catalog checks. Core dependencies were current. Upgraded lab vector_math to 2.4.4. Retained two incompatible transitive versions required by Flutter 3.50, without overrides, and documented them. Reran lab analysis/tests/build after the upgrade.
10. Built the release Web application. The optional Wasm probe stalled under restricted execution; disabled that probe and successfully built JavaScript/CanvasKit. No Wasm claim is made. Started a localhost-only server for actual Chrome testing.
11. Inspected regression, classification and clustering in Chrome. Exercised training, Pause, Resume, Cancel and narrow-screen navigation. Added explicit A/B binary boundaries and corrected the clustering legend to avoid calling clusters classes. Saved real screenshots; reset the temporary browser viewport afterward.
12. Measured native and Node/V8 numerical workloads at the lab's maximum 500-row size. Saved raw results and explicitly excluded rendering/scheduling from the claim. JavaScript timer granularity is documented.
13. Wrote English documentation, a Portuguese quickstart, numerical policies, glossary, extension guide, MIT license, original vector cover, changelog and a tutorial ending with exactly five exercises. No existing Medium lesson or editorial session was supplied; no Medium edit/publication is claimed.
14. Prepared a GitHub workflow, description and eight topics. Direct public endpoint checks returned 404 for the provisional package and repository names. Did not reserve, create or publish either identity. Existing projects' push authorization was not reused for this new repository.
15. Initialized local main and committed the verified Dart core (`1a2a7a9`). Kept lab/docs/verification evidence in a separate following commit. No credentials, temporary SDK/cache, build products or coverage intermediates are tracked.

## Available-tool limits

The requested crapper, dryer and mutator tools were not available in the installed tool inventory. No CRAP score, duplication score or mutation-testing success is claimed. Behavioral fixtures, analyzer checks, line coverage and direct UI inspection were used, with their distinct limits recorded. GitHub Actions is prepared, not remotely executed.

## Remaining external step

Obtain authorization specific to creating `kleberandrade/ml-engine`, including the desired visibility, then create the remote, apply doc/github-metadata.json, push main, and verify remote CI before adding any status badge. Do not publish to pub.dev as part of that step. Source remains fully usable locally.
