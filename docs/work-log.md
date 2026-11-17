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

The requested crapper, dryer and mutator tools were not available in the installed tool inventory. No CRAP score, duplication score or mutation-testing success is claimed. Behavioral fixtures, analyzer checks, line coverage and direct UI inspection were used, with their distinct limits recorded. At the initial local handoff, GitHub Actions was prepared but not remotely executed. The authorized publication follow-up below records the later remote execution.

## Authorized GitHub publication follow-up

1. Received explicit authorization to create public `kleberandrade/ml-engine`, apply prepared metadata, push main, verify CI and add badges/tags. The prohibition on pub.dev publication remains in force.
2. Created the public repository using the existing authenticated GitHub credential without exposing or storing it. Applied the prepared description and all eight topics; verified the owner, public visibility and main default branch.
3. Added the origin remote and pushed the existing local history. The first remote run failed formatting because the Flutter package was not resolved before the cross-package format check.
4. Reproduced the failure in a clean archive, then resolved the lab package and observed the same check pass with zero source-format changes. Committed the workflow setup-order fix as `037c521`, preserving every validation gate.
5. Verified successful [remote run 44170406586](https://github.com/kleberandrade/ml-engine/actions/runs/44170406586): format, both analyzers, both test suites, CLI examples and release Flutter Web build.
6. Added linked CI/release/toolchain/license badges, repository and issue URLs, public-source documentation, and v0.1.0 source-release notes. Prepared the annotated version tag for the publication commit; the GitHub release and workflow pages provide the final external audit trail.
7. Kept pub.dev disabled and made no hosted-demo or native/Wasm support claim. Changes are limited to this repository; no shared Flutter SDK was modified.

## Pages and architecture follow-up

1. Received explicit authorization to publish the Flutter lab on GitHub Pages, add the demo link and restructure the project using development/architecture practices. Checked the clean tree and existing origin/main before changing files. No sibling project or shared SDK was modified.
2. Preserved the root Dart package and public `ml_engine.dart` facade. Split implementation and tests into data, models, preprocessing, pipeline, model selection and metrics. Moved the app to `apps/ml_lab` and documentation to `docs`, updating dependency paths, ignores, CI and instructions together.
3. Split the Flutter app into composition/theme plus an experiment feature with data, pure domain sessions, application state/timer ownership and presentation widgets/formatters/painters. Replaced mutable settings fields with validated commands and mutable-model painter inputs with immutable snapshots.
4. Added tests before implementing the new session boundary and observed the expected missing-API failure. Preserved independent numerical fixtures and added typed-score, deterministic-data, active-import preservation, disposal, immutable-snapshot and invalid-clustering recovery checks. A later test exposed unsupported one-feature sessions; added a two-feature domain guard and rechecked it.
5. Added recommended Dart lints, an executable architecture gate and two decision records. Injected a temporary outward domain import, verified the gate failed, removed the probe and verified the clean source passed. Reviewed the refactor for behavioral/API preservation, ownership, dependency direction, lifecycle errors and deployment permissions; the 500-row main-thread teaching limit remains explicit.
6. Built the Pages subpath with bundled rendering resources and content hashes. Added a custom bootstrap without deprecated service-worker registration. The artifact check verified the base path, hashed entry point and every manifest asset before deployment.
7. Enabled HTTPS workflow-based GitHub Pages using the existing authenticated GitHub connection. Extended Verify so only a successful main run uploads and deploys the tested artifact, with Pages/OIDC write permissions restricted to deployment. PRs/tags cannot publish the site.
8. Updated the README and Portuguese guide with the demo URL and new layout. Retained exactly five tutorial exercises, the MIT license, existing v0.1.0 tag and both `publish_to: none` safeguards. Dependency limits remain documented; no pub.dev action was performed.
9. Publication/browser verification and fresh screenshots are recorded in deployment.md after the first successful Pages deployment.
