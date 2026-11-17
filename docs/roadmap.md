# Roadmap (not implemented)

This first delivery includes linear/Ridge/logistic regression, K-means++, preprocessing, evaluation and the Flutter teaching lab. The following are future directions, not existing APIs or promised release dates.

1. **KNN classification/regression next:** reuse the train-fitted scaler and existing estimator/pipeline boundary. Define Euclidean distance, uniform versus distance weighting, duplicate-point handling and deterministic class ties. Validate k against training rows and demonstrate the effect of k with independent neighbor fixtures.
2. **Decision tree before ensembles:** bounded depth, minimum leaf size, deterministic split ties, regression squared-error/classification impurity fixtures and explicit overfitting demonstrations. Only then add Random Forest and an original Gradient Boosting implementation, with deterministic sampling and independent fixtures.
3. PCA, feature selection and permutation importance, evaluated inside the training fold. Permutation importance measures score degradation under shuffling; correlated features complicate its interpretation.
4. Optional integrations with external backends only after versioning, licensing, portability and numerical compatibility are verified.
5. SHAP explanations as a separate research/integration effort. SHAP means Shapley-value-based feature attribution under specified assumptions; it is not a synonym for permutation importance, tree split gain or coefficients. No SHAP implementation is included.

An original Gradient Boosting implementation would not be the official XGBoost product, would not imply XGBoost model-format compatibility, and would not carry that product's performance or feature claims. A future XGBoost adapter must be explicitly named as such and tested separately.

Before adding a technique to Learn/Examples, require an implemented core API, independent numerical/edge-case tests, a bounded interactive preset, EN/PT-BR explanations, and passing Web CI. Keep regularization, feature selection and hyperparameter selection inside the training/validation boundary. These are planned acceptance criteria, not shipped features.

Technical references: [Ridge and its L2 objective](https://scikit-learn.org/stable/modules/linear_model.html#ridge-regression-and-classification), [nearest-neighbor methods and tie considerations](https://scikit-learn.org/stable/modules/neighbors.html), and [preprocessing/data leakage pitfalls](https://scikit-learn.org/stable/common_pitfalls.html). These describe the methods; ml-engine remains an independent Dart implementation, not a scikit-learn binding.
