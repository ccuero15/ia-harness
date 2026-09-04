<#
.SYNOPSIS
    Instalador global del IA Harness para Windows (PowerShell).
.DESCRIPTION
    Copia e instala los componentes del repositorio ia-harness en las rutas
    globales canónicas del host (~/.gemini y ~/.agents/skills), desacoplando
    la ejecución del entorno local de cada proyecto.
.PARAMETER Engine
    Motor a instalar: 'All', 'Gemini', 'OpenCode'. Por defecto 'All'.
.PARAMETER Force
    Sobrescribe archivos de configuración existentes si se especifica.
.EXAMPLE
    .\scripts\install-harness.ps1 -Engine All
    .\scripts\install-harness.ps1 -Engine Gemini
    .\scripts\install-harness.ps1 -Engine OpenCode
#>

[CmdletBinding()]
param(
    [ValidateSet('All', 'Gemini', 'OpenCode')]
    [string]$Engine = 'All',
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

# Resolver rutas base
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = (Resolve-Path (Join-Path $ScriptDir "..")).Path
$UserHome = if ($env:USERPROFILE) { $env:USERPROFILE } else { $HOME }

# Rutas de origen en el repositorio
$SkillsSource         = Join-Path $RepoRoot "opencode\.agents\skills"
$WorkflowsSource      = Join-Path $RepoRoot ".agent\workflows"
$SpecifySource        = Join-Path $RepoRoot ".specify"
$HooksSource          = Join-Path $RepoRoot "hooks"
$GeminiMDSource       = Join-Path $RepoRoot "GEMINI.md"
$SettingsSource       = Join-Path $RepoRoot "settings.example.json"
$OpenCodeConfigSource = Join-Path $RepoRoot "opencode\opencode.jsonc"

# Rutas de destino globales en el host
$GeminiBaseDir        = Join-Path $UserHome ".gemini"
$GeminiSkillsDir      = Join-Path $GeminiBaseDir ".agent\skills"
$GeminiWorkflowsDir   = Join-Path $GeminiBaseDir ".agent\workflows"
$GeminiSpecifyDir     = Join-Path $GeminiBaseDir ".specify"
$GeminiHooksDir       = Join-Path $GeminiBaseDir "hooks"
$GeminiMDTarget       = Join-Path $GeminiBaseDir "GEMINI.md"
$GeminiSettingsTarget = Join-Path $GeminiBaseDir "settings.json"

$OpenCodeSkillsDir    = Join-Path $UserHome ".agents\skills"
$OpenCodeConfigDir    = Join-Path $UserHome ".config\opencode"
$OpenCodeConfigTarget = Join-Path $OpenCodeConfigDir "opencode.json"

function Write-Step {
    param([string]$Message)
    Write-Host "`n[STEP] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "  [OK] $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "  [INFO] $Message" -ForegroundColor Gray
}

function Write-Warn {
    param([string]$Message)
    Write-Host "  [WARN] $Message" -ForegroundColor Yellow
}

function Copy-SkillsTo {
    param(
        [string]$DestinationDir,
        [string]$EngineName
    )
    if (-not (Test-Path $SkillsSource)) {
        Write-Warn "Directorio de origen de skills no encontrado: $SkillsSource"
        return
    }

    if (-not (Test-Path $DestinationDir)) {
        New-Item -ItemType Directory -Path $DestinationDir -Force | Out-Null
        Write-Info "Creado directorio: $DestinationDir"
    }

    $skillDirs = Get-ChildItem -Path $SkillsSource -Directory
    $count = 0
    foreach ($dir in $skillDirs) {
        $dest = Join-Path $DestinationDir $dir.Name
        if (-not (Test-Path $dest)) {
            New-Item -ItemType Directory -Path $dest -Force | Out-Null
        }
        Copy-Item -Path (Join-Path $dir.FullName "*") -Destination $dest -Recurse -Force
        $count++
    }
    Write-Success "$count skills instaladas en $DestinationDir ($EngineName)"
}

Write-Host "============================================================" -ForegroundColor Magenta
Write-Host "         IA HARNESS — INSTALADOR GLOBAL DE RUNTIME         " -ForegroundColor Magenta
Write-Host "============================================================" -ForegroundColor Magenta
Write-Info "Repositorio Fuente : $RepoRoot"
Write-Info "Directorio Host    : $UserHome"
Write-Info "Motor Seleccionado : $Engine"

# ─────────────────────────────────────────────────────────────────────────────
# Instalación Gemini / Antigravity
# ─────────────────────────────────────────────────────────────────────────────
if ($Engine -eq 'All' -or $Engine -eq 'Gemini') {
    Write-Step "Instalando runtime para Gemini / Antigravity..."

    # 1. Skills
    Copy-SkillsTo -DestinationDir $GeminiSkillsDir -EngineName "Gemini"

    # 2. Workflows
    if (Test-Path $WorkflowsSource) {
        if (-not (Test-Path $GeminiWorkflowsDir)) {
            New-Item -ItemType Directory -Path $GeminiWorkflowsDir -Force | Out-Null
        }
        $wfFiles = Get-ChildItem -Path $WorkflowsSource -File
        foreach ($wf in $wfFiles) {
            Copy-Item -Path $wf.FullName -Destination (Join-Path $GeminiWorkflowsDir $wf.Name) -Force
        }
        Write-Success "$($wfFiles.Count) workflows speckit instalados en $GeminiWorkflowsDir"
    }

    # 3. .specify (Constitución y plantillas)
    if (Test-Path $SpecifySource) {
        if (-not (Test-Path $GeminiSpecifyDir)) {
            New-Item -ItemType Directory -Path $GeminiSpecifyDir -Force | Out-Null
        }
        Copy-Item -Path (Join-Path $SpecifySource "*") -Destination $GeminiSpecifyDir -Recurse -Force
        Write-Success "Capa de gobernanza (.specify) instalada en $GeminiSpecifyDir"
    }

    # 4. Hooks
    if (Test-Path $HooksSource) {
        if (-not (Test-Path $GeminiHooksDir)) {
            New-Item -ItemType Directory -Path $GeminiHooksDir -Force | Out-Null
        }
        $hookFiles = Get-ChildItem -Path $HooksSource -File
        foreach ($hk in $hookFiles) {
            Copy-Item -Path $hk.FullName -Destination (Join-Path $GeminiHooksDir $hk.Name) -Force
        }
        Write-Success "$($hookFiles.Count) hooks de runtime instalados en $GeminiHooksDir"
    }

    # 5. GEMINI.md
    if (Test-Path $GeminiMDSource) {
        Copy-Item -Path $GeminiMDSource -Destination $GeminiMDTarget -Force
        Write-Success "Entry point global instalado en $GeminiMDTarget"
    }

    # 6. settings.json
    if (-not (Test-Path $GeminiSettingsTarget)) {
        if (Test-Path $SettingsSource) {
            Copy-Item -Path $SettingsSource -Destination $GeminiSettingsTarget
            Write-Success "Plantilla settings.json inicializada en $GeminiSettingsTarget"
        }
    } elseif ($Force) {
        Copy-Item -Path $SettingsSource -Destination $GeminiSettingsTarget -Force
        Write-Warn "settings.json sobrescrito forzosamente con settings.example.json"
    } else {
        Write-Info "settings.json preexistente conservado en $GeminiSettingsTarget (usa -Force para sobrescribir)"
    }
}

# ─────────────────────────────────────────────────────────────────────────────
# Instalación OpenCode
# ─────────────────────────────────────────────────────────────────────────────
if ($Engine -eq 'All' -or $Engine -eq 'OpenCode') {
    Write-Step "Instalando runtime para OpenCode..."

    # 1. Skills globales (~/.agents/skills)
    Copy-SkillsTo -DestinationDir $OpenCodeSkillsDir -EngineName "OpenCode"

    # 2. Configuración (~/.config/opencode/opencode.json)
    if (-not (Test-Path $OpenCodeConfigDir)) {
        New-Item -ItemType Directory -Path $OpenCodeConfigDir -Force | Out-Null
        Write-Info "Creado directorio: $OpenCodeConfigDir"
    }

    if (-not (Test-Path $OpenCodeConfigTarget)) {
        if (Test-Path $OpenCodeConfigSource) {
            Copy-Item -Path $OpenCodeConfigSource -Destination $OpenCodeConfigTarget
            Write-Success "Configuración inicializada en $OpenCodeConfigTarget"
        }
    } elseif ($Force) {
        Copy-Item -Path $OpenCodeConfigSource -Destination $OpenCodeConfigTarget -Force
        Write-Warn "opencode.json sobrescrito forzosamente con opencode.jsonc"
    } else {
        Write-Info "opencode.json preexistente conservado en $OpenCodeConfigTarget (usa -Force para sobrescribir)"
    }
}

Write-Host "`n============================================================" -ForegroundColor Green
Write-Host "       INSTALACIÓN DEL HARNESS COMPLETADA EXITOSAMENTE     " -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Info "Los motores ahora ejecutan y resuelven skills desde las rutas globales del host."
