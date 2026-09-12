# Instaladores

Execute os scripts sempre a partir de um clone confiável e atualizado deste repositório. Eles usam links simbólicos para a fonte local e nunca substituem uma skill existente com o mesmo nome.

```sh
git clone https://github.com/fabisprod/AgentesAdv.git ~/advocacia-ai
cd ~/advocacia-ai
bash installers/install-claude.sh
bash installers/install-opencode.sh
bash installers/install-codex.sh
```

Para atualização, execute `git pull --ff-only` dentro do clone. Claude Code e OpenCode passam a usar o conteúdo atualizado pelos links simbólicos; reinicie a sessão. Para Codex em equipe, atualize pelo marketplace privado no painel administrativo em vez de rodar o instalador local em cada máquina.

O instalador Codex é destinado a teste/local e exige o CLI `codex`. O marketplace compartilhado está em `.agents/plugins/marketplace.json` e deve ser importado por um administrador do workspace.
