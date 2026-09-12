$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$marketplace = Join-Path $repoRoot ".agents\plugins\marketplace.json"

if (-not (Test-Path -LiteralPath $marketplace -PathType Leaf)) {
  throw "Manifesto Codex ausente: $marketplace"
}
if (-not (Get-Command codex -ErrorAction SilentlyContinue)) {
  throw "Codex CLI não encontrado. Para uso em escritório, importe o repositório privado em Workspace settings > Plugins > Import marketplace."
}

& codex plugin marketplace add $repoRoot
& codex plugin add "advocacia-multi-area@advocacia-escritorios"
Write-Host "Concluído. Abra uma nova tarefa do Codex e selecione o plugin em Sources > Use plugins."
