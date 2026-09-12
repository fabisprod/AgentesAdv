#!/usr/bin/env bash
set -euo pipefail

installer_root() {
  cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P
}

plugin_skills_dir() {
  printf '%s/plugins/advocacia-multi-area/skills\n' "$(installer_root)"
}

require_skills() {
  local skills_dir
  skills_dir="$(plugin_skills_dir)"
  if [[ ! -d "$skills_dir" ]] || [[ ! -f "$skills_dir/orquestrador-juridico-geral/SKILL.md" ]]; then
    echo "ERRO: pacote de skills não encontrado em $skills_dir" >&2
    exit 1
  fi
}

link_skills() {
  local target_dir="$1"
  local skills_dir skill name installed skipped
  skills_dir="$(plugin_skills_dir)"
  installed=0
  skipped=0
  mkdir -p "$target_dir"

  for skill in "$skills_dir"/*; do
    [[ -d "$skill" && -f "$skill/SKILL.md" ]] || continue
    name="$(basename "$skill")"
    if [[ -e "$target_dir/$name" || -L "$target_dir/$name" ]]; then
      if [[ -L "$target_dir/$name" ]] && [[ "$(readlink "$target_dir/$name")" == "$skill" ]]; then
        continue
      fi
      echo "AVISO: preservada skill existente: $target_dir/$name" >&2
      skipped=$((skipped + 1))
      continue
    fi
    ln -s "$skill" "$target_dir/$name"
    installed=$((installed + 1))
  done

  echo "Instaladas: $installed links; preservadas: $skipped; destino: $target_dir"
}
