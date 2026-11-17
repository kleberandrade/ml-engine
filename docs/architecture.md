# Architecture and project layout

## Requirements

Maintain the existing pure Dart API and its numerical results while delivering a static Flutter Web demo under `/ml-engine/`. The lab must support seeded data, strict CSV validation, equal-budget comparisons, training lifecycle controls, readable charts and accessible desktop/mobile layouts. The deployment must run only after analysis, tests and a release build succeed. Training data stays in the browser; no backend is needed.

The bounded lab supports at most 500 rows and two features, yields between training iterations and uses immutable chart snapshots. Reproducibility, error recovery, dependency isolation and an understandable teaching codebase take priority over speculative extension layers.

## Layout

```text
ml-engine/
  lib/ml_engine.dart              public Dart facade (existing imports preserved)
  lib/src/
    data/                        matrix, dataset and numeric CSV boundaries
    models/                      estimator contract, gradient models and K-means++
    preprocessing/               transformer contract and scalers
    pipeline/                    train-fitted composition
    model_selection/             splits, folds and fresh-pipeline cross validation
    metrics/                     regression/classification scoring
  test/                          numerical tests grouped by core responsibility
  example/main.dart              executable Dart examples
  apps/ml_lab/
    lib/main.dart                entry point only
    lib/app/                     app composition, original branding, EN/PT-BR strings and browser adapters
    lib/features/experiments/
      data/                      synthetic generation and lab CSV policy
      domain/                    settings, typed scores and pure Dart training session
      application/               view model, timer lifetime and immutable plot snapshots
      presentation/              page, widgets, formatters and painters
    lib/features/learning/       bilingual topics, real executable presets and exercises
    test/features/experiments/    domain, application and presentation tests
    test/app/                    navigation, localization, keyboard and state-preservation tests
    web/                         Web shell and manifest
  docs/                          guides, decisions, evidence and screenshots
  tool/                          benchmarks and architecture validation
  .github/workflows/verify.yml   validation, tested artifact upload and Pages deploy
```

The root stays a conventional Dart package. The Flutter application consumes it with `path: ../..`; it is not a core runtime dependency. `example/` and `tool/` retain their standard Dart roles. Build outputs, generated package configuration and editor state remain ignored.

## Dependency direction

```mermaid
flowchart LR
    Entry[main.dart] --> App[App and theme]
    App --> View[Experiment page and widgets]
    View --> VM[LabViewModel]
    VM --> Data[Dataset generation and CSV boundary]
    VM --> Session[ExperimentSession]
    Data --> Core[Pure Dart ML Engine]
    Session --> Core
    VM --> Snapshot[Immutable PlotSnapshot]
    View --> Painter[Stateless chart painters]
    Painter --> Snapshot
    Format[Score formatters] --> Score[Typed experiment score]
    View --> Format
```

`LabViewModel` is the sole owner of the timer and training commands. Views configure it through validated commands; they cannot mutate settings fields directly. `ExperimentSession` owns the scaler, seeded split and A/B models; it emits typed scores rather than UI strings. Presentation formatters own wording and numeric display. Painters receive immutable numbers and sample labels, with no access to advance a training session.

A new CSV dataset is parsed and prepared before replacing active state. Failed imports preserve the old dataset and timer. Both K-means instances must initialize before a training session is installed. Failure is visible and synthetic data can recover the experiment. Disposal cancels pending updates.

`dart run tool/check_architecture.dart` enforces dependency direction: no framework/runtime package imports in the core, no Flutter or outward dependencies in data/domain, no presentation imports in application, and no mutable view model/session imports in painters. Numerical tests, timer tests and widget tests separately verify behavior; folder names alone are not architectural isolation.

## Decisions and operating limits

See [ADR 0001](adr/0001-separate-core-and-lab.md) and [ADR 0002](adr/0002-deploy-tested-pages-artifact.md). The view model follows Flutter's guidance on separating views and their state/commands, adapted to local deterministic data. There are no artificial service/repository layers for a nonexistent backend. ChangeNotifier is sufficient for one feature and avoids an additional state-management dependency.

Long or high-dimensional training still needs an isolate/worker. The 500-row lab limit and event-loop yielding are scoped to this teaching UI. The ML algorithms and public facade remain independent of Flutter, browser hosting and Pages permissions.

References: [Flutter architecture guide](https://docs.flutter.dev/app-architecture/guide), [Flutter Web deployment](https://docs.flutter.dev/deployment/web), [GitHub Pages custom workflows](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages).

## Bilingual navigation and learning

The app shell owns one LabViewModel for its lifetime and retains Laboratory/Learn/Examples pages in an IndexedStack. Locale selection rebuilds localized views without replacing the experiment or its CSV editor. The app's browser adapter persists only `ml-engine.language` when localStorage is available and synchronizes the document language for accessibility. Blocked storage falls back to session behavior; CSV data and models are not persisted or transmitted. Material UI localization delegates translate framework controls as well as project strings.

The learning feature adapts the actual `docs/design.md` and `docs/tutorial.md` into EN/PT-BR content, formulas, four real model/data presets and exactly five exercises. It does not embed a GitHub iframe or present roadmap algorithms as implemented. See [ADR 0003](adr/0003-bilingual-learning-shell.md).

The language controls use locally drawn circular Brazil/United Kingdom flags, selected-state rings, localized tooltips/semantics, keyboard operation and 48-pixel touch targets. The original drawings are code-native and make no runtime image requests.
