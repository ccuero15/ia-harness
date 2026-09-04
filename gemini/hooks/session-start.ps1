# Context Pipeline: inyecta AGENTS.md + constitution + estado de proyectos en el system prompt
$ErrorActionPreference = 'Stop'
$raw = [Console]::In.ReadToEnd()
$data = $null
if ($raw) {
    try { $data = $raw | ConvertFrom-Json } catch {}
}

$home = $env:USERPROFILE
$context = @()

# 1. AGENTS.md (local workspace or global)
$localAgents = Join-Path $PSScriptRoot '..\opencode\AGENTS.md'
$globalAgents = Join-Path $home '.gemini\AGENTS.md'
if (Test-Path $localAgents) {
    $context += '=== GLOBAL RULES (AGENTS.md) ==='
    $context += (Get-Content (Resolve-Path $localAgents) -Raw)
} elseif (Test-Path $globalAgents) {
    $context += '=== GLOBAL RULES (AGENTS.md) ==='
    $context += (Get-Content $globalAgents -Raw)
}

# 2. Constitution (local workspace or global)
$localConstitution = Join-Path $PSScriptRoot '..\.specify\memory\constitution.md'
$globalConstitution = Join-Path $home '.gemini\.specify\memory\constitution.md'
if (Test-Path $localConstitution) {
    $context += '=== CONSTITUTION ==='
    $context += (Get-Content (Resolve-Path $localConstitution) -Raw)
} elseif (Test-Path $globalConstitution) {
    $context += '=== CONSTITUTION ==='
    $context += (Get-Content $globalConstitution -Raw)
}

# 3. Projects state
$projectsPath = Join-Path $home '.gemini\projects.json'
if (Test-Path $projectsPath) {
    $context += '=== PROJECT STATE ==='
    $context += (Get-Content $projectsPath -Raw)
}

$output = @{
    hookSpecificOutput = @{
        additionalContext = ($context -join "`n`n")
    }
}
$output | ConvertTo-Json -Depth 5
