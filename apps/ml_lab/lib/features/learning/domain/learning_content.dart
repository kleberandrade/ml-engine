/// Adapted from docs/design.md and docs/tutorial.md. Only shipped algorithms.
class BilingualText {
  final String en, pt;
  const BilingualText(this.en, this.pt);
  String inLanguage(bool portuguese) => portuguese ? pt : en;
}

class LearningTopic {
  final BilingualText title, body, interpretation;
  final String formula;
  final String? formulaPt;
  final String? preset;
  const LearningTopic(
    this.title,
    this.body,
    this.formula,
    this.interpretation, {
    this.preset,
    this.formulaPt,
  });
}

const learningTopics = [
  LearningTopic(
    BilingualText('Foundations before fitting', 'Fundamentos antes do ajuste'),
    BilingualText(
      'A row is a sample; a column is a feature. Fit learns parameters, transform applies learned preprocessing and predict evaluates the fitted model. Seeded splits assume independent rows; time series or repeated subjects need a different split.',
      'Uma linha é uma amostra; uma coluna é uma variável. Fit aprende parâmetros, transform aplica o pré-processamento e predict usa o modelo ajustado. Divisões aleatórias pressupõem independência; séries temporais ou pessoas repetidas exigem outra estratégia.',
    ),
    'train → fit scaler + model → validate → final test',
    BilingualText(
      'Fit preprocessing only on training rows. Cross validation creates fresh scaler/model instances in every fold. Reserve test data until model selection is complete.',
      'Ajuste o pré-processamento apenas no treino. A validação cruzada cria uma escala e um modelo novos a cada partição. Reserve o teste até concluir a escolha dos parâmetros.',
    ),
    formulaPt: 'treino → ajustar escala e modelo → validação → teste final',
  ),
  LearningTopic(
    BilingualText('Linear regression', 'Regressão linear'),
    BilingualText(
      'The model predicts a real-valued target from a weighted sum of features plus an intercept. Full-batch gradient descent updates all coefficients once per iteration; the chart records cost after each update.',
      'O modelo prevê um alvo numérico pela soma ponderada das variáveis mais um intercepto. A descida de gradiente em lote atualiza todos os coeficientes uma vez por iteração; o gráfico registra o custo após cada atualização.',
    ),
    'ŷ = b + Σⱼ wⱼ xⱼ     J = mean((ŷ − y)²) / 2',
    BilingualText(
      'For y=3x+2, x=3 gives 11. The slope changes the prediction per input unit; the intercept is the prediction at zero. Smaller rates can converge slowly; large rates can diverge.',
      'Para y=3x+2, x=3 resulta em 11. A inclinação indica a mudança por unidade de entrada; o intercepto é a previsão em zero. Taxas menores podem convergir lentamente; taxas altas podem divergir.',
    ),
    preset: 'linear',
  ),
  LearningTopic(
    BilingualText('Binary logistic regression', 'Regressão logística binária'),
    BilingualText(
      'A linear score becomes the probability of class 1 through a stable sigmoid. This implementation supports binary labels 0 and 1 and uses the 0.5 decision threshold.',
      'Uma pontuação linear vira probabilidade da classe 1 por uma sigmoide numericamente estável. A implementação aceita rótulos binários 0 e 1 e usa o limiar de decisão 0,5.',
    ),
    'z = b + w·x     p = 1 / (1 + exp(−z))\nJ = −mean(y log p + (1−y) log(1−p))',
    BilingualText(
      'At z=0, p=0.5 and the predicted class is 1. Accuracy is the fraction correct. Precision measures how many predicted positives are correct; recall measures how many actual positives were found. F1 balances both. Check confusion counts on imbalanced data.',
      'Em z=0, p=0,5 e a classe prevista é 1. A acurácia é a fração de acertos. A precisão mede os acertos entre positivos previstos; a revocação mede os positivos reais encontrados. F1 equilibra ambas. Examine a matriz de confusão em dados desequilibrados.',
    ),
    preset: 'binary',
  ),
  LearningTopic(
    BilingualText(
      'K-means++ and centroid updates',
      'K-means++ e atualização dos centroides',
    ),
    BilingualText(
      'Choose the first center uniformly. Subsequent centers are sampled in proportion to squared distance from their nearest center. Assign points to their nearest center, then replace each center by the mean of its assigned points.',
      'Escolha o primeiro centro uniformemente. Os demais são amostrados proporcionalmente ao quadrado da distância ao centro mais próximo. Atribua cada ponto ao centro mais próximo e atualize cada centro pela média dos pontos atribuídos.',
    ),
    'P(center = xᵢ) = D(xᵢ)² / Σ D(x)²\ninertia = Σᵢ ||xᵢ − c(labelᵢ)||²',
    BilingualText(
      'For points (0,0),(0,2),(10,10),(10,12), two centers are (0,1) and (10,11), with inertia 4. Empty clusters retain their previous center. IDs are arbitrary; different seeds can reach different local minima. k cannot exceed the number of distinct locations.',
      'Para (0,0),(0,2),(10,10),(10,12), dois centros são (0,1) e (10,11), com inércia 4. Grupos vazios mantêm o centro anterior. Os IDs são arbitrários; sementes diferentes podem chegar a mínimos locais diferentes. k não pode superar a quantidade de posições distintas.',
    ),
    preset: 'clusters',
  ),
  LearningTopic(
    BilingualText(
      'Scaling, pipelines and honest evaluation',
      'Escalas, pipelines e avaliação justa',
    ),
    BilingualText(
      'StandardScaler uses population variance and maps training constants to zero. MinMaxScaler uses the training minimum and range; held-out values can fall outside [0,1]. Compare equal budgets on the same split and use validation to choose settings.',
      'StandardScaler usa variância populacional e transforma constantes do treino em zero. MinMaxScaler usa mínimo e amplitude do treino; valores reservados podem sair de [0,1]. Compare o mesmo orçamento na mesma divisão e escolha parâmetros pela validação.',
    ),
    'x′ = (x − mean_train) / std_train\nRMSE = √mean((ŷ−y)²)     R² = 1 − SSE/SST',
    BilingualText(
      'In the lab, A/B use one train-fitted scaler and split. Linear cost is MSE/2, not RMSE; clustering validation is mean squared distance, not classification accuracy. Stratified K-fold requires at least k examples per class. Constant-target R² is 1 for perfect predictions and 0 otherwise.',
      'No laboratório, A/B usam a mesma escala ajustada no treino e a mesma divisão. O custo linear é MSE/2, não RMSE; a validação dos grupos é distância quadrática média, não acurácia. K-fold estratificado exige pelo menos k exemplos por classe. R² com alvo constante vale 1 em previsões perfeitas e 0 nos demais casos.',
    ),
    preset: 'csv',
  ),
];

class LearningExercise {
  final BilingualText title, objective, completion;
  const LearningExercise(this.title, this.objective, this.completion);
}

const learningExercises = [
  LearningExercise(
    BilingualText(
      '1. Recover known coefficients',
      '1. Recupere coeficientes conhecidos',
    ),
    BilingualText(
      'Generate y=4x−2 and fit a standardized pipeline.',
      'Gere y=4x−2 e ajuste um pipeline padronizado.',
    ),
    BilingualText(
      'Absolute prediction error is below 0.001 at three unseen x values.',
      'O erro absoluto é menor que 0,001 em três valores de x não vistos.',
    ),
  ),
  LearningExercise(
    BilingualText('2. Observe convergence', '2. Observe a convergência'),
    BilingualText(
      'Compare two rates on the same regression seed and split.',
      'Compare duas taxas com a mesma semente e divisão de regressão.',
    ),
    BilingualText(
      'Record both validation RMSE values and verify the iteration count freezes while paused.',
      'Registre os dois RMSE de validação e confirme que a contagem para durante a pausa.',
    ),
  ),
  LearningExercise(
    BilingualText(
      '3. Inspect classification errors',
      '3. Examine erros de classificação',
    ),
    BilingualText(
      'Use an imbalanced binary fixture and a train-majority baseline.',
      'Use um exemplo binário desequilibrado e a referência da maioria do treino.',
    ),
    BilingualText(
      'Report TP, TN, FP, FN, precision, recall and F1, including a zero-denominator case using the Dart API.',
      'Informe VP, VN, FP, FN, precisão, revocação e F1, incluindo denominador zero com a API Dart.',
    ),
  ),
  LearningExercise(
    BilingualText('4. Prevent leakage', '4. Evite vazamento de dados'),
    BilingualText(
      'Evaluate five fresh StandardScaler/LinearRegression pipelines.',
      'Avalie cinco pipelines novos de StandardScaler/LinearRegression.',
    ),
    BilingualText(
      'Every row is held out once; no fold overlaps its training rows or reuses fitted components.',
      'Cada linha fica reservada uma vez; não há sobreposição com treino nem reutilização de componentes ajustados.',
    ),
  ),
  LearningExercise(
    BilingualText(
      '5. Investigate clustering stability',
      '5. Investigue a estabilidade dos grupos',
    ),
    BilingualText(
      'Fit K-means++ with three seeds at the same k and budget.',
      'Ajuste K-means++ com três sementes, mesmo k e mesmo limite.',
    ),
    BilingualText(
      'Record inertia/centroids, explain arbitrary IDs and verify identical points with k>1 are rejected.',
      'Registre inércia e centroides, explique IDs arbitrários e confirme a rejeição de pontos idênticos com k>1.',
    ),
  ),
];
