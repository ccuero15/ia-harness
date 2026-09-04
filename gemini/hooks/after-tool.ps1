# Tool audit: registra ejecuciones de tools para auditoría
$ErrorActionPreference = 'Continue'
$raw = [Console]::In.ReadToEnd()
$data = $raw | ConvertFrom-Json

$logDir = Join-Path $env:USERPROFILE '.gemini\logs'
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Force -Path $logDir | Out-Null }
$logFile = Join-Path $logDir 'tool-audit.log'
$line = "[{0}] tool={1} session={2}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $data.tool_name, $data.session_id
Add-Content -Path $logFile -Value $line

$output = @{ suppressOutput = $true }
$output | ConvertTo-Json -Depth 5
