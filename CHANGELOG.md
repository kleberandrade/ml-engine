# Changelog

## Unreleased

- Preserve valid scaler/model state when numerical refits or individual training updates fail.
- Block pipeline transformation/prediction after a failed fit until recovery, preventing mixed preprocessing/model state.
- Add failure-recovery regression tests and a visible seed/preset synchronization check; detail Ridge, KNN and tree acceptance criteria in the roadmap.

- Add original vector branding, responsive navigation, EN/PT-BR controls/feedback/help, remembered language and an integrated project-based Learn guide.
- Add four executable presets, interpreted formulas and exactly five bilingual exercises while preserving experiments across navigation/locale changes.

- Publish the Flutter lab to GitHub Pages from a validated, repository-path build.
- Organize the core by responsibility and the Flutter app under `apps/ml_lab` by feature/layer; preserve the public Dart facade.
- Separate pure experiment sessions, immutable chart snapshots, timer commands, UI widgets and score formatting.
- Enforce architectural boundaries and add error/lifetime/snapshot tests.

## 0.1.0

Initial pure Dart classical ML core and Flutter Web laboratory. Linear/logistic gradient descent, K-means++, train-fitted scalers and pipelines, seeded splits/folds, metrics and cross validation. Includes independent numerical fixtures, interaction/accessibility tests, CLI examples and extension documentation. Source is available in the public GitHub repository. No pub.dev package has been published.
