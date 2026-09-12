---
name: djen-api-oficial
type: script
version: "3.0.1"
description: >
  Consulta intimações e comunicações do DJEN (Diário de Justiça Eletrônico Nacional)
  via API REST oficial do CNJ — alternativa robusta ao scraping, com dados estruturados
  e certidão oficial de ciência.
categories: [processual, monitoramento, integracao]
---

# DJEN — API Oficial do CNJ (Comunica PJe)

Consulta de comunicações processuais (intimações, citações, despachos publicados) do
**Diário de Justiça Eletrônico Nacional** diretamente pela **API REST pública do CNJ**.
Substitui o scraping frágil do portal web: a consulta é gratuita, sem captcha e
sem login, retorna **JSON estruturado** e ainda emite a **certidão oficial em PDF**.

## When to use

Use sempre que precisar varrer publicações oficiais para detectar atos com prazo,
em vez de raspar o portal web. Indicada como etapa de captura do seu fluxo de gestão
de prazos. Esta skill faz a **captura técnica** (HTTP REST); a **triagem**
(mero expediente × ato com prazo, urgência) continua com o agente `monitor-dje-djen`.

## API — referência (confirmada em produção)

- **Base URL (produção):** `https://comunicaapi.pje.jus.br/api/v1`
- **Homologação/testes:** `https://hcomunicaapi.cnj.jus.br/api/v1`
- **Swagger oficial (PCP/CNJ):** https://app.swaggerhub.com/apis-docs/cnj/pcp/1.0.0
- **Portal web equivalente:** https://comunica.pje.jus.br/consulta

### Endpoint de consulta

```
GET /api/v1/comunicacao
```

Filtros (query string) — combináveis; todos validados ao vivo retornando `success`:

| Parâmetro                   | Descrição                                              |
|-----------------------------|--------------------------------------------------------|
| `numeroOab`                 | Número da OAB do advogado (ex.: `28339`)               |
| `ufOab`                     | UF da OAB (ex.: `PE`) — usar junto com `numeroOab`     |
| `nomeAdvogado`              | Nome do advogado destinatário                          |
| `nomeParte`                 | Nome da parte                                          |
| `numeroProcesso`            | Número do processo **sem máscara** (só dígitos)        |
| `siglaTribunal`             | Sigla do tribunal (ex.: `TJPE`, `TRF2`, `TRT1`)        |
| `dataDisponibilizacaoInicio`| Data inicial do período — formato `AAAA-MM-DD`         |
| `dataDisponibilizacaoFim`   | Data final do período — formato `AAAA-MM-DD`           |
| `meio`                      | Meio da comunicação (`D` = Diário)                     |
| `pagina`                    | Página da paginação (inicia em `1`)                    |
| `itensPorPagina`            | Itens por página (use ~100 para varredura)             |

### Formato da resposta (JSON)

Envelope: `{ "status": "success", "message": "Sucesso", "count": <int>, "items": [...] }`

Campos relevantes de cada item em `items[]`:

```
id                       -> id interno da comunicação
data_disponibilizacao    -> "AAAA-MM-DD" (gatilho da contagem de prazo)
datadisponibilizacao     -> "DD/MM/AAAA" (mesma data, formato BR)
siglaTribunal            -> tribunal de origem
tipoComunicacao          -> "Intimação", "Citação", "Edital"...
nomeOrgao                -> vara/órgão
texto                    -> teor integral da publicação
numero_processo          -> número sem máscara
numeroprocessocommascara -> número formatado (CNJ)
meiocompleto             -> "Diário de Justiça Eletrônico Nacional"
link                     -> link para o documento no PJe de origem
hash                     -> identificador usado para emitir a certidão
status / motivo_cancelamento / data_cancelamento
destinatarios[]          -> { nome, polo }
destinatarioadvogados[]  -> { advogado: { nome, numero_oab, uf_oab } }
```

### Certidão oficial de ciência (PDF)

```
GET /api/v1/comunicacao/{hash}/certidao
```

Retorna `Content-Type: application/pdf` (HTTP 200). Use o `hash` do item da consulta.
É o **comprovante oficial** da comunicação — anexável aos autos e à pasta do cliente.

## Setup

- **Sem autenticação para consulta.** O endpoint `GET /comunicacao` e a emissão de
  certidão são **públicos** (confirmado: HTTP 200 sem token). Apenas o **envio** de
  comunicações por tribunais exige credencial no SCA/Corporativo do CNJ — fora do
  escopo desta skill (que é só leitura).
- **Ferramenta:** qualquer cliente HTTP. Em Claude Code, use `curl` (ou Python
  `requests`). Envie um `User-Agent` de navegador para evitar bloqueio por WAF.
- **Nada a instalar.** Não há chave de API nem dependência externa.

Exemplo de chamada (varredura por OAB no período):

```bash
curl -s -H "User-Agent: Mozilla/5.0" \
  "https://comunicaapi.pje.jus.br/api/v1/comunicacao?numeroOab=28339&ufOab=PE&dataDisponibilizacaoInicio=2026-06-02&dataDisponibilizacaoFim=2026-06-03&pagina=1&itensPorPagina=100"
```

## Workflow

1. **Definir a carteira** — liste os filtros do escritório: pares OAB+UF, nomes de
   advogados, nomes de partes e/ou números de processo a monitorar.
2. **Consultar o período** — para cada filtro, chame `GET /comunicacao` com
   `dataDisponibilizacaoInicio`/`Fim` (em regra, o dia). Pagine via `pagina` +
   `itensPorPagina` até esgotar `count`.
3. **Estruturar o resultado** — monte a tabela: `datadisponibilizacao`, processo
   (`numeroprocessocommascara`), `siglaTribunal`/`nomeOrgao`, `tipoComunicacao`,
   partes/advogados, `texto`, `link` e `hash`.
4. **Emitir certidão** — para cada ato relevante, baixe `…/{hash}/certidao` (PDF) e
   arquive como comprovante oficial de ciência.
5. **Triar** — entregue a tabela ao agente `monitor-dje-djen` para classificar
   urgência e identificar o que vira prazo.
6. **Encadear** — calcule o prazo a partir de `data_disponibilizacao` e agende os
   vencimentos no seu fluxo de trabalho (apoie-se nos agentes `lembrete-prazo` e
   `agenda-audiencia`).

## Vantagem sobre scraping

- **Sem captcha e sem login** — não depende de sessão de navegador nem quebra quando
  o portal muda layout (ao contrário do scraping via navegador).
- **Dados já estruturados** — JSON com campos tipados (datas, processo, OAB, partes);
  dispensa parsing de HTML e reduz erros de extração.
- **Comprovante oficial** — a certidão em PDF (`/{hash}/certidao`) é prova formal da
  comunicação; o scraping não gera documento com fé.
- **Robusto e barato** — fonte oficial do CNJ, gratuita, idempotente e fácil de
  paginar/agendar; ideal para rotina diária automatizada.

## Conformidade

Fonte **oficial** (DJEN/CNJ). Trate teor e dados das partes com sigilo (LGPD); muitos
processos têm partes em segredo de justiça. A certidão oficial deve prevalecer sobre
anotações internas.

## Fontes

- Swagger oficial PCP/CNJ: https://app.swaggerhub.com/apis-docs/cnj/pcp/1.0.0
- Orientações aos Tribunais (CNJ): https://www.cnj.jus.br/programas-e-acoes/processo-judicial-eletronico-pje/comunicacoes-processuais/orientacoes-aos-tribunais/
- Manual DJEN (PJe/CSJT): https://pje.csjt.jus.br/manual/index.php?title=DJEN
- Padrões de API do PJe: https://docs.pje.jus.br/manuais-basicos/padroes-de-api-do-pje/
- Portal de consulta DJEN: https://comunica.pje.jus.br/consulta
- Conector PJe-PCP (GitLab CNJ): https://git.cnj.jus.br/git-jus/conector-pje-pcp

---
@ Skills Jurídicas
