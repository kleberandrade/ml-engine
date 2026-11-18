# Integração da ML Engine

O pacote é uma engine Dart para ser incorporada em aplicações. Importe `package:ml_engine/ml_engine.dart`; o laboratório Flutter é um consumidor separado, não uma dependência necessária. A referência pública e os comentários dartdoc estão em inglês; este guia explica os contratos de integração em português. Veja também o [guia completo em inglês](https://github.com/kleberandrade/ml-engine/blob/main/doc/usage.md).

## Dados e pré-processamento

`Matrix` é `List<List<double>>`: linhas são amostras, colunas são variáveis. Treino e previsão exigem pelo menos uma linha, largura positiva constante e valores finitos. A engine não conhece nomes de colunas: preserve ordem, unidades e codificação entre treino e inferência. O núcleo aceita mais variáveis que as duas exibidas no laboratório. Cada alvo corresponde à mesma linha da matriz. Lotes de previsão vazios são rejeitados; trate-os na camada de aplicação se quiser devolver uma lista vazia.

`Dataset` copia os dados para listas profundamente imutáveis. `validateMatrix` e `validateTargets` verificam estrutura e valores finitos, mas não condicionamento numérico ou todos os requisitos de um algoritmo. Categorias, ausentes e schema precisam de tratamento externo consistente, aprendido somente no treino.

`Pipeline` guarda as instâncias recebidas, sem cloná-las. `fit` ajusta o transformador no treino e o estimador nos dados transformados. `predict` recebe dados crus e aplica a transformação já aprendida. Não ajuste a escala nos dados reservados nem transforme duas vezes. Para métodos adicionais do modelo, como probabilidades, use `modelo.probabilities(pipeline.transform(consulta))` se o modelo foi ajustado por esse pipeline.

`StandardScaler` usa variância populacional; coluna constante tem escala um, valores de treino viram zero e valores novos diferentes representam a diferença para essa constante. `MinMaxScaler` não limita resultados a `[0,1]`; valores reservados podem sair do intervalo. Coluna constante usa amplitude um. Falhas de ajuste preservam as estatísticas anteriores.

## Escolha do algoritmo e retorno

- Regressões linear, Ridge, KNN, árvore, Random Forest e Gradient Boosting retornam estimativas contínuas.
- Classificação logística e Gradient Boosting aceitam somente `0`/`1`. `predict` devolve rótulos após limiar `0,5`, com empate em `1`; `probabilities` devolve escores sigmoidais da classe 1, sem calibração independente.
- Classificadores KNN, árvore e Random Forest aceitam múltiplas classes numéricas finitas. Retornam decisões, não probabilidades. Empates de votos escolhem o menor rótulo numérico.
- `KMeans` recebe apenas variáveis e retorna índices inteiros dos centroides, sem significado de classe supervisionada. Tem `fit(x)`, não `Estimator.fit(x,y)`.

`classificationMetrics` é exclusivamente binário: recebe rótulos reais primeiro e previstos depois, não probabilidades. Precisão, recall e F1 retornam zero nos casos de denominador zero. O construtor direto `ClassificationMetrics` não valida as contagens; todas zero produzem acurácia NaN. Prefira a função que calcula métricas a partir dos vetores.

MSE está em unidades quadráticas do alvo; RMSE e MAE estão nas unidades originais e quanto menores melhor. R² pode ser negativo; com alvo constante vale 1 para previsões exatas e 0 nos demais casos. Valores de entrada finitos não impedem todo estouro numérico em diferenças e somas extremas.

`parseCsv` é um leitor estrito de conveniência: cabeçalho `x1,x2,y`, duas variáveis, um alvo, 2–500 linhas por padrão, decimais com ponto e sem aspas/ausentes. `CsvFormatException.code` é estável para localização; `.row` conta a linha do cabeçalho como 1 ou fica null em erros estruturais. As restrições de rótulo são responsabilidade do estimador.

## Validação e componentes novos

Separe dados antes de ajustar qualquer estatística. `trainValidationTestSplit` usa 60/20/20 por padrão, arredonda treino/validação para baixo e deixa o restante para teste; divisões vazias são rejeitadas. O construtor direto `DataSplit` apenas copia listas e não verifica sobreposição ou índices.

Em `crossValidate`, a fábrica precisa criar pipeline, transformador e estimador novos em cada partição; reutilização é rejeitada. A função devolve um escore por partição, sem calcular média ou decidir se maior ou menor é melhor. O avaliador recebe alvos reais e previsões. Para múltiplas classes, forneça uma métrica adequada. Verifique se o k do KNN cabe no treino de cada partição.

`kFold` reserva cada linha uma vez; `stratifiedKFold` distribui classes inteiras e exige ao menos k exemplos em cada classe. As divisões pressupõem linhas independentes, sem tratamento automático de grupos, indivíduos repetidos ou tempo. Reprodução por semente pressupõe o mesmo SDK e ordem de entrada. Escolha parâmetros na validação, mantendo teste final fora da seleção.

## Falhas e substituição segura de modelos

Não existe uma promessa única de rollback para todos os estimadores:

- KNN, árvores, Random Forest e Gradient Boosting substituem o ajuste inteiro somente após concluir um candidato válido. Falhas preservam o modelo anterior.
- Regressões por gradiente validam antes de `start`, mas um início válido zera parâmetros e histórico. Se uma atualização posterior falhar, fica o último estado finito dessa nova execução, não o modelo anterior ao `fit`.
- K-means inicializa centros de forma atômica. Um início válido troca os centros e limpa o histórico; uma falha posterior preserva a última etapa da execução nova.
- Falha em `Pipeline.fit` invalida o pipeline até um ajuste bem-sucedido. Componentes genéricos podem ter sido alterados e não podem ser desfeitos automaticamente. Não os reajuste fora do pipeline.

Para continuar atendendo com um modelo conhecido, ajuste uma instância candidata separada, execute os critérios de aceitação e só depois troque a referência usada pela aplicação. Capturar uma exceção não torna um pipeline inválido novamente seguro.

Em geral, parâmetros/dados inválidos geram `ArgumentError`; uso antes da inicialização gera `StateError`. O tipo de falha numérica varia: divergência por gradiente usa `StateError`, árvores/boosting usam `ArgumentError` durante o ajuste, e média de previsão KNN/floresta pode gerar `StateError`. Consulte a documentação do método. Registre a falha e trate escala/taxa quando apropriado; não substitua silenciosamente uma previsão por zero.

## Etapas, históricos e custo

`start`/`step` permitem observar atualizações reais. Uma etapa confirmada retorna true; false indica limite atingido ou convergência no K-means. Prever ou ler um snapshot não avança o treinamento. A engine é síncrona: use worker/isolate compatível com sua plataforma em trabalhos prolongados.

`GradientModel.costHistory` contém somente objetivos após atualizações, sem custo inicial. `GradientBoostingModel.lossHistory` contém a perda constante inicial no índice zero e mais um valor por árvore. `KMeans.costHistory` registra inércia total após atualizações; `inertia` só funciona depois da primeira etapa. Perda do treino não equivale a RMSE/acurácia de validação.

Há uma diferença de nomenclatura importante: `GradientModel.rawPredictions` da regressão logística já retorna probabilidades sigmoidais; `GradientBoostingModel.rawPredictions` do classificador retorna logits. Prefira `probabilities` para obter escores da classe 1. Snapshots de parâmetros, árvores e históricos são imutáveis e não mudam quando uma etapa futura é executada.

## Convenções e limites de interoperabilidade

Ridge minimiza MSE/2 mais `lambda*||pesos||²/2`, sem penalizar intercepto; em uma convenção de perda por soma, `alpha=n*lambda`. KNN usa distância euclidiana exata, pesos uniformes, ordem do treino no empate de distância e duplicatas contadas separadamente.

Profundidade de árvore conta arestas a partir de zero. O mínimo de folha limita filhos de divisões propostas; uma raiz sem divisão pode ter menos linhas. A busca gulosa exige ganho positivo e não explora o primeiro ganho zero de XOR. Igualdade com o limiar segue à esquerda.

Random Forest usa bootstrap de n linhas por árvore e novas variáveis em cada nó; por padrão, `max(1,floor(sqrt(d)))` nas duas tarefas. Classificação usa votos das classes; regressão usa média. Não há OOB ou probabilidades. Índices bootstrap imutáveis referem-se às linhas do último ajuste e ocupam `O(n*árvores)` inteiros.

Gradient Boosting é de primeira ordem, usa todas as linhas/variáveis e soma árvores de regressão dos resíduos com taxa fixa. Inicia na média para regressão ou no log das chances da classe no treino, limitado numericamente, para classificação binária. Não inclui Newton nas folhas, busca de passo, subamostragem ou parada antecipada automática. Não é XGBoost nem promete compatibilidade de arquivos/previsões.

Persistência de modelos, schema, categorias, imputação, calibração, execução em GPU e monitoramento ficam na aplicação. A documentação declara os comportamentos reais da API; cobertura de documentação não significa qualidade preditiva para qualquer conjunto de dados.

Execute os exemplos verificados: `dart run example/quickstart.dart`, `dart run example/classification.dart` e `dart run example/cross_validation.dart`. A [referência da API](https://pub.dev/documentation/ml_engine/latest/) contém os contratos de cada símbolo; o CI rejeita membros públicos sem documentação e avisos/links quebrados na referência gerada.
