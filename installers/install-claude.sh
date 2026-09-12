#!/usr/bin/env bash
set -euo pipefail

# Instala as skills sem sobrescrever definições que já pertencem ao usuário.
source "$(dirname "$0")/lib.sh"
require_skills

if ! command -v claude >/dev/null 2>&1; then
  echo "AVISO: Claude Code não encontrado; as skills serão instaladas para o próximo uso." >&2
fi

link_skills "$HOME/.claude/skills"
echo "Concluído. Abra uma nova sessão do Claude Code e comece por: \$orquestrador-juridico-geral"
