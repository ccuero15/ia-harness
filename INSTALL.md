# IA Harness — Protocolo Canónico de Instalación Global (Host-Level)

> **Destinatarios:** Agentes de Inteligencia Artificial (Gemini, Antigravity, OpenCode, Claude Code, Cursor, Windsurf, etc.) y Desarrolladores Humanos.  
> **Propósito:** Desplegar de forma estandarizada, desacoplada y reproducible los motores, skills canónicas, configuraciones, directrices y workflows en el host local del usuario (`$HOME` o `%USERPROFILE%`), evitando toda contaminación en repositorios de proyectos locales.

---

## 🛑 PASO 0: Mandato Obligatorio de Enrutamiento (Gatekeeper para Agentes IA)

> [!CAUTION]
> ### REGLA DE DETENCIÓN INMEDIATA PARA EL AGENTE IA
> Si eres un agente de IA ejecutando o interpretando este repositorio:
> **DEBES DETENERTE EN ESTE INSTANTE Y PREGUNTAR AL USUARIO** antes de copiar un solo archivo o ejecutar cualquier script.
> 
> **Mensaje exacto que debes formular al usuario:**
> ```text
> ¿Qué instalación deseas realizar en este equipo?
>  [1] Gemini / Antigravity (Entorno ~/.gemini)
>  [2] OpenCode (Entorno ~/.agents/skills y ~/.config/opencode)
>  [3] Ambas (Instalación completa e independiente)
> ```
> 
> **PROHIBICIÓN ESTRICTA:**
> - Prohibido asumir una opción por defecto.
> - Prohibido autoseleccionar un motor basado en el entorno actual donde te estás ejecutando.
> - Prohibido continuar sin recibir la respuesta explícita del usuario (`1`, `2` o `3`).

---

## 🧭 Resolución de Variables de Entorno y Rutas del Sistema

Antes de iniciar la copia física, resuelve la raíz de usuario del sistema operativo actual:

| Variable | Windows (PowerShell) | Linux / macOS (Bash) |
|---|---|---|
| **Host User Home** | `$env:USERPROFILE` (o `$HOME`) | `$HOME` |
| **Repo Root** | Directorio raíz donde está clonado este repositorio `ia-harness` | Directorio raíz donde está clonado este repositorio `ia-harness` |

### Matriz de Mapeo: Repositorio Fuente ➔ Host Destino

| Componente | Ruta de Origen en Repo (`ia-harness/`) | Ruta Canónica de Destino en el Host | Motor Asociado |
|---|---|---|---|
| **Skills Gemini (26)** | `gemini/.agent/skills/` | `~/.gemini/.agent/skills/` | Gemini / Antigravity |
| **Workflows Speckit (7)** | `gemini/.agent/workflows/` | `~/.gemini/.agent/workflows/` | Gemini / Antigravity |
| **Constitución y Templates** | `gemini/.specify/` | `~/.gemini/.specify/` | Gemini / Antigravity |
| **Hooks de Runtime (3)** | `gemini/hooks/` | `~/.gemini/hooks/` | Gemini / Antigravity |
| **Entry Point Global** | `gemini/GEMINI.md` | `~/.gemini/GEMINI.md` | Gemini / Antigravity |
| **Configuración y MCPs** | `gemini/settings.example.json` | `~/.gemini/settings.json` *(solo si no existe)* | Gemini / Antigravity |
| **Skills OpenCode (26)** | `opencode/.agents/skills/` | `~/.agents/skills/` | OpenCode |
| **Directrices Globales** | `opencode/AGENTS.md` | `~/.config/opencode/AGENTS.md` | OpenCode |
| **Configuración OpenCode** | `opencode/opencode.jsonc` | `~/.config/opencode/opencode.json` *(solo si no existe)* | OpenCode |

---

## ⚡ Flujo de Instalación Rápido por Scripts Automatizados

Si prefieres ejecutar el instalador automatizado provisto en este repositorio:

### En Windows (PowerShell)
```powershell
# Modo interactivo (pregunta [1], [2] o [3]):
powershell -ExecutionPolicy Bypass -File .\scripts\install-harness.ps1

# O con parámetro explícito:
powershell -ExecutionPolicy Bypass -File .\scripts\install-harness.ps1 -Engine Gemini
powershell -ExecutionPolicy Bypass -File .\scripts\install-harness.ps1 -Engine OpenCode
powershell -ExecutionPolicy Bypass -File .\scripts\install-harness.ps1 -Engine All
```

### En Linux / macOS (Bash)
```bash
# Modo interactivo (pregunta [1], [2] o [3]):
chmod +x ./scripts/install-harness.sh && ./scripts/install-harness.sh

# O con parámetro explícito:
./scripts/install-harness.sh --engine Gemini
./scripts/install-harness.sh --engine OpenCode
./scripts/install-harness.sh --engine All
```

---

## 🛠️ Opción 1: Flujo Detallado Paso a Paso para Gemini / Antigravity

Si el usuario respondió `1` (o durante la fase Gemini de la opción `3`), el agente o desarrollador debe realizar exactamente las siguientes operaciones:

### 1.1 Estructura de Directorios en el Host
Crear en el host los siguientes directorios si no existen:
- `~/.gemini/`
- `~/.gemini/.agent/skills/`
- `~/.gemini/.agent/workflows/`
- `~/.gemini/.specify/`
- `~/.gemini/hooks/`

### 1.2 Copia de las 26 Skills Canónicas
Copiar recursivamente cada una de las 26 carpetas de skills desde `gemini/.agent/skills/` hacia `~/.gemini/.agent/skills/`:
- `agile-delivery-governance`
- `coder`
- `daily_analysis`
- `engram-memory-protocol`
- `engram-project-structure`
- `engram-testing-coverage`
- `find-skills`
- `frontend-design`
- `graphify`
- `gsap`
- `interface-design`
- `memory-keeper`
- `nestjs-best-practices`
- `next-best-practices`
- `orchestrator`
- `pm_lead`
- `reviewer`
- `skill-creator`
- `solid`
- `spec-writer`
- `subagent-driven-development`
- `systematic-debugging`
- `task_runner`
- `test-driven-development`
- `verification-before-completion`
- `vertical-slice-architecture`

### 1.3 Copia de los 7 Workflows Speckit
Copiar los 7 archivos Markdown desde `gemini/.agent/workflows/` hacia `~/.gemini/.agent/workflows/`:
1. `speckit.constitution.md`
2. `speckit.specify.md`
3. `speckit.clarify.md`
4. `speckit.planning.md`
5. `speckit.tasks.md`
6. `speckit.implement.md`
7. `speckit.memory-sync.md`

### 1.4 Copia de la Gobernanza y Plantillas (.specify)
Copiar recursivamente todo el contenido de `gemini/.specify/` hacia `~/.gemini/.specify/`:
- `memory/constitution.md` (directivas del SDD, TDD y Graphify)
- `templates/plan-template.md`
- `templates/spec-template.md`
- `templates/tasks-template.md`

### 1.5 Copia de los Hooks de Runtime
Copiar los 3 scripts de ciclo de vida desde `gemini/hooks/` hacia `~/.gemini/hooks/`:
- `after-tool.ps1`
- `before-tool.ps1`
- `session-start.ps1`  
*(En Linux/macOS, otorgar permisos de ejecución si se convierten a bash o wrapper).*

### 1.6 Copia de GEMINI.md
Copiar el archivo `gemini/GEMINI.md` directamente en `~/.gemini/GEMINI.md`. Este es el punto de entrada maestro para el orquestador Antigravity / Gemini.

### 1.7 Creación Segura de `settings.json`
- **Condición de seguridad:** Verificar si `~/.gemini/settings.json` ya existe.
- Si **NO** existe: Copiar `gemini/settings.example.json` a `~/.gemini/settings.json`.
- Si **YA** existe: **NO sobrescribir**, para preservar credenciales y tokens personales del usuario (salvo que el usuario solicite explícitamente `--force`).

---

## 🛠️ Opción 2: Flujo Detallado Paso a Paso para OpenCode

Si el usuario respondió `2` (o durante la fase OpenCode de la opción `3`), realizar exactamente las siguientes operaciones:

### 2.1 Estructura de Directorios en el Host
Crear en el host los siguientes directorios si no existen:
- `~/.agents/skills/`
- `~/.config/opencode/`

### 2.2 Copia de las 26 Skills Globales para OpenCode
Copiar recursivamente las 26 skills desde `opencode/.agents/skills/` hacia `~/.agents/skills/`.
> [!NOTE]
> OpenCode resuelve por convención estándar las herramientas y habilidades desde `~/.agents/skills/`. No deben colocarse dentro de subcarpetas del proyecto local.

### 2.3 Copia de las Directrices de Agentes (`AGENTS.md`)
Copiar el archivo `opencode/AGENTS.md` hacia `~/.config/opencode/AGENTS.md`.  
Este archivo instruye a OpenCode sobre la división de roles, el orquestador primario (`@Leader`), los subagentes (`@Build`, `@Review`, `@Plan`, etc.) y el protocolo de memoria dual.

### 2.4 Creación Segura de `opencode.json`
- **Condición de seguridad:** Verificar si `~/.config/opencode/opencode.json` ya existe.
- Si **NO** existe: Copiar `opencode/opencode.jsonc` hacia `~/.config/opencode/opencode.json`.
- Si **YA** existe: **NO sobrescribir**, preservando endpoints de modelos locales o claves de API configuradas previamente.

---

## 🔄 Opción 3: Flujo para Instalación Dual (Ambas)

Si el usuario seleccionó `3` ("Ambas"):
1. **Fase 1:** Ejecutar íntegramente la **Opción 1 (Gemini / Antigravity)**.
2. **Fase 2:** Ejecutar íntegramente la **Opción 2 (OpenCode)**.
3. **Garantía de Aislamiento:** Las rutas de Gemini (`~/.gemini/`) y las rutas de OpenCode (`~/.agents/skills/` y `~/.config/opencode/`) permanecen físicamente separadas. Ningún archivo de Gemini debe depositarse en `.agents/` y ningún archivo de OpenCode debe depositarse en `.gemini/`.

---

## 🔍 Comandos de Verificación Post-Instalación

El agente de IA o el operador humano **DEBE** ejecutar los siguientes comandos para certificar que todos los componentes requeridos fueron instalados con éxito en el host.

### Verificación en Windows (PowerShell)

#### Para Gemini / Antigravity:
```powershell
$gemini = if ($env:USERPROFILE) { Join-Path $env:USERPROFILE ".gemini" } else { Join-Path $HOME ".gemini" }
Write-Host "Verificando Gemini en $gemini..." -ForegroundColor Cyan

$skillsCount = (Get-ChildItem -Path "$gemini\.agent\skills" -Directory -ErrorAction SilentlyContinue).Count
$workflowsCount = (Get-ChildItem -Path "$gemini\.agent\workflows" -File -ErrorAction SilentlyContinue).Count
$hooksCount = (Get-ChildItem -Path "$gemini\hooks" -File -ErrorAction SilentlyContinue).Count
$constitutionPath = "$gemini\.specify\memory\constitution.md"
$geminiMdPath = "$gemini\GEMINI.md"
$settingsPath = "$gemini\settings.json"

Write-Host "  Skills (Esperadas: 26)       : $skillsCount" -ForegroundColor $(if ($skillsCount -eq 26) { "Green" } else { "Red" })
Write-Host "  Workflows (Esperados: 7)     : $workflowsCount" -ForegroundColor $(if ($workflowsCount -eq 7) { "Green" } else { "Red" })
Write-Host "  Constitución (.specify)      : $(Test-Path $constitutionPath)" -ForegroundColor $(if (Test-Path $constitutionPath) { "Green" } else { "Red" })
Write-Host "  Hooks de runtime (3)         : $hooksCount" -ForegroundColor $(if ($hooksCount -eq 3) { "Green" } else { "Red" })
Write-Host "  GEMINI.md                    : $(Test-Path $geminiMdPath)" -ForegroundColor $(if (Test-Path $geminiMdPath) { "Green" } else { "Red" })
Write-Host "  settings.json                : $(Test-Path $settingsPath)" -ForegroundColor $(if (Test-Path $settingsPath) { "Green" } else { "Red" })
```

#### Para OpenCode:
```powershell
$userHome = if ($env:USERPROFILE) { $env:USERPROFILE } else { $HOME }
$openCodeSkills = Join-Path $userHome ".agents\skills"
$openCodeConfig = Join-Path $userHome ".config\opencode"
$openCodeAgentsPath = Join-Path $openCodeConfig "AGENTS.md"
$openCodeJsonPath = Join-Path $openCodeConfig "opencode.json"
Write-Host "Verificando OpenCode..." -ForegroundColor Cyan

$skillsCount = (Get-ChildItem -Path $openCodeSkills -Directory -ErrorAction SilentlyContinue).Count

Write-Host "  Skills en ~/.agents/skills (26): $skillsCount" -ForegroundColor $(if ($skillsCount -eq 26) { "Green" } else { "Red" })
Write-Host "  AGENTS.md en ~/.config/opencode: $(Test-Path $openCodeAgentsPath)" -ForegroundColor $(if (Test-Path $openCodeAgentsPath) { "Green" } else { "Red" })
Write-Host "  opencode.json configurado      : $(Test-Path $openCodeJsonPath)" -ForegroundColor $(if (Test-Path $openCodeJsonPath) { "Green" } else { "Red" })
```

---

### Verificación en Linux / macOS (Bash)

#### Para Gemini / Antigravity:
```bash
GEMINI_DIR="${HOME}/.gemini"
echo "Verificando Gemini en ${GEMINI_DIR}..."

SKILLS_COUNT=$(find "${GEMINI_DIR}/.agent/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
WORKFLOWS_COUNT=$(find "${GEMINI_DIR}/.agent/workflows" -maxdepth 1 -type f 2>/dev/null | wc -l)
HOOKS_COUNT=$(find "${GEMINI_DIR}/hooks" -maxdepth 1 -type f 2>/dev/null | wc -l)

echo "  Skills instaladas (Esperadas: 26): ${SKILLS_COUNT}"
echo "  Workflows (Esperados: 7)          : ${WORKFLOWS_COUNT}"
echo "  Hooks de runtime (Esperados: 3)   : ${HOOKS_COUNT}"
[[ -f "${GEMINI_DIR}/.specify/memory/constitution.md" ]] && echo "  Constitución: OK" || echo "  Constitución: FALTA"
[[ -f "${GEMINI_DIR}/GEMINI.md" ]] && echo "  GEMINI.md: OK" || echo "  GEMINI.md: FALTA"
[[ -f "${GEMINI_DIR}/settings.json" ]] && echo "  settings.json: OK" || echo "  settings.json: FALTA"
```

#### Para OpenCode:
```bash
OPENCODE_SKILLS="${HOME}/.agents/skills"
OPENCODE_CONFIG="${HOME}/.config/opencode"
echo "Verificando OpenCode..."

SKILLS_COUNT=$(find "${OPENCODE_SKILLS}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
echo "  Skills en ~/.agents/skills (Esperadas: 26): ${SKILLS_COUNT}"
[[ -f "${OPENCODE_CONFIG}/AGENTS.md" ]] && echo "  AGENTS.md: OK" || echo "  AGENTS.md: FALTA"
[[ -f "${OPENCODE_CONFIG}/opencode.json" ]] && echo "  opencode.json: OK" || echo "  opencode.json: FALTA"
```

---

## ⚖️ Reglas No Negociables para Agentes de IA

1. **Host-Level Runtime Absoluto**:
   - Todo componente operativo (skills, workflows, gobernanza, hooks, configuraciones) debe residir en el host (`~/.gemini` o `~/.agents/skills` / `~/.config/opencode`).
   - **NUNCA** crees ni busques skills en carpetas locales de proyectos de trabajo (`./.agents/skills` o `./.gemini`).
2. **Cero Contaminación Cruzada**:
   - No instales hooks de Antigravity dentro de `~/.config/opencode`.
   - No copies `opencode.json` dentro de `~/.gemini/`.
   - Las 26 skills de Gemini pertenecen a `~/.gemini/.agent/skills/`. Las de OpenCode pertenecen a `~/.agents/skills/`.
3. **Cero Credenciales Expuestas**:
   - Nunca expongas ni subas al repositorio tokens de GitHub (`ghp_...`), claves de Anthropic, Google Gemini o paths privados.
   - Las plantillas de configuración deben distribuirse sanitizadas (`settings.example.json` y `opencode.jsonc`).
4. **No Destructivo**:
   - Si un archivo de configuración real (`settings.json` o `opencode.json`) ya existe en el host, consérvalo intacto a menos que se indique `--force`.
