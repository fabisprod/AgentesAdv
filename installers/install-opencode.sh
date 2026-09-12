#!/usr/bin/env bash
set -euo pipefail

# OpenCode descobre automaticamente ~/.agents/skills.
source "$(dirname "$0")/lib.sh"
require_skills

if ! command -v opencode >/dev/null 2>&1; then
  echo "AVISO: OpenCode não encontrado; as skills serão instaladas para o próximo uso." >&2
fi

link_skills "$HOME/.agents/skills"
echo "Concluído. Reinicie o OpenCode e comece por: \$orquestrador-juridico-geral"
