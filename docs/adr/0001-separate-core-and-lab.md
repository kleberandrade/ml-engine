# ADR-0001: Keep a pure Dart package and a feature-oriented Flutter application

## Status

Accepted for the user-requested restructuring; verifiable through imports, tests and the architecture check.

## Context

The root package already has a usable Dart API, but four broad core source files and a large Flutter page/controller combine multiple responsibilities. We need clearer ownership without breaking consumers of `package:ml_engine/ml_engine.dart` or introducing a package manager/framework that this small project does not need.

## Decision

Keep the Dart package at the repository root, split private implementation into data/models/preprocessing/pipeline/model_selection/metrics folders, and preserve its public export facade. Move the Flutter application to `apps/ml_lab`, documentation to `docs`, and group tests by the same responsibilities. Within the app, organize the experiment feature into data, domain, application and presentation.

Separate pure experiment sessions from the ChangeNotifier view model; keep timer lifetime and commands in the view model. Extract controls, chart/result/explanation cards, theme and painters. Pass immutable plot snapshots to painters and format typed scores in presentation. Enforce the dependency direction in CI.

## Consequences

Positive: numerical and UI tests remain independently executable; new models have an obvious home; UI changes do not change mathematical code; mutable training has one owner. Existing public Dart imports remain valid.

Costs: contributors must use the new app path and update tools/document links. The app intentionally has a few more files, with each representing an actual responsibility. Snapshot construction copies small bounded collections; this is acceptable for the 500×2 lab, and is not intended for arbitrary datasets.

## Alternatives considered

A full multi-package workspace would add migration/configuration overhead without an additional reusable package. Keeping `lab/` was technically valid, but the `apps/` namespace makes runnable clients distinct from the root library. Adding repositories/services or a new state-management package for only local generated/CSV data would not solve a current requirement.

## References

[Project architecture](../architecture.md), [Flutter architecture guide](https://docs.flutter.dev/app-architecture/guide).
