# Laboratório de aprendizado de máquina clássico

[Abrir a demonstração no GitHub Pages](https://kleberandrade.github.io/ml-engine/).

O núcleo está em Dart puro (`lib/`); a interface está em Flutter (`apps/ml_lab/`). Execute `dart test` e `dart run example/main.dart` na raiz. Entre em `apps/ml_lab/`, execute `flutter pub get` e `flutter run -d chrome`. Ambiente validado: Dart 3.14.0 e Flutter 3.50.0.

Escolha regressão, classificação binária ou agrupamento. Compare duas execuções com os mesmos dados e orçamento. Os botões Pause/Resume congelam e retomam o treinamento; Cancel mantém a curva parcial; Restart limpa os modelos. O treino ocorre em pequenos passos para permitir interação.

A padronização aprende somente no treino. Use validação para escolher parâmetros e preserve o teste para a avaliação final. Consultar o teste repetidamente também causa vazamento na seleção. Em validação cruzada, crie um pipeline novo por fold. Dados temporais ou de pessoas repetidas exigem uma divisão específica.

CSV: cabeçalho exato `x1,x2,y`, 10–500 linhas numéricas, sem valores ausentes, NaN ou infinito. Na classificação, y precisa ser 0 ou 1. No agrupamento, y é ignorado. Há mensagens de erro sem descartar o conjunto atual.

O pacote ainda não foi publicado no pub.dev. O código está público em [kleberandrade/ml-engine](https://github.com/kleberandrade/ml-engine), com CI e documentação. Ridge, KNN, árvores, florestas, Gradient Boosting, PCA, importância por permutação e SHAP pertencem ao roadmap; não são recursos implementados.
