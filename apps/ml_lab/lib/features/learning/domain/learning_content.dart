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
    BilingualText('Ridge and L2 regularization', 'Ridge e regularização L2'),
    BilingualText(
      'Ridge adds a squared-weight penalty to the mean linear loss. The intercept is excluded. Both models use the same training split, scaler, rate and iterations; only Ridge has the penalty. Scaling changes what a unit coefficient means, so fit it on training rows only.',
      'Ridge adiciona uma penalização quadrática dos pesos à perda linear média. O intercepto fica de fora. Os modelos usam a mesma divisão, escala, taxa e iterações; só Ridge tem a penalização. A escala muda o significado de um coeficiente unitário e deve ser ajustada apenas no treino.',
    ),
    'J = mean((ŷ − y)²)/2 + λ||w||²/2\n∂J/∂w = Xᵀ(ŷ − y)/n + λw; ∂J/∂b = mean(ŷ − y)',
    BilingualText(
      'λ=0 is exactly linear regression. On centered x=−1,+1 and y=−1,+1, λ=1 gives w=0.5 and b=0. Larger λ trades fit for smaller coefficient norm, not guaranteed accuracy. Select it by validation; objective heights differ because Ridge includes a penalty. This mean-loss convention corresponds to alpha=n*lambda in a sum-loss definition.',
      'λ=0 é exatamente regressão linear. Com x=−1,+1 e y=−1,+1 centrados, λ=1 resulta em w=0,5 e b=0. Um λ maior troca ajuste por menor norma dos coeficientes, sem garantir acurácia. Escolha pela validação; a altura dos custos difere porque Ridge inclui a penalização. Esta perda média corresponde a alpha=n*lambda na definição por soma.',
    ),
    preset: 'ridge',
  ),
  LearningTopic(
    BilingualText('Decision tree classification', 'Árvore de classificação'),
    BilingualText(
      'Greedily choose an axis-aligned feature/threshold split that reduces weighted Gini impurity. Numeric values at or below the threshold go left. Each leaf predicts its majority label, choosing the smallest numeric label in a vote tie.',
      'Escolha de forma gulosa a variável e o limiar que reduzam a impureza Gini ponderada. Valores numéricos iguais ou inferiores ao limiar seguem à esquerda. Cada folha prevê a maioria, escolhendo o menor rótulo numérico no empate.',
    ),
    'Gini = 1 − Σ p(class)²\nGain = I(parent) − nL/n I(left) − nR/n I(right)',
    BilingualText(
      'For x=[0,1,2,3] and y=[0,0,1,1], Gini drops from 0.5 to 0 at x≤1.5. Root depth is zero; depth 1 permits one split. The lab compares selected depth with depth 1, both with at least 2 training rows per leaf. Actual depth may be smaller. Equal gains prefer feature index then threshold; pure nodes, small leaves or no positive gain stop growth. Greedy search is not globally optimal and rejects zero-gain XOR splits.',
      'Para x=[0,1,2,3] e y=[0,0,1,1], Gini cai de 0,5 para 0 em x≤1,5. A raiz tem profundidade zero; profundidade 1 permite uma divisão. O laboratório compara seu limite com 1, ambas com ao menos 2 linhas de treino por folha. A profundidade efetiva pode ser menor. Ganhos empatados preferem índice de variável e limiar; pureza, folhas pequenas ou ausência de ganho param o crescimento. A busca não é ótima globalmente e rejeita divisões XOR com ganho zero.',
    ),
    preset: 'tree-classification',
  ),
  LearningTopic(
    BilingualText('Decision tree regression', 'Árvore de regressão'),
    BilingualText(
      'Choose splits by weighted squared-error reduction; predict the mean training target of the reached leaf. A depth limit and a minimum leaf size constrain complexity. More depth can memorize noise; use validation to choose the limit.',
      'Escolha divisões pela redução ponderada do erro quadrático; preveja a média dos alvos de treino na folha alcançada. Profundidade e tamanho mínimo de folha limitam a complexidade. Mais profundidade pode memorizar ruído; escolha o limite pela validação.',
    ),
    'I(node) = mean((y − mean_node(y))²)\nŷ(x) = mean(y in reached leaf)',
    BilingualText(
      'For targets [0,2,10,12] at x=[0,1,2,3], split 1.5 yields means 1 and 11, reducing MSE from 26 to 1. Predictions are piecewise constant; plots sample 60 x₁ positions at x₂=0. No smooth extrapolation, pruning, missing-value routing or categorical splits are supplied. Scaling is unnecessary for ordering-based trees; the lab keeps its shared train-only scaler for consistent axes.',
      'Para alvos [0,2,10,12] em x=[0,1,2,3], o limiar 1,5 gera médias 1 e 11, reduzindo MSE de 26 para 1. As previsões são constantes por região; o gráfico amostra 60 posições de x₁ em x₂=0. Não há extrapolação suave, poda, tratamento de ausentes ou divisões categóricas. A escala é desnecessária para árvores baseadas em ordem; o laboratório a mantém ajustada só no treino para eixos consistentes.',
    ),
    preset: 'tree-regression',
  ),
  LearningTopic(
    BilingualText(
      "Random Forest classification",
      "Classificação Random Forest",
    ),
    BilingualText(
      "Each tree draws n training rows with replacement and a new random subset of features at every split. The forest votes on tree class predictions with equal weights; a tie chooses the smallest numeric label. This is not a probability estimate. The core accepts multiclass labels; the lab shows binary data. The default subset is floor(sqrt(features)), at least one. If selected features have no positive gain, that node stops without searching other features.",
      "Cada árvore sorteia n linhas do treino com reposição e um novo subconjunto de variáveis em cada divisão. A floresta vota nas classes previstas pelas árvores com pesos iguais; o empate escolhe o menor rótulo numérico. Isso não estima probabilidades. O núcleo aceita múltiplas classes; o laboratório mostra dados binários. O padrão usa floor(sqrt(variáveis)), no mínimo uma. Sem ganho positivo nas variáveis sorteadas, o nó para sem buscar outras variáveis.",
    ),
    "ŷ = mode(h₁(x), …, hT(x))",
    BilingualText(
      "A uses bootstrap samples and one randomly chosen feature per split (two input features). B is one all-feature tree on the full training split at the same depth. Even one forest tree differs from B.",
      "A usa amostras bootstrap e uma variável aleatória por divisão (duas variáveis de entrada). B é uma árvore com todas as variáveis e todo o treino na mesma profundidade. Mesmo uma árvore da floresta difere de B.",
    ),
    preset: "forest-classification",
  ),
  LearningTopic(
    BilingualText("Random Forest regression", "Regressão Random Forest"),
    BilingualText(
      "Average the numeric predictions of independently randomized trees. Each leaf predicts its bootstrap-target mean. The default feature subset is floor(sqrt(features)) for regression too. The generated target depends on both inputs. The plot samples 60 x₁ positions with standardized x₂=0: it is a conditional slice, while points can have other x₂ values. Averaging may reduce variance, but cannot guarantee improved test error or extrapolate trends beyond leaf predictions. Seeded results repeat within the same SDK; no pruning or feature importance is supplied.",
      "Calcule a média das previsões numéricas das árvores aleatórias. Cada folha prevê a média dos alvos bootstrap. A regressão também usa floor(sqrt(variáveis)) por padrão. O alvo gerado depende das duas entradas. O gráfico amostra 60 posições x₁ com x₂ padronizado=0: é um recorte condicional; os pontos podem ter outros x₂. A média pode reduzir variância, mas não garante menor erro de teste nem extrapola tendências além das folhas. A semente repete resultados no mesmo SDK; não há poda ou importância de variáveis.",
    ),
    "ŷ = Σₜ hₜ(x) / T",
    BilingualText(
      "A uses bootstrap samples and one randomly chosen feature per split (two input features). B is one all-feature tree on the full training split at the same depth. Even one forest tree differs from B.",
      "A usa amostras bootstrap e uma variável aleatória por divisão (duas variáveis de entrada). B é uma árvore com todas as variáveis e todo o treino na mesma profundidade. Mesmo uma árvore da floresta difere de B.",
    ),
    preset: "forest-regression",
  ),

  LearningTopic(
    BilingualText('KNN classification', 'Classificação KNN'),
    BilingualText(
      'Store training rows and find the k closest to each query in Euclidean distance. Each row contributes one vote; predict the most frequent class. Features must be scaled using training statistics only.',
      'Armazene o treino e encontre as k linhas mais próximas de cada consulta pela distância euclidiana. Cada linha recebe um voto; preveja a classe mais frequente. Ajuste a escala apenas com estatísticas do treino.',
    ),
    'd(x,z) = √Σⱼ(xⱼ−zⱼ)²; ŷ = mode(y among k neighbors)',
    BilingualText(
      'For neighbors labeled [0,1,1], k=3 predicts 1. Class-vote ties choose the smallest numeric label; equal-distance boundaries choose the earlier training row. Duplicate locations count separately. The lab compares selected k against 1, shows only A on the grid and supports binary labels; core classes may be any finite numeric label.',
      'Para vizinhos [0,1,1], k=3 prevê 1. Empates de votos escolhem o menor rótulo numérico; na fronteira de distâncias iguais, vale a primeira linha de treino. Duplicatas contam separadamente. O laboratório compara o k escolhido com 1, mostra só A na grade e aceita classes binárias; o núcleo aceita qualquer rótulo numérico finito.',
    ),
    preset: 'knn-classification',
  ),
  LearningTopic(
    BilingualText('KNN regression', 'Regressão KNN'),
    BilingualText(
      'Predict the simple mean of the k nearest training targets with uniform weights. Fit stores examples; there is no learning rate, iteration budget or optimization curve. Distances are brute-forced, not indexed by a KD-tree.',
      'Preveja a média simples dos alvos das k linhas mais próximas com pesos iguais. Fit armazena exemplos; não há taxa de aprendizado, limite de iterações ou curva de otimização. A busca percorre as linhas, sem índice KD-tree.',
    ),
    'ŷ(x) = (1/k) Σᵢ∈Nₖ(x) yᵢ',
    BilingualText(
      'Neighbor targets [2,4,9] give 5 at k=3. k=1 can follow noise; a large k may smooth away useful structure. Choose k inside validation/CV with k no larger than each training fold. Exact matches and duplicate rows do not bypass uniform averaging. Curves are sampled slices at x₂=0; KNN does not learn an extrapolation trend.',
      'Alvos vizinhos [2,4,9] resultam em 5 com k=3. k=1 pode seguir ruído; um k alto pode suavizar estruturas úteis. Escolha k na validação/CV sem superar o treino de cada partição. Coincidências exatas e duplicatas não anulam a média uniforme. As curvas são cortes amostrados em x₂=0; KNN não aprende uma tendência de extrapolação.',
    ),
    preset: 'knn-regression',
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
    BilingualText(
      '2. Control forest complexity',
      '2. Controle a complexidade da floresta',
    ),
    BilingualText(
      'Compare 1, 15 and 25 forest trees at depths 1, 3 and 6 on the same split. Keep the single-tree baseline at the selected depth; choose by validation.',
      'Compare 1, 15 e 25 árvores nas profundidades 1, 3 e 6 na mesma divisão. Mantenha a árvore de comparação na profundidade selecionada; escolha pela validação.',
    ),
    BilingualText(
      'Record actual depth, leaf counts and validation scores; choose a depth without inspecting the final test.',
      'Registre profundidade efetiva, folhas e métricas de validação; escolha o limite sem consultar o teste final.',
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
    BilingualText('4. Choose k without leakage', '4. Escolha k sem vazamento'),
    BilingualText(
      'Compare KNN k=1, 3 and 5 using fresh StandardScaler/KNN pipelines in every validation fold.',
      'Compare KNN com k=1, 3 e 5 usando pipelines StandardScaler/KNN novos em cada partição de validação.',
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
