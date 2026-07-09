# Instalador del SDD Harness para Claude Code (Windows / PowerShell).
# Copia los skills y las plantillas a ~/.claude/ (o a $env:CLAUDE_HOME si está seteado).
$ErrorActionPreference = 'Stop'

$src = $PSScriptRoot
$dest = if ($env:CLAUDE_HOME) { $env:CLAUDE_HOME } else { Join-Path $HOME '.claude' }

Write-Host "Instalando SDD Harness en: $dest"
New-Item -ItemType Directory -Force -Path (Join-Path $dest 'skills'), (Join-Path $dest 'sdd') | Out-Null
Copy-Item -Recurse -Force -Path (Join-Path $src 'skills\*') -Destination (Join-Path $dest 'skills')
Copy-Item -Recurse -Force -Path (Join-Path $src 'sdd\*')    -Destination (Join-Path $dest 'sdd')

Write-Host "OK. Abri una sesion NUEVA de Claude Code y proba:  /sdd-help"
