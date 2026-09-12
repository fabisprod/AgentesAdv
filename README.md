# Advocacia Multiárea

Base local de skills jurídicas brasileiras organizada para uso em escritórios de diferentes áreas. O sistema separa roteamento, execução especializada e revisão profissional.

## Componentes

- `areas do direito/`: 495 skills ativas, incluindo 107 de Penal.
- `agents/`: agentes transversais e o `orquestrador-juridico-geral.md`.
- `catalogo-skills.tsv`: índice gerado para descoberta e auditoria.
- `governanca/`: política de uso, esquema de metadados e cenários de regressão.
- `plugins/advocacia-multi-area/`: plugin local pronto para validação/instalação.

## Fluxo recomendado

1. Inicie pelo `orquestrador-juridico-geral`.
2. Confirme área, polo, órgão, fase, prazo, documentos e resultado pretendido.
3. Leia a skill primária inteira antes de elaborar qualquer entrega.
4. Marque dados ausentes como `[VERIFICAR: ...]` e confira fontes oficiais atuais.
5. Submeta toda entrega externa à revisão e aprovação de advogado habilitado.

## Atualização e validação

Após acrescentar ou alterar skills, execute na raiz do projeto:

```sh
ruby scripts/normalize_openai_prompts.rb
ruby scripts/build_skill_catalog.rb
ruby scripts/audit_legal_skills.rb
ruby scripts/validate_routing_fixtures.rb
ruby scripts/assemble_plugin.rb
python3 /Users/macbookpro/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py plugins/advocacia-multi-area
```

O empacotador exclui skills com `metadata.status: deprecated`; não remova a fonte legada sem uma migração planejada.

## Limites e próxima curadoria

Validação estrutural não é homologação jurídica. O catálogo tem campos para área, rito, fase, polo, gatilhos, exclusões, fontes oficiais, data de corte e status de revisão. Preencha-os e registre `review_status: homologada` somente depois de revisão material por especialista.

As lacunas são deliberadas: se a suíte de cenários apontar `lacuna`, o roteador deve coletar fatos e registrar a necessidade de nova skill, e não produzir peça final por analogia. No estado atual, as prioridades identificadas são resposta à acusação penal comum, Propriedade Intelectual e Recuperação Judicial/Falências.
