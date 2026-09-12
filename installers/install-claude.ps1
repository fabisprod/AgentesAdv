$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "lib.ps1")
Assert-SkillsPackage

if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
  Write-Warning "Claude Code não encontrado; as skills serão instaladas para o próximo uso."
}

Install-SkillLinks (Join-Path $HOME ".claude\skills")
Write-Host "Concluído. Abra uma nova sessão do Claude Code e comece por: `$orquestrador-juridico-geral"
