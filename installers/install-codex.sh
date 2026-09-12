#!/usr/bin/env bash
set -euo pipefail

# Instala o marketplace local do clone atual. Para equipes, prefira importar o
# marketplace privado pelo painel administrativo do Codex.
repo_root="$(cd "$(dirname "$0")/.." && pwd -P)"
marketplace="$repo_root/.agents/plugins/marketplace.json"

if [[ ! -f "$marketplace" ]]; then
  echo "ERRO: manifesto Codex ausente: $marketplace" >&2
  exit 1
fi
if ! command -v codex >/dev/null 2>&1; then
  echo "ERRO: Codex CLI não encontrado. Para uso em escritório, importe o repositório privado no painel Workspace settings → Plugins → Import marketplace." >&2
  exit 1
fi

codex plugin marketplace add "$repo_root"
codex plugin add advocacia-multi-area@advocacia-escritorios
echo "Concluído. Abra uma nova tarefa do Codex e selecione o plugin em Sources → Use plugins."
