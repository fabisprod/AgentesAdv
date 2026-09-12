#!/usr/bin/env ruby
# frozen_string_literal: true

# Monta uma distribuição local do plugin sem alterar as fontes das skills.
require "csv"
require "fileutils"
require "yaml"

root = File.expand_path("..", __dir__)
plugin = File.join(root, "plugins", "advocacia-multi-area")
destination = File.join(plugin, "skills")
sources = Dir.glob(File.join(root, "areas do direito", "**", "SKILL.md")).sort

abort "Plugin inexistente: #{plugin}" unless File.directory?(plugin)

active = []
sources.each do |path|
  text = File.read(path)
  ending = text.index("\n---\n", 4)
  next unless text.start_with?("---\n") && ending

  metadata = YAML.safe_load(text[4...ending], permitted_classes: [], aliases: false) || {}
  next if metadata.dig("metadata", "status") == "deprecated"

  name = metadata.fetch("name").to_s
  abort "Nome inválido em #{path}" unless name.match?(/\A[a-z0-9][a-z0-9-]*\z/) && name.length < 64
  active << [name, path, metadata, text]
end

names = active.map(&:first)
abort "Nomes duplicados na distribuição" unless names.uniq.length == names.length

FileUtils.rm_rf(destination)
FileUtils.mkdir_p(destination)
active.each do |name, source, _metadata, _text|
  FileUtils.cp_r(File.dirname(source), File.join(destination, name))
end

router = File.join(destination, "orquestrador-juridico-geral")
FileUtils.mkdir_p(File.join(router, "references"))
FileUtils.mkdir_p(File.join(router, "agents"))
router_skill = <<~MARKDOWN
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
MARKDOWN
File.write(File.join(router, "SKILL.md"), router_skill)

ui = {
  "interface" => {
    "display_name" => "Orquestrador Jurídico Geral",
    "short_description" => "Escolhe a skill jurídica adequada com gates de segurança.",
    "default_prompt" => "Use $orquestrador-juridico-geral para identificar a skill adequada e orientar a próxima ação."
  }
}
File.write(File.join(router, "agents", "openai.yaml"), YAML.dump(ui))

%w[politica-uso-ia-juridica.md schema-roteamento-skills.md].each do |file|
  FileUtils.cp(File.join(root, "governanca", file), File.join(router, "references", file))
end

headers = %w[area name title intent description related_areas jurisdictions procedures phases client_sides deliverables triggers exclusions required_inputs alternatives official_sources legal_cutoff review_status risk_level path]
CSV.open(File.join(router, "references", "catalogo-skills.tsv"), "w", col_sep: "\t", force_quotes: true) do |csv|
  csv << headers
  active.each do |name, source, metadata, text|
    title = text[/^#\s+(.+)$/, 1].to_s.strip
    routing = metadata.dig("metadata", "routing") || {}
    area = routing["area"].to_s
    area = File.basename(File.dirname(source)) if area.empty?
    row = [area, name, title, name.tr("-", " "), metadata["description"].to_s]
    headers[5..-2].each { |key| row << Array(routing[key]).join(" | ") }
    row << "skills/#{name}/SKILL.md"
    csv << row
  end
end

FileUtils.cp(File.join(root, "AGENTS.md"), File.join(plugin, "AGENTS.md"))
puts "Plugin montado: #{active.length} skills especializadas + 1 orquestrador em #{plugin}"
