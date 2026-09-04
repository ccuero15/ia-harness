# OpenCode Config Constitution

Non-negotiable rules every agent (orchestrator, subagents, human) must follow. Both
Antigravity CLI and OpenCode read this file before planning or implementing anything.
Keep it short — a handful of principles, not a style guide. Update it deliberately;
treat changes as a spec change, not a drive-by edit.

## Principles

1. **Spec before code (Directorio Centralizado `specs/`).** Lo primero que debe hacer cualquier agente al recibir un requerimiento es consultar si existe la carpeta raíz `specs/` en el proyecto donde se está ejecutando. En caso de que no exista, el agente está obligado a crearla. Ninguna tarea de implementación puede iniciar sin que los archivos `spec.md` y `plan.md` estén creados, organizados y aprobados dentro de una subcarpeta centralizada `specs/<feature>/`. Queda estrictamente prohibido crear estos archivos de planeación sueltos o fuera de este scope.
2. **Intocabilidad de frameworks y dependencias.** Queda terminantemente prohibido editar, modificar o tocar de cualquier manera los archivos dentro de las carpetas de código de frameworks o dependencias, tales como `node_modules`.
3. **Test-Driven Development (TDD) estricto.** Antes de escribir cualquier código de funcionalidad, es obligatorio redactar y ejecutar primero las pruebas pertinentes basándose en los requerimientos (Fase RED -> Fase GREEN).
4. **Human-in-the-loop for approvals.** Always pause and seek human approval after generating a spec or plan.
5. **Lectura de código estricta (Graphify).** Está terminantemente prohibido leer código fuente utilizando herramientas como Glob o Grep. Toda lectura, mapeo y análisis de código debe realizarse exclusivamente a través de **Graphify**. Al inicio de cada sesión, es obligatorio verificar que la captura de nodos esté actualizada utilizando el MCP y las skills correspondientes.

## Tech constraints

- Language / stack: JSONC / Markdown
- Testing requirement: Ensure valid JSON syntax for all configurations.
- Forbidden: Overwriting global user files outside the current project scope without explicit permission. Prohibido usar Glob/Grep para leer o buscar código; usar siempre Graphify.

## Definition of done

A task is done when: The feature is fully implemented, JSON is validated, the `plan.md` checklist item is ticked, and the human confirms it works as expected.

## Amendment process

Changes to this file require a spec entry of their own (`specs/NNN-constitution-update/`)
so the reasoning is preserved, not just the diff.

## Code Style Rules

### General
- Follow the project's existing patterns.
- No commented-out code — delete it.
- Keep functions small and focused (single responsibility).
- Use meaningful names; avoid abbreviations.
- Prefer immutability where practical.

### TypeScript / JavaScript
- Use TypeScript strict mode.
- Prefer `const` over `let`; never use `var`.
- Use arrow functions for callbacks.
- Named exports over default exports.

### Python
- Follow PEP 8.
- Use type hints for all public functions.
- Prefer `pathlib` over `os.path`.

### Git
- Atomic commits (one logical change per commit).
- Conventional commit messages.
- Rebase before merging to main.

## Testing Rules

### Framework
- Use Node.js built-in test runner: `node:test` + `node:assert/strict`.
- Test files: `*.test.js` in `quiz/tests/` or project-level `tests/`.
- Run tests using: `node --test <file>` or `node --test **/*.test.js`.

### Conventions
- One test file per module (e.g., `scorer.js` → `scorer.test.js`).
- Use `describe` blocks to group related tests.
- Each `it()` should test exactly one behavior.
- Use `assert/strict` for all assertions.
- **NO external test dependencies** (do not use jest, vitest, mocha, etc.).

### TDD Workflow
- Write failing test first (RED).
- Implement minimum code to pass (GREEN).
- Refactor while keeping tests green.
- Use the `/plan` command to create a plan before coding.

### CI Validation
- Run: `node .opencode/scripts/ci-validate.js`.
- Must pass before any commits.
- Checks: required files, placeholder text, frontmatter validity/plan.
