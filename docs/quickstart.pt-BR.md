# Laboratório de aprendizado de máquina clássico

[Abrir a demonstração no GitHub Pages](https://kleberandrade.github.io/ml-engine/).

O núcleo está em Dart puro (`lib/`); a interface está em Flutter (`apps/ml_lab/`). Execute `dart test` e `dart run example/main.dart` na raiz. Entre em `apps/ml_lab/`, execute `flutter pub get` e `flutter run -d chrome`. Ambiente validado: Dart 3.14.0 e Flutter 3.50.0.

Escolha regressão linear, Ridge, KNN para classificação/regressão, classificação logística, árvores de classificação/regressão ou agrupamento. Compare duas execuções com os mesmos dados e orçamento. Os botões Pause/Resume congelam e retomam o treinamento; Cancel mantém a curva parcial; Restart limpa os modelos. O treino ocorre em pequenos passos para permitir interação.

A padronização aprende somente no treino. Use validação para escolher parâmetros e preserve o teste para a avaliação final. Consultar o teste repetidamente também causa vazamento na seleção. Em validação cruzada, crie um pipeline novo por fold. Dados temporais ou de pessoas repetidas exigem uma divisão específica.

CSV: cabeçalho exato `x1,x2,y`, 10–500 linhas numéricas, sem valores ausentes, NaN ou infinito. Na classificação, y precisa ser 0 ou 1. No agrupamento, y é ignorado. Há mensagens de erro sem descartar o conjunto atual.

O núcleo está publicado como [ml_engine 0.4.0 no pub.dev](https://pub.dev/packages/ml_engine/versions/0.4.0). Instale com `dart pub add ml_engine`. O código está público em [kleberandrade/ml-engine](https://github.com/kleberandrade/ml-engine), com CI e documentação. Florestas, Gradient Boosting, PCA, importância por permutação e SHAP pertencem ao roadmap; não são recursos implementados.

A navbar oferece Laboratório, Aprender e Exemplos, além da documentação e do GitHub. O seletor EN/PT-BR traduz controles, mensagens, ajuda e conteúdo educativo; a troca preserva o experimento, a curva e o rascunho CSV. Só a preferência de idioma fica armazenada no navegador, quando permitido. A área Aprender contém fórmulas explicadas e cinco exercícios; os exemplos abrem os algoritmos e dados realmente implementados. Abrir um exemplo substitui o experimento atual.

No modo **Ridge × linear**, A usa Ridge e B regressão linear com a mesma divisão, escala, inicialização, taxa e limite. O controle λ vai de 0 a 3; λ=0 gera curvas idênticas. Ridge minimiza `média((previsão−alvo)²)/2 + λ||w||²/2`, sem penalizar o intercepto. Observe a redução na norma dos coeficientes e escolha λ pelo RMSE de validação. A penalização pode aumentar o viés e não garante melhora no teste. As alturas dos custos não são comparáveis, pois A inclui a penalização. O exemplo usa variáveis correlacionadas; a reta exibida fixa x₂ na média do treino.

```dart
final pipeline = Pipeline(StandardScaler(), RidgeRegression(lambda: 1));
pipeline.fit(xTreino, yTreino);
final previsoes = pipeline.predict(xValidacao);
```

Na versão 0.3.0, **Classificação KNN** usa votação da maioria e **Regressão KNN** usa a média dos alvos dos k vizinhos mais próximos. A distância é euclidiana e os pesos são iguais. Empates de votos escolhem o menor rótulo numérico; distâncias iguais seguem a ordem do treino. Duplicatas contam separadamente, inclusive coincidências exatas. O núcleo aceita classes numéricas finitas; o laboratório usa apenas 0/1.

Escolha k (até 15, sem superar o treino) e clique **Avaliar vizinhos**. A usa seu k e B usa k=1; com k=1 os resultados coincidem. Não há épocas, taxa ou curva de otimização. A grade mostra apenas A; as curvas de regressão são cortes amostrados em x₂=0. Escolha k pela validação, com escala ajustada só no treino. Um k pequeno pode seguir ruído e um k alto pode suavizar demais. Se um CSV novo tiver pouco treino para o k escolhido, reduza k e tente novamente; o erro preserva o resultado anterior.

```dart
final modelo = Pipeline(StandardScaler(), KNNClassifier(k: 3));
modelo.fit(xTreino, classesTreino);
final classes = modelo.predict(xValidacao);
// Para alvos contínuos, use KNNRegressor(k: 3).
```

Na versão 0.4.0, árvores de classificação reduzem Gini e árvores de regressão reduzem erro quadrático. Escolha profundidade máxima 1–6 e clique **Ajustar e avaliar árvores**: A usa seu limite e B usa 1, com ao menos duas linhas de treino por folha. Observe profundidade efetiva, folhas e primeira regra de A (valores arredondados). A raiz tem profundidade zero; o núcleo também permite limite zero para uma folha constante.

Valores iguais ao limiar seguem à esquerda. Empates de classe escolhem o menor rótulo numérico; ganhos empatados preferem índice de variável e limiar. Pureza, profundidade, folhas pequenas ou falta de ganho positivo interrompem o crescimento. A busca é gulosa e não descobre XOR quando o primeiro ganho é zero. As folhas de regressão preveem médias constantes; degraus no gráfico são amostrados em x₂ padronizado=0. Não há poda, ausentes, divisões categóricas ou extrapolação suave. Árvores não precisam de escala, mas o laboratório mantém a escala ajustada só no treino para os eixos.

```dart
final arvore = DecisionTreeRegressor(maxDepth: 3, minSamplesLeaf: 2);
arvore.fit(xTreino, yTreino);
final previsoes = arvore.predict(xValidacao);
print(arvore.root.threshold); // Regra imutável; null se for uma folha.
```
