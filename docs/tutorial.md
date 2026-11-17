# Learn classical ML through observable experiments

Start with the CLI example and run the numerical tests. The first regression fixture uses y=3x+2, so a prediction at x=3 must approach 11. Because the expected value comes from algebra, the test can reveal an incorrect implementation instead of merely comparing the model with itself.

Open the Flutter lab with `cd apps/ml_lab && flutter run -d chrome`. Linear regression adjusts a line to reduce mean squared error. The displayed cost is half MSE, matching the derivative used by the optimizer. Lowering the learning rate slows convergence; too high a rate can diverge. Scaling reduces imbalance among feature magnitudes, but scaling itself must learn only from training rows.

Open **Ridge vs linear**. A uses Ridge and B linear, with the same zero initialization, train-fitted scale, split, learning rate and iteration budget. Move λ to zero: both histories and predictions match exactly. Increase λ to shrink the coefficient norm on the seeded correlated-feature example. Ridge minimizes `mean((ŷ−y)²)/2 + λ||w||²/2`, with no penalty on the intercept. The two costs optimize different objectives, so choose λ using validation RMSE rather than chart height. A strong penalty can underfit; improved test performance is not guaranteed. Lines hold x₂ at its training mean and are partial slices, not projections of the full two-feature surface.

Switch to logistic classification. A linear score becomes a probability through the sigmoid; a 0.5 threshold separates the two classes. The colored regions show model A's decisions. Compare both models' validation accuracy and learning curves with the majority-class baseline. A high accuracy on imbalanced data can conceal missed positive cases; inspect the core's precision, recall, F1 and confusion counts as well.

Switch to clustering. K-means++ samples seeds using squared distance, then alternates assignment and centroid updates. A seed can change the local solution. Cluster IDs have no semantic class meaning. The curves show training inertia, while validation reports mean squared distance to the learned centers. Compare equal k values before attributing a lower score to better initialization.

Paste CSV only after selecting the task. The strict numeric header is `x1,x2,y`; the lab accepts 10–500 rows, rejects invalid values and preserves existing data on errors. Classification targets must be 0 or 1; clustering ignores the target. Regression lines show a slice at the training mean of x2, so two-feature CSV relationships need that interpretation.

Pause stops the timer, Resume continues the same model, Cancel preserves a partial result, and Restart clears training while retaining the current dataset. Training and controls are separate from the Dart mathematics. The lab yields between bounded iterations rather than calling a long synchronous fit loop.

Validation chooses settings. The test score appears only at the end, but repeatedly inspecting it still contaminates selection. For more robust estimation, use K-fold with a fresh pipeline factory. Use stratified folds for binary class balance when each class has at least k rows. For time-correlated or grouped samples, design a different splitter before training.

## References and credits

The implementation's numerical conventions are documented in [design.md](design.md); [example/main.dart](../example/main.dart) is executable. The original algorithms are ordinary least squares and Ridge via gradient descent, binary logistic regression and k-means++/Lloyd iteration. For the k-means++ method, see Arthur and Vassilvitskii, “k-means++: The Advantages of Careful Seeding” (SODA 2007). Flutter and Dart dependencies retain their own licenses. Screenshots depict the real local Web build, not a conceptual rendering.

## Five practical exercises

1. **Recover known coefficients.** Generate y=4x−2, fit a standardized pipeline, and predict three unseen values. Completion: absolute prediction error below 0.001 for every value.
2. **Observe regularization.** Compare Ridge λ=0, 1 and 3 with linear on the same seed, split, rate and budget. Completion: record validation RMSE and coefficient norms, verify identical histories at λ=0, and show that pausing does not add iterations.
3. **Inspect classification errors.** Build an imbalanced binary fixture and compare the model with a train-majority baseline. Completion: report TP, TN, FP, FN, precision, recall and F1, including a zero-denominator case.
4. **Prevent leakage in cross validation.** Evaluate a fresh StandardScaler/LinearRegression pipeline in five folds. Completion: every row appears in one held-out fold, no fold overlaps its training rows, and no fitted component is reused.
5. **Investigate clustering stability.** Fit K-means++ on the same dataset with three seeds and the same k/budget. Completion: record inertia and centroid locations, explain arbitrary cluster IDs, and verify that all-identical input with k>1 is rejected.
