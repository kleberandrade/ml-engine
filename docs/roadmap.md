# Roadmap (not implemented)

This first delivery includes linear/logistic regression, K-means++, preprocessing, evaluation and the Flutter teaching lab. The following are future directions, not existing APIs or promised release dates.

1. Ridge regression with explicit regularization conventions and KNN with train-only scaling, distance policies and tie tests.
2. Decision trees, Random Forest and an original Gradient Boosting implementation, with deterministic sampling, overfitting demonstrations and independent fixtures.
3. PCA, feature selection and permutation importance, evaluated inside the training fold. Permutation importance measures score degradation under shuffling; correlated features complicate its interpretation.
4. Optional integrations with external backends only after versioning, licensing, portability and numerical compatibility are verified.
5. SHAP explanations as a separate research/integration effort. SHAP means Shapley-value-based feature attribution under specified assumptions; it is not a synonym for permutation importance, tree split gain or coefficients. No SHAP implementation is included.

An original Gradient Boosting implementation would not be the official XGBoost product, would not imply XGBoost model-format compatibility, and would not carry that product's performance or feature claims. A future XGBoost adapter must be explicitly named as such and tested separately.
