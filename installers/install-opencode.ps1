$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib.ps1")
Assert-SkillsPackage

if (-not (Get-Command opencode -ErrorAction SilentlyContinue)) {
  Write-Warning "OpenCode não encontrado; as skills serão instaladas para o próximo uso."
}

Install-SkillLinks (Join-Path $HOME ".agents\skills")
Write-Host "Concluído. Reinicie o OpenCode e comece por: `$orquestrador-juridico-geral"
