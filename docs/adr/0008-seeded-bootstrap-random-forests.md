# ADR 0008: Seeded bootstrap Random Forests

## Status

Accepted — November 17, 2026.

## Decision

Implement RandomForestClassifier and RandomForestRegressor as Estimator, composed from existing numeric trees. Parameters: nEstimators=100, maxDepth=5, minSamplesLeaf=1, maxFeatures=null, seed=42. Null maxFeatures resolves to max(1,floor(sqrt(d))) for both tasks, an explicit convention that differs from some libraries. For every tree, draw n row indices with replacement then a tree seed from the seeded forest RNG. A separate tree RNG samples a fresh subset without replacement at each eligible node, sorting selected indices before deterministic split scoring. Increasing tree count preserves the earlier bags/seeds. Defaults on standalone DecisionTree remain all features, preserving previous results.

Use uniform hard votes over tree class predictions with smallest-label ties, and mean tree predictions for regression. Do not present votes as probabilities. Numeric finite multiclass labels work in core; lab remains binary. Strict feature subsets stop a node when no selected feature has positive gain, without a broader fallback search; positive-gain and greedy/XOR limitations remain. Bootstrap duplicates count as distinct entries for leaf minima. Depth starts at zero. No pruning, OOB estimate, calibrated probabilities, feature importance or categorical/missing routing is added.

Build all roots and metadata locally before committing any forest state. Expose deeply immutable roots, bag indices and tree seeds. Retaining indices costs O(T*n) integers; raw rows are not retained. Prediction costs O(T*depth) per row; training repeats tree sorting and is synchronous. Large workloads require an isolate/worker rather than promising responsiveness. Reproduction is within the same Dart SDK, not a cross-version RNG guarantee.

## Lab integration

Reuse direct-fit session completion, immutable sampled plots and cache invalidation. Add forest classification/regression with 1–25 trees, depth 1–6, minimum leaf size 2, n=90 on generated 150-row 60/20/20 data. A is the forest; B is an all-feature, unbootstrapped tree trained on the same train rows/scaler at the selected depth. One forest tree is still different from B. Show aggregate counts/max actual depth/total leaves/features per split/bootstrap size and separate B depth/leaves, never one tree’s root as a forest-wide rule. No timer, fake history, optimizer rate or epochs is used. Both input features vary in regression; plot values are a conditional slice at standardized x₂=0, not predictions at every observed x₂.

## Verification and alternatives

Independent depth-zero bootstrap means and hard-vote tie fixtures verify aggregation. Reconstruct a one-tree forest from recorded bags/seeds; verify prefix/determinism, per-node feature redraws, min leaves, invalid inputs, ownership and atomic recovery after a later candidate fails numerically. Session/widget checks verify train-only targets, same-depth reference, count-one difference, two meaningful regression inputs, cached immutable plots, count/depth limits, rejected CSV preservation, actual sliders, PT/EN state preservation and narrow 150% text. Existing tree defaults remain under regression tests. Avoid a general ensemble framework until another implementation needs it.

Reference: [Breiman (2001), Random Forests](https://www.stat.berkeley.edu/~breiman/randomforest2001.pdf). No equivalence to any other implementation’s default predictions is claimed.
