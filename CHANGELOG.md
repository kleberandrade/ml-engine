## 0.5.0

- Add RandomForestClassifier/Regressor: seeded n-row bootstrap, fresh per-node feature subsets, uniform hard votes / means, count/depth/leaf controls and immutable roots/bag indices/tree seeds.
- Extend decision trees with opt-in maxFeatures/seed; defaults retain the all-feature behavior. Default forest maxFeatures is floor(sqrt(d)), at least one, for both tasks.
- Keep refits atomic, including numerical failure after partially building a forest. Document strict subset stopping, tie rules and synchronous/memory limits.
- Add PT/EN Flutter forest modes, count/depth sliders, comparison with a single full-training all-feature tree at equal depth, honest aggregate summaries and two-feature regression samples.
- Add core numerical/sampling/recovery tests and session/widget checks for leakage, deterministic results, controls, cache invalidation, locale/navigation and mobile text scaling.

# Changelog

## 0.4.0

- Add `DecisionTreeClassifier` (weighted Gini) and `DecisionTreeRegressor` (squared error) with max depth, minimum leaf size, deterministic split/vote ties and immutable fitted nodes.
- Preserve previous models on failed fits; handle rounded/extreme midpoints and expose root rules, actual depth and leaf counts.
- Add PT/EN tree lab modes, depth controls, comparison with depth 1, sampled regions/steps and executable lessons/presets.
- Reuse direct evaluation and cached immutable plot samples without artificial optimizer controls.
- Add independent numerical, stopping, leakage, recovery, locale/navigation and mobile tests.

## 0.3.0

- Add pure Dart `KNNClassifier` and `KNNRegressor` with Euclidean distance, uniform vote/mean, deterministic row/class ties, copied training data and validation.
- Add binary KNN classification and continuous-target regression lab modes, k controls, equal-data comparisons with k=1, sampled plots and EN/PT-BR lessons/presets.
- Show direct evaluation rather than artificial optimizer controls/history; cache immutable KNN plot samples outside painters.
- Add numerical, leakage, cache, error-recovery, navigation, localization and mobile tests.

## 0.2.0

- Add `RidgeRegression(lambda: ...)`, mean-loss L2 regularization, an unpenalized intercept and exact lambda-zero equivalence with linear regression.
- Add Ridge/linear lab comparisons, correlated-feature data, regularization controls, coefficient norms and EN/PT-BR learning content/presets.
- Add independent numerical fixtures and Ridge session/widget tests; prepare a core-only pub.dev archive.


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
