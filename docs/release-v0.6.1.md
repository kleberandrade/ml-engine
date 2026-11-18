# v0.6.1 — Public SDK documentation and integration contracts

- Document all public API symbols, including inherited members, constructor constraints, input/output conventions, lifecycle, errors and recovery.
- Put engine integration first in the README; ship English/PT integration guides and complete runnable prediction/classification/CV examples.
- Clarify binary/multiclass label domains, probability/logit differences, scaler and validation boundaries, atomic versus incremental fit recovery, and safe application model replacement.
- Reject missing public docs in static analysis. CI generates API documentation, requires complete indexed-symbol descriptions and no warnings/broken links, and executes developer examples.
- Numerical implementations and API signatures are unchanged; only equivalent explicit default scaler constructors and separately documented field declarations were introduced.

[API reference](https://pub.dev/documentation/ml_engine/0.6.1/) · [Package](https://pub.dev/packages/ml_engine/versions/0.6.1) · [Integration guide](https://github.com/kleberandrade/ml-engine/blob/main/doc/usage.md) · [Português](https://github.com/kleberandrade/ml-engine/blob/main/doc/usage.pt-BR.md)

Local verification: 192/192 API elements documented (100%), zero dartdoc warnings/errors/broken links, and pana 160/160 points (documentation 20/20). All 69 core and 50 Flutter tests and the three new developer examples pass. These local measurements are recorded in [documentation evidence](https://github.com/kleberandrade/ml-engine/blob/main/docs/api-docs-v0.6.1.json); public scorecard verification follows publication.
