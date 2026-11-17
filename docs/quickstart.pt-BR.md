# Laboratório de aprendizado de máquina clássico

[Abrir a demonstração no GitHub Pages](https://kleberandrade.github.io/ml-engine/).

O núcleo está em Dart puro (`lib/`); a interface está em Flutter (`apps/ml_lab/`). Execute `dart test` e `dart run example/main.dart` na raiz. Entre em `apps/ml_lab/`, execute `flutter pub get` e `flutter run -d chrome`. Ambiente validado: Dart 3.14.0 e Flutter 3.50.0.

Escolha regressão linear, Ridge, classificação binária ou agrupamento. Compare duas execuções com os mesmos dados e orçamento. Os botões Pause/Resume congelam e retomam o treinamento; Cancel mantém a curva parcial; Restart limpa os modelos. O treino ocorre em pequenos passos para permitir interação.

A padronização aprende somente no treino. Use validação para escolher parâmetros e preserve o teste para a avaliação final. Consultar o teste repetidamente também causa vazamento na seleção. Em validação cruzada, crie um pipeline novo por fold. Dados temporais ou de pessoas repetidas exigem uma divisão específica.

CSV: cabeçalho exato `x1,x2,y`, 10–500 linhas numéricas, sem valores ausentes, NaN ou infinito. Na classificação, y precisa ser 0 ou 1. No agrupamento, y é ignorado. Há mensagens de erro sem descartar o conjunto atual.

A versão 0.2.0 do núcleo foi preparada para publicação no pub.dev; consulte o registro de lançamento para o resultado. O código está público em [kleberandrade/ml-engine](https://github.com/kleberandrade/ml-engine), com CI e documentação. KNN, árvores, florestas, Gradient Boosting, PCA, importância por permutação e SHAP pertencem ao roadmap; não são recursos implementados.

A navbar oferece Laboratório, Aprender e Exemplos, além da documentação e do GitHub. O seletor EN/PT-BR traduz controles, mensagens, ajuda e conteúdo educativo; a troca preserva o experimento, a curva e o rascunho CSV. Só a preferência de idioma fica armazenada no navegador, quando permitido. A área Aprender contém fórmulas explicadas e cinco exercícios; os exemplos abrem os algoritmos e dados realmente implementados. Abrir um exemplo substitui o experimento atual.

No modo **Ridge × linear**, A usa Ridge e B regressão linear com a mesma divisão, escala, inicialização, taxa e limite. O controle λ vai de 0 a 3; λ=0 gera curvas idênticas. Ridge minimiza `média((previsão−alvo)²)/2 + λ||w||²/2`, sem penalizar o intercepto. Observe a redução na norma dos coeficientes e escolha λ pelo RMSE de validação. A penalização pode aumentar o viés e não garante melhora no teste. As alturas dos custos não são comparáveis, pois A inclui a penalização. O exemplo usa variáveis correlacionadas; a reta exibida fixa x₂ na média do treino.

```dart
final pipeline = Pipeline(StandardScaler(), RidgeRegression(lambda: 1));
pipeline.fit(xTreino, yTreino);
final previsoes = pipeline.predict(xValidacao);
```
