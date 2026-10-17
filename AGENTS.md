# AGENTS.md

This file is the top-level index for AI assistants working in this
repository.

The real project rules live in `.cursor/rules/`.

If there is any conflict between this file and `.cursor/rules/*.mdc`,
the files in `.cursor/rules/` are the source of truth.

## Purpose

- Keep `AGENTS.md` short and easy to scan.
- Point assistants to the real rule files.
- Avoid duplicating full rule content here.

## Read Order

1. `.cursor/rules/global_guardrails.mdc`
2. `.cursor/rules/rules_index.mdc`
3. The specific rule files that match the work being changed
4. This file only as a navigation aid

When two rules overlap, prefer the layer or scope rule, then the
technical rule, then the general rule, then this index.

## Rule Source Of Truth

- `.cursor/rules/global_guardrails.mdc`
  Minimal always-on repository guardrails.
- `.cursor/rules/rules_index.mdc`
  Master routing index and rule priority map.
- `.cursor/rules/rules_authoring.mdc`
  How to maintain rules and `AGENTS.md` without duplication.
- `.cursor/rules/architecture.mdc`
  High-level architecture overview and layer responsibilities.
- `.cursor/rules/clean_architecture.mdc`
  Dependency direction and layer boundaries.
- `.cursor/rules/design_patterns.mdc`
  Which pattern to apply: View, ViewModel, Controller, Coordinator,
  Use Case, Repository, Service, or Mapper.
- `.cursor/rules/solid_principles.mdc`
  SOLID, god classes, and composition over inheritance.
- `.cursor/rules/domain_layer.mdc`
  Entities, value objects, use cases, repositories, and `AppFailure`.
- `.cursor/rules/coding_conventions.mdc`
  Naming, file conventions, constructor injection, and `Result`.
- `.cursor/rules/coding_style.mdc`
  Dart style, tooling, logging, and language features legal on SDK 3.9.
  Do not use dot shorthands, private named parameters, or primary
  constructors until the SDK lower bound allows them.
- `.cursor/rules/null_safety.mdc`
  Null-safety rules and defensive typing guidance.
- `.cursor/rules/dependencies_patterns.mdc`
  Approved library choices such as `go_router`, `dio`, `get_it`,
  `Provider`, `result_dart`, `flutter_dotenv`, `uuid`, `zard`, and
  `brasil_fields`.
- `.cursor/rules/general_rules.mdc`
  Docs, comments, extraction, and self-explanatory code.
- `.cursor/rules/flutter_widgets.mdc`
  Widget composition, god widgets, componentization, local state,
  layout, and performance.
- `.cursor/rules/ui_ux_design.mdc`
  UI states, accessibility, responsiveness, and mobile UX guidance.
- `.cursor/rules/shared_components.mdc`
  Promotion and safe evolution of shared UI components.
- `.cursor/rules/testing.mdc`
  Testing strategy and Dart/Flutter testing practices.

## Agent Expectations

- Treat `.cursor/rules/` as the canonical rule set.
- Apply the relevant `.mdc` files based on the files and layer being
  changed.
- For new code, follow the applicable rules strictly.
- For existing code, improve rule alignment incrementally when touching
  the area.
- Keep classes and widgets focused. Split a god class or god widget by
  the reason it changes, using the pattern named in
  `design_patterns.mdc`.
- Prefer Dart 3.9 features that remove casts and branches: `sealed`
  types, exhaustive `switch`, records, patterns, and null-aware
  collection elements.
- Do not duplicate detailed rules in `AGENTS.md`; update links and short
  descriptions instead.

## Scope Hints

- `lib/domain/**/*.dart`
  Pay special attention to `domain_layer.mdc`,
  `clean_architecture.mdc`, `design_patterns.mdc`,
  `solid_principles.mdc`, `coding_conventions.mdc`,
  `coding_style.mdc`, and `null_safety.mdc`.
- `lib/data/**/*.dart` and `lib/infrastructure/**/*.dart`
  Pay special attention to `clean_architecture.mdc`,
  `design_patterns.mdc`, `coding_conventions.mdc`,
  `coding_style.mdc`, `dependencies_patterns.mdc`, and
  `null_safety.mdc`.
- `lib/di/**/*.dart`
  Pay special attention to `clean_architecture.mdc`,
  `design_patterns.mdc`, `coding_conventions.mdc`,
  `coding_style.mdc`, and `dependencies_patterns.mdc`.
- `lib/presentation/**/*.dart` and `lib/ui/**/*.dart`
  Pay special attention to `flutter_widgets.mdc`,
  `ui_ux_design.mdc`, `shared_components.mdc`,
  `design_patterns.mdc`, `solid_principles.mdc`,
  `dependencies_patterns.mdc`, `coding_style.mdc`, and
  `general_rules.mdc`.
- `lib/core/**/*.dart`
  Pay special attention to `coding_style.mdc`,
  `dependencies_patterns.mdc`, `general_rules.mdc`, and, when the
  change touches theme or base UI, `ui_ux_design.mdc`.
- `test/**/*.dart`
  Pay special attention to `testing.mdc`, `coding_style.mdc`, and
  `general_rules.mdc`.
- `.cursor/rules/**/*.mdc` and `AGENTS.md`
  Pay special attention to `global_guardrails.mdc`,
  `rules_index.mdc`, and `rules_authoring.mdc`.
- `pubspec.yaml`
  Pay special attention to `dependencies_patterns.mdc`.

## Maintenance Rule

When project rules change, update the corresponding file in
`.cursor/rules/` first. Update `AGENTS.md` only if the index, filenames,
or navigation guidance need to change.
