# Gemini / Antigravity Harness

Entorno de desarrollo asistido por IA multi-agente diseñado para **Gemini CLI** y el ecosistema **Antigravity**, fundamentado en **Spec-Driven Development (SDD)**, **Test-Driven Development (TDD)** y **Graphify-First**.

---

## 🏗️ Estructura del Motor Gemini

Todos los assets y componentes requeridos para operar con Gemini y Antigravity se encuentran aislados dentro de este directorio:

```text
gemini/
├── GEMINI.md                         # Entry point global para el agente orquestador
├── settings.example.json             # Plantilla sanitizada de configuración MCP y hooks
├── README.md                         # Documentación de este motor
├── .agent/
│   ├── skills/                       # 26 skills canónicas para subagentes
│   └── workflows/                    # Ciclo de vida Speckit ejecutable (7 pasos)
│       ├── speckit.constitution.md   # Validación y establecimiento de la constitución
│       ├── speckit.specify.md        # Generación de spec.md
│       ├── speckit.clarify.md        # Clarificación interactiva de dudas
│       ├── speckit.planning.md       # Generación de plan.md y constitution checklist
│       ├── speckit.tasks.md          # Desglose en tasks.md atómicas y paralelas
│       ├── speckit.implement.md      # Ciclo de implementación (Coder -> Reviewer -> Tests)
│       └── speckit.memory-sync.md    # Sincronización de memoria flash a Obsidian Vault
├── .specify/                         # Capa de gobernanza y especificación
│   ├── memory/
│   │   └── constitution.md           # Reglas no negociables del proyecto
│   └── templates/                    # Plantillas de ingeniería (spec, plan, tasks)
│       ├── spec-template.md
│       ├── plan-template.md
│       └── tasks-template.md
└── hooks/                            # Hooks de runtime de Antigravity
    ├── session-start.ps1             # Context pipeline (inyección de constitución y reglas)
    ├── before-tool.ps1               # RBAC dispatcher (bloqueo de herramientas peligrosas)
    └── after-tool.ps1                # Auditoría y telemetría de ejecución de herramientas
```

---

## 💻 Instalación y Runtime Global en el Host

En tiempo de ejecución, el motor Gemini / Antigravity **no** se ejecuta directamente desde este repositorio, sino desde las rutas globales del usuario (`~/.gemini/`):

| Componente Fuente (`gemini/`) | Destino Host Global (`~/.gemini/`) | Función en Runtime |
|---|---|---|
| `gemini/GEMINI.md` | `~/.gemini/GEMINI.md` | Contexto inicial y directivas del orquestador |
| `gemini/.agent/skills/` | `~/.gemini/.agent/skills/` | Catálogo de las 26 skills para subagentes |
| `gemini/.agent/workflows/` | `~/.gemini/.agent/workflows/` | Workflows ejecutables del ciclo SDD Speckit |
| `gemini/.specify/` | `~/.gemini/.specify/` | Constitución y plantillas oficiales |
| `gemini/hooks/` | `~/.gemini/hooks/` | Hooks de seguridad, contexto y auditoría |
| `gemini/settings.example.json` | `~/.gemini/settings.json` | Configuración de servidores MCP y hooks |

### Comando de Instalación
Para desplegar exclusivamente el entorno Gemini en tu máquina:

- **Windows (PowerShell)**:
  ```powershell
  powershell -ExecutionPolicy Bypass -File .\scripts\install-harness.ps1 -Engine Gemini
  ```
- **Linux / macOS (Bash)**:
  ```bash
  chmod +x ./scripts/install-harness.sh
  ./scripts/install-harness.sh --engine Gemini
  ```

---

## 🤖 Roles y Subagentes

El orquestador (`@Leader` / `@Orchestrator`) delega la totalidad del trabajo operativo a subagentes especializados:

| Subagente | Skill Principal | Misión y Permisos |
|---|---|---|
| `@Leader` / `@Orchestrator` | `orchestrator` | Secuenciación SDD, asignación de tareas vía `task` / `send_message`. No toca código ni modifica specs. |
| `@SpecWriter` | `spec-writer` | Creación y mantenimiento de `specs/NNN-slug/{spec,plan,tasks}.md`. |
| `@Coder` | `coder` | Implementación de tareas atómicas siguiendo TDD estricto. Ejecución de tests. |
| `@Reviewer` | `reviewer` | Auditoría de diffs contra la constitución y criterios de aceptación. Solo lectura. |
| `@TaskRunner` | `task_runner` | Automatización de issues de GitHub y trazabilidad. |
| `@MemoryKeeper` | `memory-keeper` | Depuración de observaciones en Engram y promoción hacia el vault de Obsidian. |

---

## 🛡️ Hooks de Seguridad y Runtime (RBAC)

1. **`session-start.ps1`**:
   - Inyecta automáticamente la constitución (`.specify/memory/constitution.md`) y directivas operativas al abrir una sesión en Antigravity.
2. **`before-tool.ps1`**:
   - Evalúa cada llamada a herramienta antes de ser ejecutada.
   - Bloquea comandos peligrosos destructivos (ej. `rmdir /s`, `format`, borrado recursivo no autorizado).
3. **`after-tool.ps1`**:
   - Registra telemetría y auditoría de las acciones concluidas por las herramientas.

---

## 🔄 Flujo SDD (Spec-Driven Development)

1. **Constitución (`speckit.constitution`)**: Validación de reglas sin placeholders.
2. **Especificación (`speckit.specify`)**: Creación de especificaciones funcionales y criterios de aceptación.
3. **Clarificación (`speckit.clarify`)**: Diálogo con el humano para resolver dudas. **Pausa Human-in-the-Loop obligatoria**.
4. **Planificación (`speckit.planning`)**: Definición del plan técnico y verificación contra la constitución.
5. **Tareas (`speckit.tasks`)**: Desglose atómico (`[P]` para tareas paralelizables).
6. **Implementación (`speckit.implement`)**: Despacho de subagentes (Coder → Reviewer → Tests).
7. **Sincronización de Memoria (`speckit.memory-sync`)**: Promoción de aprendizajes a Obsidian.
