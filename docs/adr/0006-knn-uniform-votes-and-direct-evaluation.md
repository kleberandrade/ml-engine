# ADR 0006: Uniform KNN and direct lab evaluation

## Status

Accepted — November 17, 2026.

## Decision and numerical contract

Add KNNClassifier/KNNRegressor to the existing Estimator/Pipeline boundary. Fit validates k in 1..trainingRows and copies data atomically. Exact squared Euclidean ranking breaks distance ties by training row index. Classification uses uniform counts and resolves class ties by smallest finite numeric label. Regression uses the uniform mean. Duplicates remain separate rows, including exact matches. No inverse-distance weighting or probabilities are implied.

Reuse one small private neighbor-search implementation for both estimators. Brute-force distances plus sorting costs O(n*d+n log n) per query and O(n) temporary memory. A heap or KD-tree would add implementation complexity; neither is needed for the bounded teaching lab. Keep that limitation explicit instead of claiming large-data scalability.

## Lab ownership and presentation

KNN sessions store training rows at start and complete directly; they do not invent optimizer epochs, costs or pause/resume controls. A uses selected k, B uses 1, with identical train split and train-only standardization. The lab uses binary labels for its classification plot/metrics; the core also accepts multiclass numeric labels. New CSV data that cannot support selected k is rejected before replacing state, with translated feedback.

PlotBounds is shared by sampling and painting. Immutable PredictionSamples contain a 24×16 model-A classification grid or 60-point A/B regression slices. LabViewModel caches these by experiment state and invalidates them on start/replacement; painters receive values, never mutable KNN models. This prevents repeated neighbor search during paint or language/navigation rebuilds. Test/validation rows can establish display extent but never become neighbors or affect fitted scaling.

## Alternatives and limits

Keep synchronous fit/predict for the public core and bounded local UI; long or high-dimensional work requires a worker/isolate. Do not add a second state-management layer or external numerical backend. Distance weighting and indexed approximate search remain separate future features. Sampled curves connect discrete local predictions and do not imply differentiability; classification backgrounds show only A.

## Validation

Independent neighbor fixtures cover Euclidean ranking versus Manhattan, uniform regression, boundary/class ties, duplicates, k=1/k=n, ownership, rejected refits, invalid inputs and overflow. Session/widget tests cover train-only voting/scaling, k=1 comparison equality, instant completion without costs/timers, cached immutable samples, invalid CSV preservation, actual k slider interaction, locale/navigation preservation and Portuguese mobile layout at 150% text scale. Both analyzers, the architecture gate and release artifact are checked before publication.
