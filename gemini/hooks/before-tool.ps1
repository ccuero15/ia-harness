# Runtime Hook Dispatcher: valida tool.execute.before contra RBAC
$ErrorActionPreference = 'Stop'
$raw = [Console]::In.ReadToEnd()
$data = $raw | ConvertFrom-Json

$toolName = $data.tool_name
$toolInput = $data.tool_input

if ($toolName -eq 'run_shell_command') {
    $cmd = $toolInput.command
    $dangerous = @('rm -rf', 'Remove-Item -Recurse -Force', 'git push --force', 'git push -f', 'format c:', 'del /s /q', 'rd /s /q')
    foreach ($pattern in $dangerous) {
        if ($cmd -like "*$pattern*") {
            $output = @{
                decision = 'deny'
                reason = "BLOCKED by RBAC: dangerous command pattern '$pattern' is forbidden."
            }
            $output | ConvertTo-Json -Depth 5
            exit 0
        }
    }
}

if ($toolName -in @('write_file', 'edit_file', 'replace')) {
    $path = $toolInput.file_path
    if ($path -match 'node_modules|\.gemini\\(settings|GEMINI)\.md') {
        $output = @{
            decision = 'deny'
            reason = "BLOCKED by RBAC: writing to protected path '$path' is forbidden."
        }
        $output | ConvertTo-Json -Depth 5
        exit 0
    }
}

$output = @{ decision = 'allow' }
$output | ConvertTo-Json -Depth 5
