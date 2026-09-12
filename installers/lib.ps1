Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-InstallerRoot {
  return (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

function Get-PluginSkillsDirectory {
  return (Join-Path (Get-InstallerRoot) "plugins\advocacia-multi-area\skills")
}

function Assert-SkillsPackage {
  $skillsDirectory = Get-PluginSkillsDirectory
  $router = Join-Path $skillsDirectory "orquestrador-juridico-geral\SKILL.md"
  if (-not (Test-Path -LiteralPath $router -PathType Leaf)) {
    throw "Pacote de skills não encontrado em $skillsDirectory"
  }
}

function Install-SkillLinks([string]$DestinationDirectory) {
  $skillsDirectory = Get-PluginSkillsDirectory
  New-Item -ItemType Directory -Path $DestinationDirectory -Force | Out-Null
  $installed = 0
  $skipped = 0

  Get-ChildItem -LiteralPath $skillsDirectory -Directory | ForEach-Object {
    $source = $_.FullName
    $skillFile = Join-Path $source "SKILL.md"
    if (-not (Test-Path -LiteralPath $skillFile -PathType Leaf)) { return }

    $destination = Join-Path $DestinationDirectory $_.Name
    if (Test-Path -LiteralPath $destination) {
      Write-Warning "Skill existente preservada: $destination"
      $skipped++
      return
    }

    # Junctions funcionam sem habilitar o Developer Mode na maioria dos ambientes Windows.
    New-Item -ItemType Junction -Path $destination -Target $source | Out-Null
    $installed++
  }

  Write-Host "Instaladas: $installed links; preservadas: $skipped; destino: $DestinationDirectory"
}
