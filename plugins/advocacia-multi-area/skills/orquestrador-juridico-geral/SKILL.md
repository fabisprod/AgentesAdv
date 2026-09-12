---
name: orquestrador-juridico-geral
description: Roteia demandas jurídicas brasileiras para a skill especializada adequada, aplica gates de segurança e exige revisão profissional antes de qualquer uso externo.
---

# Orquestrador jurídico geral

Use esta skill como porta de entrada para demandas jurídicas brasileiras.

1. Leia `references/catalogo-skills.tsv` e identifique até três candidatas por área, peça, fase, polo, fato e urgência.
2. Antes de escolher, diferencie vias próximas e aplique as exclusões descritas no catálogo ou na skill candidata.
3. Leia integralmente a skill primária em `../<name>/SKILL.md`. Uma skill especializada prevalece sobre esta orientação geral.
4. Para matéria penal, priorize as skills da área Penal e aplique os requisitos próprios de fase processual, liberdade e cadeia de custódia.
5. Se os fatos cruzarem áreas, declare a skill primária e as complementares. Não trate a interseção como uma única área sem verificar competência, rito, prazo e polo.

## Gates obrigatórios

- Confirme jurisdição, órgão, fase, prazo, polo do cliente e documentos disponíveis antes de concluir cabimento ou redigir peça.
- Não invente leis, precedentes, atos processuais, prazos, fatos ou fontes. Indique o que precisa ser conferido em fonte oficial atual.
- Marque lacunas factuais como `[VERIFICAR: ...]` e diferencie informação fornecida, inferência e ponto pendente.
- Entregas destinadas a cliente, parte contrária, tribunal ou órgão público exigem revisão e aprovação humana por advogado habilitado.
- Observe sigilo profissional, minimização de dados e a política em `references/politica-uso-ia-juridica.md`.

## Se não houver rota confiável

Não force uma skill parecida. Explique a lacuna, faça apenas triagem ou pesquisa exploratória identificada como tal e registre a necessidade de curadoria em `references/schema-roteamento-skills.md`.
