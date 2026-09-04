# Harness ECC — Adaptación a OpenCode

> Portado desde el harness "Everything Claude Code" (ECC), a su vez adaptado desde Gemini CLI. Esta versión traduce las convenciones de Claude Code a las convenciones nativas de **OpenCode** (opencode.ai).

---

## 0. Rules & Grafo de Código (Graphify Protocol)

- For codebase questions, first run `graphify query "<question>"` when graphify-out/graph.json exists. Use `graphify path "<A>" "<B>"` for relationships and `graphify explain "<concept>"` for focused concepts. These return a scoped subgraph, usually much smaller than GRAPH_REPORT.md or raw grep output.
- Dirty graphify-out/ files are expected after hooks or incremental updates; dirty graph files are not a reason to skip graphify. Only skip graphify if the task is about stale or incorrect graph output, or the user explicitly says not to use it.
- If graphify-out/wiki/index.md exists, use it for broad navigation instead of raw source browsing.
- Read graphify-out/GRAPH_REPORT.md only for broad architecture review or when query/path/explain do not surface enough context.
- After modifying code, run `graphify update .` to keep the graph current (AST-only, no API cost).

## DIRECTIVAS TRANSVERSALES: PROTOCOLO ENGRAM, RECON & TOKEN-THRIFT

- **engram-context**: mantener coherencia global mapeando dependencias de microservicios y eventos; transferir estrictamente payloads mutados/nuevos entre capas (no el historial repetido).
- **engram-doc-coverage**: prohibido escribir comentarios de texto en el código o explicaciones extensas en el chat. Explicar la lógica exclusivamente mediante arquitectura autodescriptiva (nombres semánticos, tipado estricto, abstracciones limpias).
- **engram-memory-protocol**: registrar estados de diseño, nombres de colas y contratos de eventos en un JSON compacto para sincronizar subagentes sin redundancia de texto.
- **engram-testing-coverage**: exigir cobertura de pruebas unitarias e integración para flujos asíncronos y workers de colas (BullMQ u otro). Definir casos de borde (fallos de red, reintentos, colisiones de estado).
- **skill-first (graphify incluido y host-level runtime)**: antes de usar cualquier tool de exploración de código (`graphify query`, `graphify path`, `graphify explain`, `grep`, `glob`, etc.) o antes de cualquier tarea operativa (implementación, debugging, diseño, review), el agente **DEBE** cargar primero la skill relevante con la tool nativa `skill` de OpenCode (que expone el `<available_skills>` disponible), o leyendo directamente su `SKILL.md` desde la ruta global del ordenador (`~/.agents/skills/<skill>/SKILL.md`). **REGLA CRÍTICA**: Las skills se ejecutan y resuelven EXCLUSIVAMENTE desde el directorio global del ordenador (`~/.agents/skills/`), NUNCA como dependencias locales de la carpeta del proyecto o repositorio analizado. Regla "even 1% chance → invoke" obligatoria.
- **superpowers-mandate**: ningún agente (primario o subagente) puede iniciar ejecución operativa o de diseño sin invocar primero las skills/tools MCP aplicables. Todo bloque de ejecución debe estar respaldado por la carga en contexto de su skill correspondiente.
- **tdd-mandatory**: todo cambio de comportamiento (implementación, bugfix, refactor) sigue el ciclo RED → GREEN → REFACTOR. Prohibido escribir código de producción sin un test fallido que lo justifique previamente. El agente de QA debe verificar que existan tests antes de aprobar cualquier entrega.
- **subagent-only-orchestrator**: el agente primario/orquestador **no** ejecuta `write`/`edit`/`patch` sobre código fuente directamente. Toda implementación, modificación o refactor se delega a subagentes vía mención `@agente` (o comando con `subtask: true`). El orquestador solo coordina, revisa y consolida.
- **token-thrift-rules**:
  - Prohibido saludo, preámbulos, cortesías o resúmenes conversacionales en el chat. Ir directo al grano técnico.
  - Uso mandatorio de marcas semánticas densas y etiquetas delimitadoras (`<orquestador>`, `<subagente_X>`).
  - Prohibido retornar código fuente completo o bloques extensos dentro del chat. Estructurar la lógica mediante especificaciones técnicas, pseudocódigo abstracto o estructuras JSON/YAML.
  - Referenciar elementos preexistentes por su identificador. No duplicar información.
  - **Regla inquebrantable de gestión de paquetes**: usar única y exclusivamente `bun` para dependencias, scripts de ejecución y monorepos/workspaces. Prohibido `npm` o `yarn`.

---

## 0'. PRINCIPIOS DEL AGENT LOOP

- **Estado global único (Engram)**: cada subagente recibe el estado acumulado completo y únicamente añade su output delimitado. Nunca reescribe ni borra el output de un subagente anterior.
- **Enrutamiento condicional**: el agente primario invoca un subagente si el `stack_manifest` lo hace relevante, no "porque está en la lista". Si no hay capa Flutter en el repo, el subagente Frontend Flutter jamás se invoca.
- **Loop de estados explícito**: `DETECT → PLAN → DESIGN → IMPLEMENT (capas en paralelo lógico) → TEST → AUDIT → (retry ≤2 si <qa_refusal>) → DOCUMENT → DELIVER`.
- **Circuit breaker de QA**: máximo 2 ciclos de `<qa_refusal>` sobre el mismo entregable. Al tercer fallo, el orquestador detiene el pipeline y escala el reporte de diffs al usuario.
- Cero texto conversacional superfluo en outputs intermedios: cada subagente comunica solo estado estructurado.

---

## 1. AGENTE PRIMARIO / ORQUESTADOR

En OpenCode se define como agente primario en `.opencode/agent/orquestador.md` (o se usa el agente `build` por defecto con este `AGENTS.md` cargado). Frontmatter sugerido:

```yaml
---
description: Cerebro, enrutador y director absoluto del flujo. No ejecuta tareas operativas.
mode: primary
model: anthropic/claude-sonnet-4-6
tools:
  write: false
  edit: false
  patch: false
permission:
  bash: ask
---
```

Responsabilidades:
- Recibe el input del usuario e inicializa el estado Engram vacío.
- Invoca siempre primero al subagente Detector de Stack (Fase 0) vía `@detector-stack`.
- Con el `stack_manifest` resuelto, decide dinámicamente qué subagentes de implementación (Fase 3) son aplicables.
- Valida presencia de herramientas de reconocimiento (`.codegraph/`, lockfiles, configs de monorepo) antes de invocar cada subagente.
- Transfiere el estado neto entre capas respetando el orden de dependencias (Impacto → Diseño → Implementación → Test → QA → Docs).
- Aplica el circuit breaker de QA.
- Consolida la salida final de forma hiper-concisa.

## 2. FASE 0 — DETECTOR DE STACK Y ARQUITECTURA

Subagente: `.opencode/agent/detector-stack.md` (`mode: subagent`, tools: `read`, `grep`, `glob`).

Objetivo: construir el `stack_manifest` (mapa objetivo de tecnologías, herramientas y patrones del repo, sin asumir nada).

Proceso Recon: escanear indicadores de stack/monorepo (`package.json`, `pnpm-workspace.yaml`, `turbo.json`, `nx.json`, `pubspec.yaml`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `pom.xml`/`build.gradle`, `composer.json`); usar `.codegraph/` como fuente primaria si existe; identificar apps/paquetes y su framework; inferir patrón arquitectónico (DDD, Clean, MVC, VSA, Hexagonal, feature-first) y convención de testing; detectar ORM/driver y formato de contrato de API; detectar infra (Docker, IaC, CI/CD).

Output: `<s0_output>` con `monorepo_tool`, `packages[]`, `api_contract_format`, `infra_detected`, `codegraph_available`.

## 3. FASE 1 — ANALISTA DE IMPACTO Y CONTRATOS

Subagente: `.opencode/agent/analista-impacto.md`. Determina el impacto del cambio a través de los paquetes de `stack_manifest`. Ejecuta `codegraph_explore` (o `grep`/`glob` si no hay codegraph) acotado a paquetes relevantes; define/modifica contrato en el formato detectado; marca paquetes afectados en cascada.

Output: `<s1_output>` con `impacted_paths`, `api_contract_changes`, `cascade_affected_packages`.

## 4. FASE 2 — ARQUITECTO DE SOLUCIÓN

Subagente: `.opencode/agent/arquitecto.md` (tools de solo lectura + `write` restringido a specs). Diseña la solución técnica antes de escribir código: interfaces/firmas por capa, orden de implementación entre capas, breaking changes.

Output: `<s2_output>` con `interfaces`, `implementation_order`, `breaking_changes`.

## 5. FASE 3 — CAPA DE IMPLEMENTACIÓN (subagentes granulares y condicionales)

Cada uno como archivo independiente en `.opencode/agent/`:

- **Backend** (`role: backend`): `backend-contratos` (DTOs) · `backend-logica` (negocio) · `backend-persistencia` · `backend-api` (controladores) · `backend-tester` → `<s3_backend_output>`.
- **Frontend** (`role: frontend`): `frontend-modelos` · `frontend-estado` (BLoC/Riverpod/Redux/Zustand/Provider) · `frontend-ui` · `frontend-tester` → `<s3_frontend_output>`.
- **Infra** (`infra-iac`): Dockerfiles, CI/CD, IaC → `<s3_infra_output>`.
- **Migraciones** (`db-migrations`): script de migración del ORM, separado de la persistencia → `<s3_migration_output>`.

Cada subagente se invoca solo si `stack_manifest` lo justifica; en paralelo cuando sean independientes entre sí.

## 6. FASE 4 — QA & GATEKEEPER

Subagente: `.opencode/agent/qa-gatekeeper.md` (tools de solo lectura: `read`, `grep`, `bash: ask`, sin `write`/`edit`). Validación implacable de todos los `s3_*_output`, adaptando criterios al `s0_output`.

Criterios: tipado/nulabilidad estrictos según lenguaje; aislamiento de capas según `architecture_pattern`; uso de `codegraph_explore` cuando disponible; cobertura de pruebas explícita; consistencia entre capas respecto a `<s2_output>.interfaces`.

Falla → `<qa_refusal>motivo + diff</qa_refusal>` (circuit breaker ≤2). Óptimo → `<qa_verified>`.

## 7. FASE 5 — DOCUMENTADOR

Subagente: `.opencode/agent/documentador.md`. Tras `<qa_verified>`: changelog (Keep a Changelog / Conventional Commits) + descripción de PR (motivación, `impacted_paths`, `breaking_changes`) → `<s5_output>`.

## 8. STARTUP PROTOCOL & RUNTIME GLOBAL

Al inicio de cada sesión: cargar este `AGENTS.md`, listar agentes disponibles en `.opencode/agent/` (y globales en `~/.config/opencode/agent/`), y confirmar el estado del loop actual.

> [!IMPORTANT]
> **Ejecución Global de Skills (Host-Level)**:
> Todas las skills se ejecutan y resuelven EXCLUSIVAMENTE desde el directorio global del host (`~/.agents/skills/`) y no como dependencias locales del repositorio analizado. La configuración canónica de OpenCode (`~/.config/opencode/opencode.json`) y el archivo `opencode.jsonc` apuntan a `~/.agents/skills`. Ningún proyecto local debe mantener carpetas `.agents/skills` relativas. Si la máquina de trabajo no tiene las skills instaladas, debe ejecutarse previamente `scripts/install-harness.ps1` (Windows) o `scripts/install-harness.sh` (Linux/macOS) desde el repositorio canónico `ia-harness`.

Cuando el requerimiento implique planificación, refactorización, testeo o debugging complejo: leer con `read` el archivo del agente correspondiente (ej. `.opencode/agent/planner.md`, `.opencode/agent/tdd-guide.md`) o delegar vía `@planner` / `@tdd-guide` antes de codificar. Estructura de librería recomendada:

- Subagentes → `~/.config/opencode/agent/*.md` o `.opencode/agent/*.md`
- Skills → `~/.agents/skills/<nombre>/SKILL.md` (Directorio global del sistema en el host)
- Comandos → `~/.config/opencode/command/*.md` o `.opencode/command/*.md`

---

# ECC — Estándares operativos

## Principios

1. **Agent-First** — delega en subagentes especializados vía `@agente`.
2. **Test-Driven** — tests antes de implementar, 80%+ cobertura.
3. **Security-First** — valida todas las entradas.
4. **Immutability** — crea objetos nuevos, nunca mutes.
5. **Plan Before Execute**.

## Orquestación de agentes (proactiva, sin prompt del usuario)

- Feature compleja → `@planner`
- Código recién escrito → `@code-reviewer`
- Bugfix/feature → `@tdd-guide`
- Decisión arquitectónica → `@architect`
- Código sensible → `@security-reviewer`
- Onboarding brownfield → `@spec-miner`
- Loops autónomos → `@loop-operator`
- Config del harness → `@harness-optimizer`

Ejecución en paralelo para operaciones independientes (invocar varios subagentes a la vez con menciones `@` en el mismo turno, o mediante comandos con `subtask: true`).

Reviewers por lenguaje disponibles en `.opencode/agent/`: `cpp`, `csharp`, `fsharp`, `go`, `kotlin`, `java`, `python`, `django`, `fastapi`, `rust`, `typescript`, `react`, `vue`, `flutter`, `php`, `healthcare`, `mle`, `database`, `network`. Build-resolvers análogos para errores de build.

## Seguridad (antes de CUALQUIER commit)

- Sin secretos hardcodeados; entradas validadas; queries parametrizadas (anti SQLi); HTML sanitizado (anti XSS); CSRF; authn/authz verificada; rate limiting; errores sin fugas de datos sensibles.
- Secretos: nunca hardcodear; usar env vars o secret manager; validar al arranque; rotar secretos expuestos de inmediato.
- Si se detecta un issue: **STOP** → `@security-reviewer` → arreglar CRITICAL → rotar secretos → revisar código por casos similares.

## Estilo de código

- **Inmutabilidad (CRÍTICO)**: devolver copias nuevas con los cambios aplicados.
- **Organización**: muchos archivos pequeños (200–400 líneas típico, 800 máx.); por feature/dominio; alta cohesión, bajo acoplamiento.
- **Errores**: manejar en cada nivel; mensajes amigables en UI; contexto detallado en logs de servidor; nunca tragar errores en silencio.
- **Validación**: validar toda entrada en los límites del sistema; validación por esquema; fail fast.
- **Checklist**: funciones <50 líneas, archivos <800, sin anidamiento >4 niveles, sin valores hardcodeados, nombres legibles.

## Testing (mínimo 80%)

Unit + Integration + E2E requeridos. TDD obligatorio: RED (test falla) → GREEN (implementación mínima) → REFACTOR (cobertura 80%+).

## Workflow de desarrollo

1. Plan (`@planner`)
2. TDD (`@tdd-guide`)
3. Review (`@code-reviewer`, atacar CRITICAL/HIGH)
4. Capturar conocimiento en el lugar correcto (skill/AGENTS.md del proyecto vs. skills globales, sin duplicar)
5. Commit (conventional commits + PR summary)

## Git

- Formato commit: `<type>: <description>` — `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `ci`.
- PR: analizar historial completo → resumen comprensivo → plan de pruebas → push con `-u`.

## Arquitectura

API envelope consistente (`success`, `data`, `error`, paginación). Repository pattern (`findAll`/`findById`/`create`/`update`/`delete`) sobre interfaz abstracta. Skeletons: buscar plantillas probadas, evaluar en paralelo, clonar la mejor.

## Performance

Contexto: evitar el último 20% de la ventana en refactors grandes/multi-archivo. Build: `@build-error-resolver` → analizar → arreglar incrementalmente → verificar tras cada fix.

---

## Checklist de puesta en marcha en OpenCode

1. `mkdir -p .opencode/agent .opencode/command .opencode/skills`
2. Copiar este archivo como `AGENTS.md` en la raíz del repo (o correr `/init` y luego fusionar este contenido).
3. Migrar cada subagente de `~/.claude/agents/*.md` a `.opencode/agent/*.md`, agregando el frontmatter YAML (`description`, `mode: subagent`, `model`, `tools`, `permission`).
4. Migrar cada skill de `~/.claude/skills/<nombre>/SKILL.md` a `.opencode/skills/<nombre>/SKILL.md` (formato idéntico, no requiere transformación) — o dejarlas en `.claude/skills/` si se quiere compartir con Claude Code, ya que OpenCode las detecta igual.
5. Migrar cada comando/workflow de `~/.claude/commands/*.md` a `.opencode/command/*.md`.
6. Ajustar `opencode.json` para permisos globales (`bash`, `edit`, `write`) y para forzar `bun` como package manager en los agentes que ejecuten `bash`.
7. Verificar con `/agents` (o equivalente) que el agente primario y todos los subagentes cargan correctamente antes de iniciar el loop `DETECT → PLAN → DESIGN → IMPLEMENT → TEST → AUDIT → DOCUMENT → DELIVER`.
