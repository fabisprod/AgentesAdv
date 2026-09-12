---
name: transcricao-audiencia
description: >
  Transforma a transcrição bruta (ou gravação, via ferramenta de transcrição) de uma
  audiência, depoimento, interrogatório ou reunião com cliente em uma NOTA estruturada:
  cabeçalho, fala por participante, pontos-chave, contradições, ações/prazos e citações a
  verificar. Salva no seu vault Obsidian (se houver) ou em pasta local sigilosa do caso.
type: prompt
version: "3.0.1"
categories: [transcricao, audiencia, memoria, conhecimento]
---

# Transcrição de Audiência / Depoimento

## When to use

Para estruturar o registro de um ato oral: audiência de instrução (AIJ), de custódia, sessão
do júri, oitiva de testemunha, interrogatório, ou reunião com cliente. Acionada pela
`secretaria-juridica` ou diretamente. A captação do áudio depende de uma ferramenta de
transcrição (MCP/serviço externo, se disponível); esta skill assume o **texto bruto** e o
transforma em conhecimento utilizável. A **atuação ao vivo** que gera esse material é das
skills `audiencia-inquiricao-testemunhas` (prova oral na AIJ) e `audiencia-de-custodia`
(custódia) — aqui é o registro **depois** do ato.

## Inputs

- **Texto bruto** da transcrição (colado ou apontado), e o contexto (processo, tipo de ato, data).
- **Caso/pessoas:** sua pasta local do caso (sigilosa) e CRM (se houver).
- Integração: se você usar um vault Obsidian, salve na pasta de transcrições do vault;
  senão, grave na pasta local do caso.

## Workflow

1. **Identificar o tipo** do ato (AIJ, custódia, júri, depoimento, interrogatório, reunião) e os
   **participantes** (juízo, MP, defesa, cliente/réu, testemunhas, peritos).
2. **Estruturar** a transcrição por participante/momento, preservando **fielmente** o que foi dito
   — nunca alterar o conteúdo, só organizar.
3. **Extrair inteligência:** pontos-chave, **contradições** (entre depoimentos ou com a prova dos
   autos), fatos relevantes, **protestos e requerimentos consignados em ata** (insumo para as
   nulidades — ver `audiencia-inquiricao-testemunhas` e o agente `mapa-nulidades`),
   **compromissos/prazos** mencionados, e **citações a verificar**.
4. **Linkar** (se vault ativo): wikilinks ao `[[Caso ...]]`, às `[[Pessoas]]` (testemunhas/cliente)
   e às teses pertinentes da sua base local de materiais e jurisprudência (se você mantiver uma).
5. **Salvar** na pasta de transcrições do vault (se houver) ou na pasta local do caso
   (sigilosa, fora de versionamento).

## Output Format

`AAAA-MM-DD — Transcrição — {tipo} — {processo}.md`, com:
**Cabeçalho** (processo, juízo, data, tipo) · **Participantes** · **Transcrição estruturada**
(por falante/momento) · **Pontos-chave** · **Contradições** · **Protestos/requerimentos consignados** · **Ações e prazos** · **Citações a verificar**.

## Conformidade

- **Fidelidade:** não invente nem altere falas — transcrição é registro, não interpretação.
- **Sigilo:** transcrições são sigilosas — vivem só no vault local ou na pasta local do caso, fora de versionamento e de nuvens não autorizadas (dever de sigilo profissional, art. 34, VII, do EOAB).
- Citações jurídicas mencionadas no ato passam pelo agente `verificador-citacoes` antes de irem para peça.
- Saída é insumo para conferência humana.

---
@ Skills Jurídicas
