# OpenCode Harness

Entorno de desarrollo asistido por IA multi-agente diseñado para **OpenCode** (opencode.ai), optimizado para arquitecturas complejas, ejecución modular con subagentes especializados, **Graphify-First**, **TDD estricto** y control de contexto de alta eficiencia (**Token-Thrift**).

---

## 🏗️ Estructura del Motor OpenCode

Todos los componentes específicos del runtime de OpenCode se encuentran aislados dentro de este directorio:

```text
opencode/
├── opencode.jsonc                    # Configuración canónica: agentes, permisos, modelos y MCPs
├── AGENTS.md                         # Directrices operativas de OpenCode y protocolos de agentes
├── README.md                         # Documentación de este motor
├── package.json & package-lock.json  # Dependencias y herramientas de soporte
└── .agents/
    ├── .skill-lock.json              # Registro de integridad de skills
    └── skills/                       # Catálogo canónico de distribución de 26 skills
        ├── orchestrator/
        ├── coder/
        ├── reviewer/
        ├── spec-writer/
        ├── task_runner/
        ├── memory-keeper/
        ├── pm_lead/
        ├── daily_analysis/
        ├── agile-delivery-governance/
        ├── subagent-driven-development/
        ├── test-driven-development/
        ├── systematic-debugging/
        ├── verification-before-completion/
        ├── solid/
        ├── vertical-slice-architecture/
        ├── graphify/
        ├── frontend-design/
        ├── interface-design/
        ├── gsap/
        └── ...
```

---

## 💻 Instalación y Runtime Global en el Host

OpenCode opera resolviendo sus directivas y herramientas desde las ubicaciones globales del usuario en el host, evitando ensuciar los repositorios individuales de cada proyecto:

| Componente Fuente (`opencode/`) | Destino Host Global | Función en Runtime |
|---|---|---|
| `opencode/.agents/skills/` | `~/.agents/skills/` | Catálogo de skills global consumible vía tool nativa `skill` |
| `opencode/opencode.jsonc` | `~/.config/opencode/opencode.json` | Configuración de agentes primarios, subagentes y MCPs |

### Comando de Instalación
Para desplegar exclusivamente el entorno OpenCode en tu máquina:

- **Windows (PowerShell)**:
  ```powershell
  powershell -ExecutionPolicy Bypass -File .\scripts\install-harness.ps1 -Engine OpenCode
  ```
- **Linux / macOS (Bash)**:
  ```bash
  chmod +x ./scripts/install-harness.sh
  ./scripts/install-harness.sh --engine OpenCode
  ```

---

## 🤖 Arquitectura de Agentes y Flujo Operativo

OpenCode utiliza un modelo jerárquico donde el agente primario coordina y subagentes granulares ejecutan:

1. **Agente Primario / Orquestador (`@orquestador` / `build`)**:
   - Modo: `primary`.
   - Permisos de edición de código: **Deshabilitados** (`write: false`, `edit: false`, `patch: false`).
   - Función: Enrutamiento, control de calidad, delegación y consolidación de estado.
2. **Fase 0 — Detección (`@detector-stack`)**:
   - Inspección de monorepos, frameworks, herramientas y dependencias para generar el `stack_manifest`.
3. **Fase 1 — Análisis de Impacto (`@analista-impacto`)**:
   - Mapeo de dependencias mediante AST y grafo (`graphify`) para evaluar el radio de afectación.
4. **Fase 2 — Diseño y Arquitectura (`@arquitecto`)**:
   - Diseño previo de contratos de API, firmas e interfaces por capa antes de programar.
5. **Fase 3 — Implementación por Capas**:
   - Subagentes dedicados para backend (`backend-contratos`, `backend-logica`, `backend-api`), frontend (`frontend-modelos`, `frontend-ui`), migraciones e infra.
6. **Fase 4 & 5 — Testing y Auditoría**:
   - Validación TDD estricta (Red-Green-Refactor) con circuit breaker de QA (máximo 2 ciclos de reintento).

---

## ⚡ Reglas Transversales y Buenas Prácticas

- **Skill-First**: Todo agente debe cargar su skill correspondiente (`skill <name>` o leyendo `~/.agents/skills/<name>/SKILL.md`) antes de ejecutar tareas.
- **Graphify-First**: Uso de grafo estructural en lugar de búsquedas recursivas en texto plano (`grep`/`findstr`).
- **Token-Thrift**: Sin preámbulos ni cortesías conversacionales; comunicación por estados delimitados y estructuras compactas.
- **Gestión con Bun**: Uso preferente y estricto de `bun` para dependencias y ejecución de scripts.
