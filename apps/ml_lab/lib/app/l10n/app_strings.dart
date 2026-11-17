import 'package:flutter/widgets.dart';

enum AppLanguage { en, ptBr }

extension AppLanguageCode on AppLanguage {
  String get code => this == AppLanguage.en ? 'en' : 'pt-BR';
  Locale get locale => this == AppLanguage.en
      ? const Locale('en', 'GB')
      : const Locale('pt', 'BR');
}

class AppStrings {
  final AppLanguage language;
  const AppStrings(this.language);
  String t(String key, [Map<String, Object> values = const {}]) {
    final translations = messages[key];
    if (translations == null) throw StateError('Missing translation: $key');
    var result = translations[language.index];
    for (final entry in values.entries) {
      result = result.replaceAll('{${entry.key}}', '${entry.value}');
    }
    return result;
  }

  String number(double value, int digits) {
    final result = value.toStringAsFixed(digits);
    return language == AppLanguage.ptBr ? result.replaceAll('.', ',') : result;
  }
}

extension LocalizedContext on BuildContext {
  AppStrings get l10n => AppStrings(
    Localizations.localeOf(this).languageCode == 'pt'
        ? AppLanguage.ptBr
        : AppLanguage.en,
  );
}

const messages = <String, List<String>>{
  'languageEnglish': ['English (United Kingdom)', 'Inglês (Reino Unido)'],
  'languagePortuguese': ['Portuguese (Brazil)', 'Português (Brasil)'],
  'selected': ['selected', 'selecionado'],

  "appTitle": [
    "ML Engine • Learning laboratory",
    "ML Engine • Laboratório de aprendizado",
  ],
  "nav-laboratory": ["Laboratory", "Laboratório"],
  "nav-learn": ["Learn", "Aprender"],
  "nav-examples": ["Examples", "Exemplos"],
  "nav-documentation": ["Documentation", "Documentação"],
  "nav-github": ["GitHub", "GitHub"],
  "language": ["Language", "Idioma"],
  "menu": ["Navigation menu", "Menu de navegação"],
  "brandLabel": [
    "ML Engine laboratory — original rising-seed mark",
    "Laboratório ML Engine — marca original da semente em ascensão",
  ],
  "hero": ["Make learning visible.", "Torne o aprendizado visível."],
  "subtitle": [
    "Build an intuition for models, one training step at a time.",
    "Desenvolva sua intuição sobre modelos, um passo de treino por vez.",
  ],
  "labTag": ["CLASSICAL ML / LAB 01", "ML CLÁSSICO / LAB 01"],
  "chip-regression": ["01  Linear regression", "01  Regressão linear"],
  "chip-classification": [
    "02  Logistic classification",
    "02  Classificação logística",
  ],
  "chip-clustering": ["03  K-means++", "03  K-means++"],
  'chip-ridge': ['04  Ridge vs linear', '04  Ridge × linear'],
  'plot-ridge': [
    'See regularization shrink coefficients',
    'Veja a regularização reduzir coeficientes',
  ],
  'type-ridge': ['Ridge regression', 'regressão Ridge'],
  'regularization': ['Regularization λ  {value}', 'Regularização λ  {value}'],
  'ridgeControlHelp': [
    'λ=0 matches linear regression. Larger λ shrinks weights; the intercept is not penalized. Both models use the same learning rate.',
    'λ=0 equivale à regressão linear. Um λ maior reduz os pesos; o intercepto não é penalizado. Os modelos usam a mesma taxa de aprendizado.',
  ],
  'ridgeShort': ['Ridge λ={value}', 'Ridge λ={value}'],
  'linearShort': ['Linear λ=0', 'Linear λ=0'],
  'coefficientNorm': [
    'Coefficient norm ||w||₂ • A: {a} / B: {b}',
    'Norma dos coeficientes ||w||₂ • A: {a} / B: {b}',
  ],
  'ridgeObjectiveLegend': [
    'A: teal, MSE/2 + λ||w||²/2. B: brown, MSE/2. Costs have different objectives; compare validation RMSE, not curve heights.',
    'A: verde, MSE/2 + λ||w||²/2. B: marrom, MSE/2. Os objetivos são diferentes; compare o RMSE de validação, não a altura das curvas.',
  ],
  'explain-ridge': [
    'Ridge minimizes mean squared error / 2 + λ||w||²/2. The intercept is not penalized. Correlated features make coefficient estimates sensitive; L2 shrinks their norm but can increase bias. A uses Ridge, B linear, with identical split, scaler, initialization, rate and budget. Choose λ on validation data. Better test performance is not guaranteed. The plotted line fixes x₂ at its training mean.',
    'Ridge minimiza erro quadrático médio / 2 + λ||w||²/2. O intercepto não é penalizado. Variáveis correlacionadas tornam os coeficientes sensíveis; L2 reduz sua norma, mas pode aumentar o viés. A usa Ridge e B linear, com a mesma divisão, escala, inicialização, taxa e limite. Escolha λ pela validação. Não há garantia de melhora no teste. A reta fixa x₂ na média do treino.',
  ],
  'example-ridge': [
    'Ridge on correlated features',
    'Ridge com variáveis correlacionadas',
  ],
  'example-ridge-body': [
    '150 seeded samples, correlated x₁/x₂ and y ≈ 2x₁+1. Compare Ridge λ=1 with linear at the same rate 0.08 and 250 iterations. Move λ to zero to recover identical curves.',
    '150 amostras reproduzíveis, x₁/x₂ correlacionados e y ≈ 2x₁+1. Compare Ridge λ=1 com linear à mesma taxa 0,08 e 250 iterações. Leve λ a zero para obter curvas idênticas.',
  ],
  'chip-knnClassification': ['05  KNN classification', '05  Classificação KNN'],
  'chip-knnRegression': ['06  KNN regression', '06  Regressão KNN'],
  'plot-knnClassification': [
    'Classify by neighborhood',
    'Classifique pela vizinhança',
  ],
  'plot-knnRegression': ['Estimate a local average', 'Estime uma média local'],
  'type-knnClassification': ['KNN classification', 'classificação KNN'],
  'type-knnRegression': ['KNN regression', 'regressão KNN'],
  'neighbors': ['Neighbors k  {count}', 'Vizinhos k  {count}'],
  'knnShort': ['KNN k={count}', 'KNN k={count}'],
  'evaluateNeighbors': ['Evaluate neighbors', 'Avaliar vizinhos'],
  'knnControlHelp': [
    'A uses your k; B uses k=1. Same train rows and train-fitted scaling. After changing k, evaluate again. k cannot exceed the training row count.',
    'A usa seu k; B usa k=1. Mesmas linhas e escala ajustada no treino. Após mudar k, avalie novamente. k não pode superar a quantidade de linhas de treino.',
  ],
  'knnNoObjective': [
    'KNN stores training examples; it has no epochs, learning rate or optimization curve. Compare validation scores to choose k. Small k can follow noise; large k can oversmooth. The core uses exact Euclidean search with uniform weights.',
    'KNN armazena exemplos de treino; não tem épocas, taxa de aprendizado ou curva de otimização. Compare a validação para escolher k. Um k pequeno pode seguir ruído; um k grande pode suavizar demais. O núcleo usa busca euclidiana exata e pesos iguais.',
  ],
  'directRegions': [
    'Colored cells show model A only, on a sampled grid; compare A/B accuracy below.',
    'As células coloridas mostram apenas o modelo A em uma grade amostrada; compare a acurácia de A/B abaixo.',
  ],
  'directPlotAria': [
    'Data plot. {count} samples, {type}. No iterative training. Validation scores appear below.',
    'Gráfico de dados. {count} amostras, {type}. Sem treino iterativo. Métricas de validação abaixo.',
  ],
  'explain-knnClassification': [
    'KNN finds the k nearest training rows in standardized Euclidean distance and predicts their most frequent numeric label. Equal class votes choose the smallest label; equal distances choose earlier training rows. Duplicate points each get one vote. A uses selected k, B uses 1; the grid shows A. This lab accepts binary labels 0/1; the Dart API also accepts other finite numeric classes. No calibrated probabilities are provided.',
    'KNN encontra as k linhas de treino mais próximas pela distância euclidiana padronizada e prevê o rótulo numérico mais frequente. Empates de votos escolhem o menor rótulo; distâncias iguais favorecem as primeiras linhas de treino. Pontos duplicados recebem um voto cada. A usa o k escolhido e B usa 1; a grade mostra A. O laboratório aceita 0/1; a API Dart também aceita outras classes numéricas finitas. Não há probabilidades calibradas.',
  ],
  'explain-knnRegression': [
    'KNN predicts the uniform mean of the k nearest training targets. Every duplicate row counts separately, including exact matches; it does not use inverse-distance weights. A uses selected k, B uses 1. Curves connect sampled predictions at standardized x₂=0; they are partial slices, not a differentiable fitted equation. KNN does not learn a trend for extrapolation. Choose k on validation data, not test.',
    'KNN prevê a média simples dos alvos das k linhas de treino mais próximas. Cada duplicata conta separadamente, inclusive em coincidências exatas; não há pesos pelo inverso da distância. A usa o k escolhido e B usa 1. As curvas ligam previsões amostradas em x₂ padronizado=0; são cortes parciais, não uma equação diferenciável ajustada. KNN não aprende uma tendência para extrapolar. Escolha k pela validação, não pelo teste.',
  ],
  'errorNeighbors': [
    'Choose a smaller k before importing: k cannot exceed the number of training rows in the new split.',
    'Escolha um k menor antes de importar: k não pode superar a quantidade de linhas de treino na nova divisão.',
  ],
  'example-knn-classification': [
    'KNN on a curved boundary',
    'KNN em uma fronteira curva',
  ],
  'example-knn-classification-body': [
    '150 seeded binary samples around a circular boundary. Compare k=5 and k=1 on the same split and scaler.',
    '150 amostras binárias reproduzíveis em torno de uma fronteira circular. Compare k=5 e k=1 na mesma divisão e escala.',
  ],
  'example-knn-regression': [
    'KNN on a nonlinear signal',
    'KNN em um sinal não linear',
  ],
  'example-knn-regression-body': [
    '150 seeded samples with y ≈ 2 sin(x₁)+1. Compare local averages with k=5 versus k=1; no gradient iterations are needed.',
    '150 amostras reproduzíveis com y ≈ 2 sen(x₁)+1. Compare médias locais com k=5 e k=1; não há iterações de gradiente.',
  ],
  'chip-treeClassification': [
    '07  Decision tree classifier',
    '07  Árvore de classificação',
  ],
  'chip-treeRegression': [
    '08  Decision tree regressor',
    '08  Árvore de regressão',
  ],
  'plot-treeClassification': [
    'Split the space with rules',
    'Divida o espaço com regras',
  ],
  'plot-treeRegression': [
    'Predict with leaf averages',
    'Preveja com médias nas folhas',
  ],
  'type-treeClassification': [
    'decision tree classification',
    'classificação por árvore',
  ],
  'type-treeRegression': ['decision tree regression', 'regressão por árvore'],
  'maxDepth': ['Maximum depth  {count}', 'Profundidade máxima  {count}'],
  'depthShort': ['Tree depth ≤ {count}', 'Árvore com profundidade ≤ {count}'],
  'evaluateTree': ['Fit and evaluate trees', 'Ajustar e avaliar árvores'],
  'directSplit': [
    'Train {train} / validation {validation} / test {test}. Same training rows, split and train-fitted scaler for A and B.',
    'Treino {train} / validação {validation} / teste {test}. Mesmas linhas, divisão e escala ajustada no treino para A e B.',
  ],
  'treeControlHelp': [
    'A uses your depth limit; B uses depth 1. Both require at least 2 training rows per leaf. After changing depth, fit again.',
    'A usa seu limite de profundidade; B usa profundidade 1. Ambas exigem pelo menos 2 linhas de treino por folha. Após mudar a profundidade, ajuste novamente.',
  ],
  'treeStats': [
    'Actual depth / leaves • A: {depthA} / {leavesA} • B: {depthB} / {leavesB}',
    'Profundidade efetiva / folhas • A: {depthA} / {leavesA} • B: {depthB} / {leavesB}',
  ],
  'treeRootRule': [
    'First rule of A: standardized x{feature} ≤ {value} goes left; otherwise right (rounded to 3 decimals).',
    'Primeira regra de A: x{feature} padronizado ≤ {value} segue à esquerda; caso contrário, à direita (arredondado para 3 casas).',
  ],
  'treeRootLeaf': [
    'A is a single leaf predicting {value}.',
    'A é uma única folha com previsão {value}.',
  ],
  'treeNoObjective': [
    'Trees fit greedy splits directly; there are no optimizer epochs, rate or cost curve. More depth can fit noise. Choose depth on validation data; reduced training error does not guarantee better test performance.',
    'Árvores ajustam divisões gulosas diretamente; não há épocas, taxa ou curva de otimização. Maior profundidade pode ajustar ruído. Escolha pela validação; menor erro de treino não garante melhora no teste.',
  ],
  'explain-treeClassification': [
    'Each node chooses the numeric feature/threshold with the largest weighted Gini decrease. Gini = 1 − sum(class fraction²). Route x ≤ threshold left; predict the majority class in its leaf, choosing the smallest numeric label on tied votes. Depth starts at zero. Tied gains prefer the lowest feature index, then threshold. Pure nodes, depth limits, small leaves or no positive gain stop growth. Greedy choices may miss globally useful splits, including zero-gain XOR.',
    'Cada nó escolhe a variável numérica e o limiar com maior redução ponderada de Gini. Gini = 1 − soma(fração de classe²). Valores x ≤ limiar seguem à esquerda; a folha prevê a maioria, com menor rótulo numérico no empate. A profundidade começa em zero. Ganhos empatados preferem o menor índice de variável e limiar. Pureza, profundidade, folhas pequenas ou falta de ganho param o crescimento. A busca gulosa pode perder divisões úteis globalmente, inclusive XOR com ganho inicial zero.',
  ],
  'explain-treeRegression': [
    'Choose splits that reduce weighted within-leaf squared error; each leaf predicts its training-target mean. Predictions are piecewise constant, not a smooth curve or learned extrapolation trend. The plot approximates leaf steps at 60 sampled x₁ values, holding standardized x₂=0. Trees do not require scaling; this lab keeps the shared train-fitted scale for consistent axes. Numeric finite data only; no pruning, missing-value routing or categorical splits.',
    'Escolha divisões que reduzam o erro quadrático ponderado dentro das folhas; cada folha prevê a média dos alvos do treino. As previsões são constantes por região, sem curva suave ou tendência de extrapolação. O gráfico aproxima os degraus em 60 valores de x₁, fixando x₂ padronizado=0. Árvores não exigem escala; o laboratório mantém a mesma padronização ajustada no treino para os eixos. Apenas dados numéricos finitos; sem poda, tratamento de ausentes ou divisões categóricas.',
  ],
  'example-tree-classification': [
    'A tree on a curved boundary',
    'Uma árvore em fronteira curva',
  ],
  'example-tree-classification-body': [
    'Compare a depth-3 classifier with a depth-1 tree on 150 seeded binary samples. Observe axis-aligned regions and validation accuracy.',
    'Compare classificação com profundidade 3 e 1 em 150 amostras binárias reproduzíveis. Observe regiões alinhadas aos eixos e acurácia de validação.',
  ],
  'example-tree-regression': [
    'A tree on a nonlinear signal',
    'Uma árvore em um sinal não linear',
  ],
  'example-tree-regression-body': [
    'Fit piecewise-constant means to y ≈ 2 sin(x₁)+1. Compare depth limits 3 and 1 with the same split and minimum leaf size.',
    'Ajuste médias constantes por região a y ≈ 2 sen(x₁)+1. Compare limites 3 e 1 com a mesma divisão e tamanho mínimo de folha.',
  ],
  "footer": [
    "PURE DART CORE / REPRODUCIBLE SEEDS / TRAIN-ONLY PREPROCESSING",
    "NÚCLEO DART PURO / SEMENTES REPRODUZÍVEIS / PRÉ-PROCESSAMENTO SÓ NO TREINO",
  ],
  "setup": ["Experiment setup", "Configuração do experimento"],
  "rows": ["{count} rows • {source}", "{count} linhas • {source}"],
  "synthetic": ["synthetic data", "dados sintéticos"],
  "imported": ["CSV data", "dados CSV"],
  "seed": ["Random seed", "Semente aleatória"],
  "rate": ["Learning rate  {value}", "Taxa de aprendizado  {value}"],
  "clusters": ["Clusters  {count}", "Grupos  {count}"],
  "budget": ["Iteration budget  {count}", "Limite de iterações  {count}"],
  "iterations": ["{count} iterations", "{count} iterações"],
  "clusterSemantic": ["{count} clusters", "{count} grupos"],
  "train": ["Train models", "Treinar modelos"],
  "pause": ["Pause", "Pausar"],
  "resume": ["Resume", "Retomar"],
  "cancel": ["Cancel", "Cancelar"],
  "restart": ["Restart", "Reiniciar"],
  "csvTitle": ["Bring your own data", "Use seus próprios dados"],
  "csvLabel": ["CSV data", "Dados CSV"],
  "csvHelp": [
    "Paste numeric CSV with header x1,x2,y. 10–500 rows; dot decimals; binary y for classification. Labels are ignored for clustering.",
    "Cole CSV numérico com cabeçalho x1,x2,y. De 10 a 500 linhas, decimais com ponto e y binário na classificação. O agrupamento ignora os rótulos.",
  ],
  "loadCsv": ["Load CSV", "Carregar CSV"],
  "useSynthetic": ["Use synthetic", "Usar dados sintéticos"],
  "plot-regression": ["Fit a relationship", "Ajuste uma relação"],
  "plot-classification": ["Find the boundary", "Encontre a fronteira"],
  "plot-clustering": ["Discover the structure", "Descubra a estrutura"],
  "status-ready": ["READY", "PRONTO"],
  "status-running": ["RUNNING", "TREINANDO"],
  "status-paused": ["PAUSED", "PAUSADO"],
  "status-complete": ["COMPLETE", "CONCLUÍDO"],
  "status-cancelled": ["CANCELLED", "CANCELADO"],
  "status-failed": ["FAILED", "FALHOU"],
  "axisRegression": [
    "x₁ standardized → target y • line holds x₂ at its training mean",
    "x₁ padronizado → alvo y • a reta fixa x₂ na média do treino",
  ],
  "axisFeatures": [
    "x₁ standardized → x₂ standardized • scaling fitted on training rows",
    "x₁ padronizado → x₂ padronizado • escala ajustada só nas linhas de treino",
  ],
  "plotAria": [
    "Data plot. {count} samples, {type}, {iterations} iterations. Validation scores appear below.",
    "Gráfico de dados. {count} amostras, {type}, {iterations} iterações. Métricas de validação abaixo.",
  ],
  "type-regression": ["regression", "regressão"],
  "type-classification": ["classification", "classificação"],
  "type-clustering": ["clustering", "agrupamento"],
  "centroidsA": ["+ A centroids", "+ Centroides A"],
  "centroidsB": ["+ B centroids", "+ Centroides B"],
  "legendA": ["● Model A / class 0", "● Modelo A / classe 0"],
  "legendB": ["◆ Model B / class 1", "◆ Modelo B / classe 1"],
  "clusterColors": [
    "{count} cluster colors • ○ held-out rows",
    "{count} cores de grupos • ○ amostras reservadas",
  ],
  "heldOut": [
    "○ held-out rows • ● training rows",
    "○ amostras reservadas • ● amostras de treino",
  ],
  "fair": ["Same data. Fair comparison.", "Mesmos dados. Comparação justa."],
  "split": [
    "Train {train} / validation {validation} / test {test}. Same split, scaler and budget for A and B.",
    "Treino {train} / validação {validation} / teste {test}. Mesma divisão, escala e limite para A e B.",
  ],
  "seedShort": ["seed {value}", "semente {value}"],
  "rateShort": ["rate {value}", "taxa {value}"],
  "accuracy": ["Accuracy {value}%", "Acurácia {value}%"],
  "distance": ["Mean distance² {value}", "Distância² média {value}"],
  "baselineMean": [
    "Train-mean baseline • validation {score}",
    "Referência pela média do treino • validação {score}",
  ],
  "baselineMajority": [
    "Train-majority baseline • validation {score}",
    "Referência pela maioria do treino • validação {score}",
  ],
  "baselineClusters": [
    "Unsupervised • lower held-out distance is better",
    "Não supervisionado • menor distância nas amostras reservadas é melhor",
  ],
  "finalTest": [
    "Final test • A: {a} / B: {b}",
    "Teste final • A: {a} / B: {b}",
  ],
  "testWarning": [
    "Use validation to choose settings. Repeatedly inspecting test results turns test data into validation data.",
    "Use a validação para escolher parâmetros. Consultar o teste repetidamente o transforma em dados de validação.",
  ],
  "objective": [
    "Training objective  •  {count} iterations",
    "Objetivo do treino  •  {count} iterações",
  ],
  "costAria": [
    "Training cost curve. {cost}. Lower is better.",
    "Curva de custo do treino. {cost}. Menor é melhor.",
  ],
  "noTraining": ["No training yet", "Treino ainda não iniciado"],
  "latestCost": ["A latest cost {value}", "Último custo de A: {value}"],
  "costEmpty": [
    "Train models to trace their learning curves.",
    "Treine os modelos para acompanhar as curvas de aprendizado.",
  ],
  "objectiveLegend": [
    "A: teal • B: brown. Linear: MSE/2; logistic: binary cross entropy; K-means: train inertia.",
    "A: verde • B: marrom. Linear: MSE/2; logística: entropia cruzada binária; K-means: inércia do treino.",
  ],
  "insight": [
    "Why this experiment matters",
    "Por que este experimento importa",
  ],
  "explain-regression": [
    "Gradient descent adjusts coefficients to reduce squared error. Try a smaller learning rate and watch model B converge more slowly. A flat feature contributes no information; the scaler maps it to zero.",
    "A descida de gradiente ajusta os coeficientes para reduzir o erro quadrático. Experimente uma taxa menor e observe a convergência mais lenta de B. Uma variável constante não traz informação; a escala a transforma em zero.",
  ],
  "explain-classification": [
    "Logistic regression turns a linear score into a probability. The plotted boundary uses a 0.5 threshold. Accuracy can hide class imbalance: the Dart API also reports precision, recall, F1 and confusion counts.",
    "A regressão logística transforma uma pontuação linear em probabilidade. A fronteira usa limiar de 0,5. A acurácia pode esconder desequilíbrio: a API Dart também calcula precisão, revocação, F1 e contagens da matriz de confusão.",
  ],
  "explain-clustering": [
    "K-means++ seeds centers with distance-weighted sampling, then alternates assignments and centroid updates. Seeds can find different local minima. Cluster IDs are arbitrary, not class predictions.",
    "K-means++ inicia centros por amostragem proporcional à distância e alterna atribuições e atualizações dos centroides. As sementes podem levar a mínimos locais diferentes. Os identificadores dos grupos são arbitrários, não previsões de classe.",
  ],
  "leakage": [
    "No leakage: preprocessing sees training rows only. Cross validation creates a fresh pipeline inside every fold. This bounded lab is a teaching tool, not an out-of-core trainer.",
    "Sem vazamento: o pré-processamento vê apenas o treino. A validação cruzada cria um pipeline novo a cada partição. Este laboratório tem limites didáticos e não processa dados maiores que a memória.",
  ],
  "errorCsvStructure": [
    "Use header x1,x2,y and 2–500 numeric rows, with dot decimals.",
    "Use o cabeçalho x1,x2,y e de 2 a 500 linhas numéricas, com decimais separados por ponto.",
  ],
  "errorCsvRow": [
    "Row {row}: expected three finite numbers. NaN and infinity are invalid.",
    "Linha {row}: informe três números finitos. NaN e infinito não são aceitos.",
  ],
  "errorFewRows": [
    "The lab needs at least 10 rows for train, validation and test.",
    "O laboratório precisa de pelo menos 10 linhas para treino, validação e teste.",
  ],
  "errorBinary": [
    "Classification requires labels 0 or 1.",
    "A classificação exige rótulos 0 ou 1.",
  ],
  "errorMagnitude": [
    "Use magnitudes up to 1,000,000 in this lab.",
    "Use valores com magnitude de até 1.000.000 neste laboratório.",
  ],
  "errorClusters": [
    "Choose fewer clusters or provide more distinct points.",
    "Escolha menos grupos ou forneça mais pontos distintos.",
  ],
  "errorTraining": [
    "Training failed. Restore synthetic data or lower the learning rate, then retry.",
    "O treino falhou. Restaure os dados sintéticos ou reduza a taxa de aprendizado e tente novamente.",
  ],
  "learnTitle": ["Learn by observing the model", "Aprenda observando o modelo"],
  "learnSubtitle": [
    "A guide to the algorithms actually implemented in ML Engine 0.4.0, based on the project tutorial and numerical conventions.",
    "Um guia dos algoritmos realmente implementados no ML Engine 0.4.0, baseado no tutorial e nas convenções numéricas do projeto.",
  ],
  "foundations": ["Foundations before fitting", "Fundamentos antes do ajuste"],
  "openExample": ["Open this experiment", "Abrir este experimento"],
  "references": [
    "Project sources and references",
    "Fontes e referências do projeto",
  ],
  "exercises": ["Five practical exercises", "Cinco exercícios práticos"],
  "objectiveLabel": ["Objective: ", "Objetivo: "],
  "completionLabel": ["Complete when: ", "Conclua quando: "],
  "examplesTitle": [
    "Start with an executable example",
    "Comece com um exemplo executável",
  ],
  "examplesSubtitle": [
    "Each preset opens the real laboratory with seeded data and explicit settings. Opening a preset replaces the current experiment; changing language or navigating Learn does not.",
    "Cada exemplo abre o laboratório real com dados reproduzíveis e parâmetros explícitos. Abrir um exemplo substitui o experimento; trocar o idioma ou visitar Aprender preserva o estado.",
  ],
  "sourceVersion": [
    "Source: project documentation • core 0.4.0 • Flutter 3.50.0",
    "Fonte: documentação do projeto • núcleo 0.4.0 • Flutter 3.50.0",
  ],
  "tutorialLink": ["Tutorial and exercises", "Tutorial e exercícios"],
  "designLink": [
    "Numerical conventions and extension guide",
    "Convenções numéricas e guia de extensão",
  ],
  "roadmapLink": [
    "Future roadmap — not implemented",
    "Plano futuro — não implementado",
  ],
  "codeLink": [
    "Executable Dart CLI example",
    "Exemplo Dart executável no terminal",
  ],
  "example-linear": ["Noisy linear relationship", "Relação linear com ruído"],
  "example-binary": [
    "A binary decision boundary",
    "Uma fronteira de decisão binária",
  ],
  "example-clusters": ["Three clouds, two seeds", "Três nuvens, duas sementes"],
  "example-csv": ["A known CSV relationship", "Uma relação conhecida em CSV"],
  "example-linear-body": [
    "150 seeded samples with y ≈ 2x₁ + 1. Compare rates 0.08 and 0.02 for 250 iterations.",
    "150 amostras reproduzíveis com y ≈ 2x₁ + 1. Compare taxas 0,08 e 0,02 durante 250 iterações.",
  ],
  "example-binary-body": [
    "150 samples labeled by x₁ + x₂ with noise. Compare accuracy with a train-majority baseline.",
    "150 amostras rotuladas por x₁ + x₂ com ruído. Compare a acurácia com a referência da maioria do treino.",
  ],
  "example-clusters-body": [
    "150 points around three centers. Use K-means++ with k=3, seeds 42 and 43, and a shared train split.",
    "150 pontos ao redor de três centros. Use K-means++ com k=3, sementes 42 e 43 e a mesma divisão de treino.",
  ],
  "example-csv-body": [
    "20 numeric rows with y=2x₁+1 and a constant x₂. Import the fixture and inspect scaling, fit and error.",
    "20 linhas numéricas com y=2x₁+1 e x₂ constante. Importe o exemplo e observe escala, ajuste e erro.",
  ],
};
