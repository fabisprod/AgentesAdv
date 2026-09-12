# Metadados de roteamento das skills

O `name` e a `description` continuam sendo os campos oficiais de descoberta. Para curadoria do catálogo multiárea, cada skill poderá acrescentar `metadata.routing` ao frontmatter.

```yaml
metadata:
  routing:
    area: "Tributário"
    related_areas: ["Administrativo"]
    jurisdictions: ["federal", "estadual", "municipal"]
    procedures: ["procedimento comum"]
    phases: ["conhecimento"]
    client_sides: ["contribuinte"]
    deliverables: ["petição inicial"]
    triggers: ["anular lançamento", "auto de infração"]
    exclusions: ["execução fiscal já garantida"]
    required_inputs: ["auto de infração", "data da ciência", "tributo"]
    alternatives: ["tributario-mandado-de-seguranca-tributario"]
    official_sources: ["Planalto", "STF", "STJ", "órgão fazendário competente"]
    legal_cutoff: "AAAA-MM-DD"
    review_status: "pendente | revisada | homologada"
    risk_level: "baixo | médio | alto"
```

## Regras de curadoria

- Use valores jurídicos discriminantes, não sinônimos do título.
- `exclusions` deve impedir as confusões mais prováveis com skills vizinhas.
- `required_inputs` contém apenas dados que mudam cabimento, competência, prazo, pedido ou risco.
- `alternatives` aponta para nomes existentes e explica vias concorrentes no corpo da skill.
- `legal_cutoff` é a data da última conferência material em fontes oficiais; não é a data de edição cosmética.
- `review_status: homologada` exige conferência por advogado da área e teste com caso realista.
- Conteúdo inferido automaticamente nunca recebe status `revisada` ou `homologada`.

O catálogo deve expor esses campos quando existirem. Campos ausentes significam "não curado", e não uma resposta negativa.

