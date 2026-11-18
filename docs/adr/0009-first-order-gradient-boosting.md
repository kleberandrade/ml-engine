# ADR 0009: First-order gradient boosting and observable stages

## Status

Accepted — November 17, 2026.

## Decision and conventions

Compose deterministic all-feature DecisionTreeRegressors in GradientBoostingRegressor and binary GradientBoostingClassifier. Parameters: nEstimators=100, maxDepth=3, minSamplesLeaf=1, learningRate=.1, with positive count/leaf, nonnegative depth and finite rate in (0,1]. Regression initializes mean(y), fits y−F and adds rate×tree, minimizing mean squared error / 2. Classification initializes log(p/(1−p)) with training p clipped to [1e-12,1−1e-12], fits y−sigmoid(F), and adds numeric regression-tree outputs to logits. Use stable sigmoid and binary cross entropy; probabilities >= .5 predict 1. Require binary 0/1 labels; no multiclass claim. Probabilities are uncalibrated model scores.

This is first-order gradient boosting without Newton terminal-leaf updates or line search, an intentional teaching convention rather than a claim of matching another package’s specialized TreeBoost algorithm. Use all training rows/features without bootstrap, subsampling or RNG. Tree positive-gain/greedy stopping remains. Build exactly the requested number of stages, including zero corrections; no automatic early stopping. Not XGBoost, and no file-format/performance equivalence claim. Missing/categorical routing, importance, pruning, histogram fitting and model persistence remain absent.

## Lifecycle and failures

Expose shared GradientBoostingModel lifecycle (private constructor), start, step, fit, immutable trees/lossHistory and initialPrediction. start owns a Dataset copy, initializes a constant prediction and one baseline loss; step returns true for each successfully added tree, false only at budget. Each stage builds a residual tree, new training scores and finite loss before replacing any state. fit trains a private candidate then installs its entire state. A rejected start/refit preserves the old model; a rejected step preserves the last complete stage. Retain copied training data for stepping, O(n*d), plus tree/history state. Each tree sorts selected data by feature at nodes. Core fit remains synchronous; use an isolate/worker for large work. Prediction is O(T*depth). Do not add a general ensemble framework until another consumer requires it.

## Lab integration

Keep core free of Flutter. Session owns two boosting models and uses the existing timer lifecycle: one real stage per tick, pause/resume/cancel/restart supported. Reuse immutable grid/curve prediction samples outside painters, recomputing during boosting rather than the direct-fit cache. Report domain BoostSummary values, never mutable models. Controls: tree count 1–25, depth 1–6, rate .01–.3; min leaf=2. A uses selected rate, B rate/4, same initial prediction/split/train-only scaler/count/depth. These are two boosting models, not forest/single-tree or optimizer-epoch comparisons. Presets use count25/depth3/rate.2. Display real stages and loss baseline at index0; distinguish MSE/2 or BCE from held-out RMSE/accuracy. Class grid depicts A only; regression is a 60-point slice at standardized x₂=0 with both generated features varying. No device-wide frame-time guarantee is made.

## Alternatives and verification

An atomic direct fit would simplify UI state but hide meaningful additive stages, so reuse the existing timer instead. Newton leaf updates, optimal step search and multiclass losses require separate numerical specifications; they are deferred explicitly.

Independent fixtures derive regression F0=6, first-stage predictions3.5/8.5 and MSE/2=3.625, second-stage2.25/9.75 and1.28125; classification starts at0 and adds±.25 at rate.5, with probability1/(1+exp(−.25)). Tests cover clipped priors/pure labels, resumable/fit equivalence, immutable snapshots, parameter/depth/leaf limits, failed refits/stages, ownership, deterministic reset and pipelines/CV. Lab checks cover train-only targets, independently fitted rate-only A/B, actual stages, pause/resume/cancel/settings, rejected CSV, three real sliders, locked active settings, PT/EN navigation and narrow150% text. Existing forest/tree results remain under regression tests.

Reference: [Friedman (2001)](https://doi.org/10.1214/aos/1013203451).
