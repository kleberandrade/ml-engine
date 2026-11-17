# ADR 0004: Reject partial training state

## Status

Accepted — November 17, 2026.

## Context

Finite input does not guarantee finite arithmetic. A refit or iterative update can overflow after changing statistics or coefficients. The previous implementation could then expose a mixture of old and new state, even though the operation threw an exception. The lab catches these exceptions, but the public Dart core must also have a coherent recovery contract.

## Decision

Compute candidate scaler statistics, K-means++ initialization, gradient parameters and clustering updates locally. Commit them only after validation, including the resulting objective. Rejected operations preserve the state from before that operation. A successful `start` still deliberately resets a run; `fit` is not a transaction spanning every iteration. If a later iteration fails, the last completed update remains available.

A generic Pipeline cannot undo mutations inside arbitrary Transformer/Estimator implementations. Any failed pipeline fit therefore blocks pipeline `transform` and `predict` until a successful fit. Components belong to the composition and must not be refitted externally while the pipeline is in use. The public component references remain available for compatibility; the guard cannot intercept direct calls on them.

## Alternatives and trade-offs

- Ignoring failures leaves misleading predictions or nonfinite parameters: rejected.
- Cloning or serializing arbitrary model components would require new contracts and introduce complexity unrelated to this small toolkit: deferred.
- Clearing every standalone model after failure would discard usable completed iterations: rejected in favor of atomic operations.

Candidate arrays add temporary memory proportional to feature/centroid count. This is small for the bounded 500×2 teaching lab. The core remains synchronous and callers must move prolonged work off the UI thread.

## Verification

Regression tests exercise rejected scaler refits, failed K-means initialization, first/later gradient divergence, clustering cost overflow, pipeline invalidation and recovery. Existing independent numerical fixtures verify that successful training results are unchanged. This policy adds no dependencies or remote data handling.
