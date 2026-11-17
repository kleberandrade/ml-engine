# ADR 0007: Greedy numeric decision trees

## Status

Accepted — November 17, 2026.

## Decision

Expose DecisionTreeClassifier/DecisionTreeRegressor through Estimator with maxDepth (default 5) and minSamplesLeaf (default 1). Classification reduces weighted Gini; regression reduces weighted squared error using Welford prefix/suffix moments. Sort each numeric feature at every node and evaluate adjacent distinct-value thresholds. Midpoints use low/2+high/2; if rounding reaches high, fall back to low so routing remains consistent.

A split must improve impurity by more than 1e-12 of the parent impurity. Equal gains within that tolerance favor feature index, then threshold. Root depth is zero; maxDepth=0 is a constant leaf. Pure targets, insufficient child rows and no useful threshold stop growth. Class leaves use majority votes with smallest numeric label on ties; regression leaves use means. Greedy search deliberately does not explore zero-gain XOR splits and is not globally optimal.

Build the whole tree before replacing fitted state. Expose immutable DecisionTreeNode values with sample counts, impurity, rules and children plus actual depth/leaf count; retain no input rows after fitting. Reject nonfinite arithmetic instead of installing partial state. No pruning, missing/categorical handling, probabilities, random splitting or extrapolation trend is implied.

## Lab integration and alternatives

Reuse direct evaluation, immutable sampled plots and the view model cache already used by KNN. Rename internal sample/cache fields to describe direct-fit models generally; numerical models never enter painters. Trees fit synchronously and complete directly without artificial epochs, cost history or pause controls. A uses selected depth 1–6, B depth 1, both with at least two training rows per leaf and the same train split/scaler. Show actual depth/leaves and A's first rule with explicitly rounded display values.

Trees do not require scaling, but the shared train-only standardization keeps lab axes consistent. Classification grids show only A. Regression steps use 60 samples at standardized x₂=0; sample boundaries are illustrative rather than exact tree threshold positions. More depth can fit noise; model selection stays on validation data.

A complete graphical tree editor, pruning subsystem, categorical encoding and ensemble framework would add unrelated complexity: deferred. Prefix/suffix scoring avoids rescoring every child from scratch; training still sorts features per node and is synchronous. Large/deep training belongs in an isolate/worker. Prediction costs O(depth) per row.

## Verification

Independent fixtures derive Gini 0.5→0 at threshold 1.5 and regression MSE 26→1 with leaf means 1/11. Tests cover depth zero and deeper fits, leaf-size bounds, pure/constant data, multiclass ties, equal gains, zero-gain XOR, input ownership, rejected-refit recovery, extreme and adjacent-double thresholds, invalid inputs and pipeline/CV. Session/widget checks cover train-only fitting, depth-one equality, cached immutable plots, depth/binary-label boundaries, actual slider interaction, translated rules, retained state and narrow Portuguese text at 150% scale.
