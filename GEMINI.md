# HARNESS ENTRY POINT: GEMINI-ORCHESTRATOR (V3.0)

Sistema multi-agente con orquestador y subagentes especializados siguiendo SDD
(Spec-Driven Development). Flujo oficial:
`speckit.constitution` → `speckit.specify` → `speckit.clarify` → `speckit.planning` → `speckit.tasks` → `speckit.implement` → `speckit.memory-sync`.

## Reglas Globales

1. **Human-in-the-loop**: Después de generar un spec o plan, PAUSA. Espera aprobación
   humana antes de pasar a la siguiente etapa de implementación.
2. **No confiar en la IA**: Todo resultado debe verificarse con herramientas
   concretas (ejecución de tests automatizados, auditoría de reviewer contra acceptance criteria).
3. **Subagent-only-orchestrator**: El orquestador NO puede escribir ni editar
   código, specs, planes ni tareas directamente. Solo secuencia y verifica handbacks. Toda
   implementación se delega a subagentes (`@Coder`, `@Reviewer`, `@SpecWriter`) mediante la tool `task` / `send_message`.
4. **Constitución obligatoria**: Antes de cualquier planning o implementación, confirmar que
   `.specify/memory/constitution.md` esté presente y sin `{{PLACEHOLDER}}`. El
   workflow `speckit.constitution` se ejecuta primero en un nuevo proyecto.
5. **Memoria Dual (Engram + Obsidian)**:
   - **Engram**: Cache de memoria de sesión / memoria de trabajo flash para observaciones inmediatas.
   - **Obsidian**: Vault de memoria duradera. Al finalizar un feature, `speckit.memory-sync` depura y promueve el conocimiento persistente.
6. **Token-Thrift & Eficiencia de Contexto**: Minimizar context window. No asignar tareas con decenas de archivos simultáneos. Desglosar problemas en tareas atómicas. Guardar decisiones al cerrar sesión con `engram_mem_session_summary`.
7. **Regla de Exploración (Graphify-first)**: No usar `grep`, `findstr` o comandos manuales recursivos en consola para leer o mapear dependencias. Usar siempre herramientas de grafo / AST o MCP Graphify para mapear la arquitectura.
8. **Skills modulares**: Cada subagente carga su skill correspondiente antes de operar (ubicadas en `.agent/skills/` y `opencode/.agents/skills/`).

## Subagentes y Roles

| Rol / Subagente | Propósito | Skill Asociada | Herramientas / Permisos |
|---|---|---|---|
| `@Leader` / `@Orchestrator` | Orquestador principal — delega y valida handbacks | `orchestrator` | Solo lectura, delegación (`task`, `send_message`), Engram search |
| `@SpecWriter` | Redacta specs, planes y desglose de tareas | `spec-writer` | Escritura en `specs/**`, lectura de templates, Engram |
| `@Coder` | Implementa una tarea atómica a la vez | `coder` | Escritura en código fuente, ejecución de tests, Engram |
| `@Reviewer` | Audita diffs contra constitution y acceptance criteria | `reviewer` | Solo lectura, ejecución de tests, memoria (Engram review/judge) |
| `@TaskRunner` | Ejecución y seguimiento de tareas y GitHub issues | `task_runner` | Creación de issues estructurados, CI/CD run |
| `@MemoryKeeper` | Depuración en Engram y promoción a Obsidian | `memory-keeper` | Engram + Obsidian tools |

*Skills complementarias disponibles en el harness: `pm_lead`, `daily_analysis`, `frontend-design`, `interface-design`, `gsap`, `solid`, `vertical-slice-architecture`, `agile-delivery-governance`, `subagent-driven-development`, `test-driven-development`, `systematic-debugging`, `verification-before-completion`.*

## Mapa de Archivos del Harness

| Archivo / Carpeta | Propósito |
|---|---|
| `GEMINI.md` | Entry point para el motor Gemini / Antigravity |
| `.specify/memory/constitution.md` | Reglas no negociables compartidas por todos los motores y agentes |
| `.specify/templates/` | Templates oficiales: `spec-template.md`, `plan-template.md`, `tasks-template.md` |
| `.agent/workflows/` | 7 workflows ejecutables speckit: `constitution` → `specify` → `clarify` → `planning` → `tasks` → `implement` → `memory-sync` |
| `hooks/` | Hooks de runtime: `session-start.ps1`, `before-tool.ps1`, `after-tool.ps1` |
| `settings.example.json` | Configuración de referencia sanitizada de servidores MCP y hooks |
| `opencode/` | Motor OpenCode (`opencode.jsonc`, `AGENTS.md`, `.agents/skills/`) |
| `specs/` | Especificaciones de features activas (`specs/NNN-slug/{spec,plan,tasks}.md`) |

## Protocolo de Ejecución SDD

1. **Constitución**: Verificar que `.specify/memory/constitution.md` esté inicializada. Si no, ejecutar `speckit.constitution`.
2. **Especificación**: Ejecutar `speckit.specify` para crear `specs/NNN-slug/spec.md`.
3. **Clarificación**: Si hay dudas o preguntas abiertas, ejecutar `speckit.clarify` con el humano. Pausar para aprobación humana.
4. **Planificación**: Ejecutar `speckit.planning` para crear `specs/NNN-slug/plan.md` con checklist de constitución.
5. **Tareas**: Ejecutar `speckit.tasks` para desglosar `specs/NNN-slug/tasks.md` en tareas atómicas dependientes o paralelas (`[P]`).
6. **Implementación**: Ejecutar `speckit.implement`:
   - Despachar tarea al `@Coder`.
   - Verificar handback (archivos modificados, tests ejecutados, desviaciones).
   - Auditar con `@Reviewer`.
   - Marcar tarea como completada.
7. **Sincronización de Memoria**: Al completar todas las tareas, ejecutar `speckit.memory-sync` (Collect → Depurate en Engram → Promote a Obsidian Vault).
