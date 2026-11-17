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
    "A guide to the algorithms actually implemented in ML Engine 0.2.0, based on the project tutorial and numerical conventions.",
    "Um guia dos algoritmos realmente implementados no ML Engine 0.2.0, baseado no tutorial e nas convenções numéricas do projeto.",
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
    "Source: project documentation • core 0.2.0 • Flutter 3.50.0",
    "Fonte: documentação do projeto • núcleo 0.2.0 • Flutter 3.50.0",
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
