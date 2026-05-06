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
- `.cursor/rules/solid_principles.mdc`
  SOLID principles for Dart code.
- `.cursor/rules/domain_layer.mdc`
  Domain-layer rules for entities, value objects, use cases,
  repositories, and errors.
- `.cursor/rules/coding_conventions.mdc`
  Naming, file conventions, dependency injection, imports, and
  `Result` usage.
- `.cursor/rules/coding_style.mdc`
  Dart style, tooling, logging, and modern language features.
- `.cursor/rules/null_safety.mdc`
  Null-safety rules and defensive typing guidance.
- `.cursor/rules/dependencies_patterns.mdc`
  Approved library choices such as `go_router`, `dio`, `get_it`,
  `Provider`, `result_dart`, `flutter_dotenv`, `uuid`, `zard`, and
  `brasil_fields`.
- `.cursor/rules/general_rules.mdc`
  Global behavioral rules for docs, comments, and clean code.
- `.cursor/rules/flutter_widgets.mdc`
  Widget composition, state, layout, and performance practices.
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
- Do not duplicate detailed rules in `AGENTS.md`; update links and short
  descriptions instead.

## Scope Hints

- `lib/domain/**/*.dart`
  Pay special attention to `domain_layer.mdc`,
  `clean_architecture.mdc`, `solid_principles.mdc`,
  `coding_conventions.mdc`, `coding_style.mdc`, and `null_safety.mdc`.
- `lib/data/**/*.dart` and `lib/infrastructure/**/*.dart`
  Pay special attention to `clean_architecture.mdc`,
  `coding_conventions.mdc`, `coding_style.mdc`,
  `dependencies_patterns.mdc`, and `null_safety.mdc`.
- `lib/di/**/*.dart`
  Pay special attention to `clean_architecture.mdc`,
  `coding_conventions.mdc`, `coding_style.mdc`, and
  `dependencies_patterns.mdc`.
- `lib/presentation/**/*.dart` and `lib/ui/**/*.dart`
  Pay special attention to `flutter_widgets.mdc`,
  `ui_ux_design.mdc`, `shared_components.mdc`,
  `dependencies_patterns.mdc`, `coding_style.mdc`, and
  `general_rules.mdc`.
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
