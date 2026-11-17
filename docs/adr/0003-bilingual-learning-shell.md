# ADR-0003: Retain the experiment while navigating bilingual learning content

## Status

Accepted for the explicit navbar/identity/EN/PT-BR/learning request.

## Context

Navigation and locale changes must not reset a fitted or paused experiment, chart history or CSV draft. Learning must explain shipped mathematical behavior using the project's actual documentation, with executable examples. The Web demo should remember language when supported without adding a backend or transmitting datasets.

## Decision

Own the LabViewModel at the app shell, retain the Laboratory/Learn/Examples pages, and keep locale separate from experiment state. Translate project messages, typed validation errors, chart descriptions, help and educational text; use standalone Material UI localization delegates for framework controls. Synchronize the HTML language and store only a namespaced language code through a conditional browser adapter. Storage failure is nonfatal.

Use original vector geometry for the rising-seed brand and favicon. Teach the actual core 0.1.0 implementation with formulas/interpretations, four real presets and five exercises. Source links target real project files. Opening a preset is an explicit replacement of the current experiment; ordinary navigation and language changes preserve it.

## Consequences

The experiment remains in memory while Learn is visible and continues training if running. There are no URL-based deep links for the internal tabs; reload returns to Laboratory, with remembered language only. The source docs remain the reference, so content and translations must be updated alongside algorithm changes. Conditional adapters avoid browser imports in domain/core and require real Web validation in addition to VM tests.

## Alternatives considered

Recreating pages or controllers on each tab/locale would lose state. Saving complete datasets/models is unnecessary and would add privacy/lifetime complexity. A GitHub iframe would not deliver an integrated translated lesson. A new state-management or localization dependency is unnecessary for this bounded app.
